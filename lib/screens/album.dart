import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../consts/consts.dart';
import '../permission.dart';
import 'gallery.dart';
import 'imagepreview.dart';

class FolderContentsPage extends StatefulWidget {
  final String? folderName;
  final List<File>? folderContents; // Images from homepage
  final Function(List<File>)? updateFolderContents;
  final bool? isFirstAddButtonClick;


  const FolderContentsPage({
    Key? key,
    required this.folderName,
    required this.updateFolderContents,
    required this.folderContents,
    this.isFirstAddButtonClick,
  }) : super(key: key);

  @override
  State<FolderContentsPage> createState() => _FolderContentsPageState();
}

class _FolderContentsPageState extends State<FolderContentsPage> {

  final GlobalKey _addButtonKey = GlobalKey();

  Future<List<File>> retrieveAndCombineImages() async {
    // Retrieve images from the Hive database
    final databaseImages = await retrieveImagesFromHive();

    // Create a set of image file paths already in the Hive database
    final databaseImagePaths = Set<String>();
    for (var file in databaseImages) {
      databaseImagePaths.add(file.path);
    }

    // Check and save new images from folderContents to the Hive database
    for (var file in widget.folderContents!) {
      if (!databaseImagePaths.contains(file.path)) {
        String extension = file.path.split('.').last.toLowerCase();
        if (extension == 'mp4' || extension == 'mov') {
          await saveVideoToHive(file, widget.folderName!);
        } else {
          // Save the new image to the Hive database
          await saveImageToHive(file, widget.folderName!);
        }
      }
    }

    setState(() {

    });

    // Retrieve the updated images from the database
    final updatedDatabaseImages = await retrieveImagesFromHive();

    // Combine images from homepage and updated database
    final combinedImages = updatedDatabaseImages.reversed.toList();

    return combinedImages;
  }

  Future<Uint8List?> generateVideoThumbnail(String videoPath) async {
    final thumbnailPath = await VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 100,
      quality: 100, // Adjust thumbnail quality as needed
    );
    return thumbnailPath;
  }

  // Method to save an image file to Hive
  Future<void> saveImageToHive(File imageFile, String folderName) async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(folderName);

    // Read the image file as bytes
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Use the file path as the key to store the image bytes in the box
    final key = imageFile.path.split('/').last;

    // Store the image bytes in the box
    await box.put(key, imageBytes);
  }

  Future<void> saveVideoToHive(File file, String folderName) async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(folderName);

    // Use the file path as the key to store the image bytes in the box
    final key = file.path.split('/').last;

    // Store the image bytes in the box
    await box.put(key, file.path);
  }

// Method to delete media (both images and videos) from Hive
  Future<void> deleteMediaFromHive(String mediaPath) async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(widget.folderName!);

    // Remove the entry corresponding to the media path
    await box.delete(mediaPath);
  }

// Method to handle adding a new image
  Future<void> addNewImage(File newImage, String folderName) async {
    // Save the new image to Hive
    await saveImageToHive(newImage, folderName);

    // Update the folder contents list
    widget.folderContents!.add(newImage);

    // Notify the parent widget to update the UI
    if (widget.updateFolderContents != null) {
      widget.updateFolderContents!(widget.folderContents!);
    }
  }

  Future<List<File>> retrieveImagesFromHive() async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(widget.folderName!);
    List<File> retrievedImages = [];

    print(
        "MK: boxKeys:0 ${box.keys} || ${widget.folderName} || ${box.keys.length}");

    // Iterate through the keys in the box
    for (var key in box.keys) {
      final value = box.get(key);
      // print('Key: $key, Value: $value');
      if (value is Uint8List) {
        // print('value is uint8list');
        // Create a temporary directory and save the image file
        final tempDir = await getTemporaryDirectory();
        final fileName = '$key.png';
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(value);
        if (await file.exists()) {
          retrievedImages.add(file);
        }
      } else if (value is String) {
        // Assume it's a video file path
        // print('value is string');
        final file = File(value);
        // print('MK: is video Exists: ${key}');
        // Assume it's a video file path
        if (await file.exists()) {
          retrievedImages.add(File(value));
        }
      }
    }
    return retrievedImages.toSet().toList();
  }

  void initState() {
    super.initState();
    // Show the dialog only when the app is first launched
    //_createTutorial();
    _checkFirstLaunch();
    retrieveAndCombineImages();
    //GalleryService.removeFirstLaunch();///Temporary
    //_showAddFilesDialog(context);
  }


  void _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('first_launch') ?? true;

    if (isFirstLaunch) {
      // Set the flag to false to indicate that the dialog has been shown
      prefs.setBool('first_launch', false);
      // Show the dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _createTutorial();
      });
    }
  }

  Future<List<dynamic>> retrieveMediaFromHive() async {
    // Open the Hive box for the specified folder
    final box = await Hive.openBox(widget.folderName!);
    List<dynamic> retrievedMedia = [];

    // Iterate through the keys in the box
    // Create a temporary directory and save the image file
    final tempDir = await getTemporaryDirectory();

    // print(
    //     "MK: boxKeys:4 ${box.keys} || ${widget.folderName} || ${box.keys.length}");

    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Uint8List) {
        // Assume it's an image
        final fileName = '$key.png';
        final filePath = '${tempDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(value);
        // retrievedMedia.add(file);
        // file.delete();
        // await deleteMediaFromHive(file.path);
        // print('MK: image Exists: ${await file.exists()}');
        if (await file.exists()) {
          retrievedMedia.add(file);
        }
        // else {
        //   print('MK: removing image ${value}');
        //   await deleteMediaFromHive(file.path);
        // }
      } else if ((value is String)) {
        final file = File(value);
        // print('MK: is video Exists: ${key}');
        // Assume it's a video file path
        if (await file.exists()) {
          retrievedMedia.add(value);
        }
        // else {
        //   print('MK: removing video ${value}');
        //   await deleteMediaFromHive(value);
        // }
      }
    }
    return retrievedMedia.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Albums Screen');

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.07),
        child: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? const Color(0xFFFFFFFF) // Color for light theme
              : Consts.FG_COLOR,
          title: Text(
            widget.folderName!,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFamily: 'Manrope',
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                FirebaseAnalytics.instance.logEvent(
                  name: 'album_add_from_gallery',
                  parameters: <String, dynamic>{
                    'activity': 'Navigating to Gallery',
                    'action': 'Button Clicked',
                  },
                );

                dynamic callback = () async {
                  // If it's not the first launch, navigate to the gallery screen
                  final pickedFiles = await ImagePicker().pickMultipleMedia();
                  print('MK: pickedFiles: ${pickedFiles.length}');
                  List<String> filesPath =
                  pickedFiles.map((e) => e.path).toList();
                  final res = await GalleryService.showConfirmationDialog(context,
                      selectedImagePaths: filesPath,
                      folderName: widget.folderName!);
                  if (res == true) {
                    setState(() {});
                  }
                };
                // SharedPreferences prefs = await SharedPreferences.getInstance();
                // bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
                if (await GalleryService.isFirstAppLaunch()) {
                  // prefs.setBool('isFirstLaunch', false);
                  // prefs.setBool('isFirstAddButtonClick', false);
                  // Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Permission(folderName: widget.folderName, successCallback: callback,),
                    ),
                  );
                } else {
                  callback();

                }
              },
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Container(
                  height: screenHeight * 0.05,
                  width: screenHeight * 0.05,
                  decoration: BoxDecoration(
                    color: Consts.COLOR,
                    borderRadius: BorderRadius.circular(screenHeight * 0.01),
                  ),
                  child: KeyedSubtree(
                    key: _addButtonKey,
                    child: Icon(
                      Icons.add,
                      size: screenWidth * 0.06,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: FutureBuilder<List<dynamic>>(
          future: retrieveMediaFromHive(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              int shimmerCount = snapshot.data != null ? snapshot.data!.length : 0;
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: shimmerCount, // Placeholder count for shimmer effect
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    );
                  },
                ),
              );
            } else if (snapshot.hasData) {
              List<dynamic> combinedMedia = snapshot.data!;
              // print('MK: combinedMedia: ${combinedMedia}');
              if (combinedMedia.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset('assets/folder (2) 1.svg'),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noFileFound,
                        style: TextStyle(
                          fontSize: 24,
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.thereIsNoFileInTheAlbumYet,
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Manrope",
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // print('MK: combinedMedia: ${combinedMedia.length} for $combinedMedia');
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                  ),
                  itemCount: combinedMedia.length,
                  itemBuilder: (context, index) {
                    final media = combinedMedia[index];
                    // print('MK: media is File: ${media is File}');
                    if (media is File) {
                      return GestureDetector(
                        onTap: () {
                          FirebaseAnalytics.instance.logEvent(
                            name: 'album_media',
                            parameters: <String, dynamic>{
                              'activity': 'Navigating to PreviewScreen',
                              'action': 'Media Clicked',
                            },
                          );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImagePreviewScreen(
                                imageFile: media,
                                imageName: media.path.split('/').last,
                                onImageRemoved: (removedMedia) async {
                                  setState(() {
                                    combinedMedia.removeWhere((item) {
                                      if (item is File) {
                                        return item == removedMedia;
                                      } else if (item is String) {
                                        return item == removedMedia.path;
                                      }
                                      return false;
                                    });
                                  });

                                  // Delete the media from the database
                                  if (removedMedia is File) {
                                    await deleteMediaFromHive(removedMedia.path);
                                  }
                                },
                                folderName: widget.folderName,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              media,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    } else if (media is String) {
                      return FutureBuilder<Uint8List?>(
                        future: generateVideoThumbnail(media),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              color: Colors.grey,
                            );
                          } else if (snapshot.hasData) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          final videoName = media.split('/').last;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImagePreviewScreen(
                                                imageFile: File(media),
                                                // Replace 'file' with 'media'
                                                imageName: videoName,
                                                onImageRemoved: (removedMedia) async {
                                                  setState(() {
                                                    combinedMedia.removeWhere((item) {
                                                      if (item is File) {
                                                        return item == removedMedia;
                                                      } else if (item is String) {
                                                        return item == removedMedia.path;
                                                      }
                                                      return false;
                                                    });
                                                  });

                                                  // Delete the media from the database
                                                  if (removedMedia is File) {
                                                    await deleteMediaFromHive(
                                                        removedMedia.path);
                                                  }
                                                },
                                                // folderName: '',
                                                folderName: widget.folderName,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16.0, horizontal: 5),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final videoName = media.split('/').last;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImagePreviewScreen(
                                          imageFile: File(media),
                                          // Replace 'file' with 'media'
                                          imageName: videoName,
                                          onImageRemoved: (removedMedia) async {
                                            setState(() {
                                              combinedMedia.removeWhere((item) {
                                                if (item is File) {
                                                  return item == removedMedia;
                                                } else if (item is String) {
                                                  return item == removedMedia.path;
                                                }
                                                return false;
                                              });
                                            });

                                            // Delete the media from the database
                                            if (removedMedia is File) {
                                              await deleteMediaFromHive(
                                                  removedMedia.path);
                                            }
                                          },
                                          // folderName: '',
                                          folderName: widget.folderName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                )
                              ],
                            );
                          } else {
                            return Container();
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              }
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/folder (2) 1.svg'),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noFileFound,
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.thereIsNoFileInTheAlbumYet,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
  Future<void> _createTutorial() async {
    final targets = [
      TargetFocus(
        identify: 'floatingButton',
        keyTarget: _addButtonKey,
        alignSkip: Alignment.topCenter,
        contents: [
          TargetContent(
            builder: (context, controller) => Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment : MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 50.0),
                  child: SvgPicture.asset(
                    'assets/Layer 88.svg',
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.addFiles,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.youCanAddPhotosAndVideosTo+'\n'+
                      AppLocalizations.of(context)!.theAlbumByTapping +" +.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    ];

    final tutorial = TutorialCoachMark(
      targets: targets,
      textSkip: '',
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      tutorial.show(context: context);
    });
  }
}
