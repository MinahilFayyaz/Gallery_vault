import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../consts/consts.dart';

class GalleryService {
  static Future<bool?> showConfirmationDialog(BuildContext context,
      {List<String> selectedImagePaths = const [],
      String folderName = ''}) async {
    if (selectedImagePaths.isEmpty) {
      // No images selected, so return null indicating no action
      return null;
    }
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Consts.FG_COLOR,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 70.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Color(
                                          0xFFF5F5F5) // Color for light theme
                                      : Consts.FG_COLOR,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Image widget inside the Stack
                              Positioned(
                                child: ClipOval(
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors
                                                .black // Color for light theme
                                            : Colors.white,
                                        BlendMode.srcIn),
                                    child: SvgPicture.asset(
                                      'assets/Group.svg',
                                      // Replace with the path to your image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.moveIn,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700,
                              fontFamily: "Manrope"),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0,),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.areYouSureYouWantTo +'\n'+
                          AppLocalizations.of(context)!.move +'${selectedImagePaths.length} item(s)' + AppLocalizations.of(context)!.inThe
                            +"\n"+ AppLocalizations.of(context)!.galleryVault,
                        maxLines: 3,
                      style: TextStyle(
                          fontSize: 16,
                          color:
                              Theme.of(context).brightness == Brightness.light
        ? Color(0xFF222222).withOpacity(0.5)
            : Color(0xFFFFFFFF).withOpacity(0.5),)
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // Add your cancel logic here
                      Navigator.pop(context, false);
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      minimumSize: MaterialStateProperty.all(Size(100, 40)),
                      // Set button size
                      backgroundColor: MaterialStateProperty.all(
                        Theme.of(context).brightness == Brightness.light
        ? Color(0xFFF5F5F5) // Color for light theme
            : Color(0xFF363C54), //
                      ), // Set background color
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
        ? Color(0xFF222222) // Color for light theme
            : Colors.white
        ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(
                          context,
                          await saveSelectedImagesToDatabase(context,
                              selectedImagePaths: selectedImagePaths,
                              folderName: folderName));
                      // FirebaseAnalytics.instance.logEvent(
                      //   name: 'gallery_lock_confirm',
                      //   parameters: <String, dynamic>{
                      //     'activity': 'Selected all media locked',
                      //     'action': 'Confirm Clicked',
                      //   },
                      // );
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 40)),
                      backgroundColor: MaterialStateProperty.all(Consts.COLOR),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                    AppLocalizations.of(context)!.confirm ,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<bool> saveSelectedImagesToDatabase(BuildContext context,
      {List<String> selectedImagePaths = const [],
      String folderName = ''}) async {
    int selectedImageCount = selectedImagePaths.length;
    print('Number of selected images: $selectedImageCount');

    print('Saving selected images to the database...');
    bool allImagesSaved = true;

    if (selectedImagePaths.isEmpty) {
      print('No selected image paths');
      return false;
    }

    for (int i = 0; i < selectedImagePaths.length; i++) {
      // if (_isSelected[i]) {
      final String mediaPath = selectedImagePaths[i];
      // print('Media path at index $i: $mediaPath');

      HiveService hiveService = HiveService();

      // Determine the type of media based on file extension
      String extension = mediaPath.split('.').last.toLowerCase();
      if (extension == 'mp4' || extension == 'mov') {
        // It's a video file
        print('Saving video at index $i...');
        try {
          // Uint8List videoBytes = await _getVideoBytes(mediaPath);
          await hiveService.storeVideo(mediaPath, folderName);
          print('Video at index $i saved successfully');
        } catch (error) {
          print('Failed to save video at index $i: $error');
          allImagesSaved = false;
        }
      } else {
        Uint8List imageBytes = await getImageBytes(selectedImagePaths[i]);

        print('Image bytes at index $i: ${imageBytes.length}');
        if (imageBytes.isNotEmpty) {
          try {
            await hiveService.storeImage(imageBytes, folderName);
            print('Image $i saved successfully');
          } catch (error) {
            print('Failed to save image $i: $error');
            allImagesSaved = false;
          }
        } else {
          print('Image bytes at index $i are empty');
          allImagesSaved = false;
        }
      }
      // }
    }

    selectedImagePaths.clear();

    if (allImagesSaved) {
      showSnackBar(
          context, 'All selected images have been saved to the database.');
      //_openSavedImagesScreen();
    } else {
      showSnackBar(context, 'Some images have not been saved to the database.');
    }
    return true;
    // Navigator.pop(context, true);
  }

  static Future<Uint8List> getImageBytes(String filePath) async {
    try {
      // Create a File object from the given file path
      File file = File(filePath);

      // Read the file as bytes
      Uint8List fileData = await file.readAsBytes();

      if (fileData.isNotEmpty) {
        // If the file data is not empty, return the bytes
        return fileData;
      } else {
        print('File data is empty for path $filePath');
        return Uint8List(0);
      }
    } catch (error) {
      print('Error reading image bytes for path $filePath: $error');
      return Uint8List(0);
    }
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static Future<Uint8List?> generateVideoThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      // Adjust thumbnail size as needed
      quality: 100, // Adjust thumbnail quality as needed
    );
    return thumbnailPath;
  }

  static Future<bool> isFirstAppLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    return isFirstLaunch;
  }

  static Future<void> doneFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isFirstLaunch', false);
  }
  static Future<void> removeFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('isFirstLaunch',);
  }
}

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    super.key,
    required this.entity,
  });

  final AssetEntity entity;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  late final future;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      future = widget.entity.file;
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingWidget();
    }
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final file = snapshot.data;
          if (file != null) {
            // print('before buildImageWidget');
            final String filePath = file.path.toLowerCase();
            if (filePath.endsWith('.mp4') || filePath.endsWith('.mov')) {
              // print('buildvideowidget $type');
              // return SizedBox();
              return NestedVideoWidget(file: file);
            } else {
              // print('futurebuilder: $type');
              return NestedImageWidget(file: file);
            }
          }
        }
        return const Center(
            child:
                CircularProgressIndicator()); // clienrt was sayiong probably we have in thousands of images in ios a  minimum of 200 will be okay
      },
    );
  }
}

class NestedVideoWidget extends StatefulWidget {
  const NestedVideoWidget({
    super.key,
    required this.file,
  });

  final File file;

  @override
  State<NestedVideoWidget> createState() => _NestedVideoWidgetState();
}

class _NestedVideoWidgetState extends State<NestedVideoWidget> {
  late final future;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      future = _generateThumbnail(widget.file);
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  Future<Uint8List?> _generateThumbnail(File file) async {
    try {
      // print('MK: before thumbnail:');
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: file.path,
        imageFormat: ImageFormat.PNG, // Choose the desired image format
        quality: 10, // Adjust the quality of the thumbnail (0 - 100)
      );
      // print('MK: thumbnail done');
      return thumbnail;
    } catch (e, s) {
      print('MK: error in thumbnail: $e and $s');
    }
    return null;
  }

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingWidget();
    }
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        // print('MK: snapshot in vid widget: ${snapshot.hasData}');
        if (snapshot.hasError) {
          // print('MK: snapshot error: ${snapshot.error} ${snapshot.stackTrace}');
        }
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          final Uint8List thumbnailBytes = snapshot.data as Uint8List;
          return Image.memory(
            thumbnailBytes,
            width: 100, // Set a fixed width for the thumbnail
            height: 100,
            fit: BoxFit.cover,
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class NestedImageWidget extends StatefulWidget {
  const NestedImageWidget({
    super.key,
    required this.file,
  });

  final File file;

  @override
  State<NestedImageWidget> createState() => _NestedImageWidgetState();
}

class _NestedImageWidgetState extends State<NestedImageWidget> {
  late final future;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      future = widget.file.readAsBytes();
      setState(() {
        loading = false;
      });
    });
    super.initState();
  }

  bool loading = true;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return LoadingWidget();
    }
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<Uint8List> bytesSnapshot) {
        if (bytesSnapshot.connectionState == ConnectionState.done) {
          final bytes = bytesSnapshot.data;
          // print('original bytes : $bytes');
          if (bytes != null) {
            return Container(
                width: 100, // Set a fixed width for the image
                height: 100,
                child: Image.memory(bytes, fit: BoxFit.cover));
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Set a fixed width for the image
      height: 100,
      color: Colors.black12,
    );
  }
}

class HiveService {
  Future<void> storeImage(dynamic media, String folderName) async {
    print('Storing media in the database...');
    var box = await Hive.openBox(folderName);

    var key = DateTime.now().millisecondsSinceEpoch.toString();

    // print('media : $media');
    if (media is Uint8List) {
      print('Uint8list media');
      // If media is image bytes, store directly
      await box.put(key, media);
      print('Image stored in database with key $key');
    } else if (media is String) {
      print('string media');
      // If media is video file path, read file and store bytes
      if (media.toLowerCase().endsWith('.mp4') ||
          media.toLowerCase().endsWith('.mov')) {
        print('mp4 media');
        try {
          File file = File(media);
          Uint8List videoBytes = await file.readAsBytes();
          await box.put(key, videoBytes);
          print('Video stored in database with key $key');
        } catch (error) {
          print('Error storing video in database: $error');
        }
      } else {
        print('Unsupported media type');
      }
    } else {
      print('Unsupported media type');
    }
  }

  Future<void> storeVideo(String filePath, String folderName) async {
    print('Storing video in the database...');
    var box = await Hive.openBox(folderName);

    var key = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await box.put(key, filePath);
      print('Video stored in database with key $key');
    } catch (error) {
      print('Error storing video in database: $error');
    }
  }
}
