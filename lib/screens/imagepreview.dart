import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vault/screens/album.dart';
import 'package:vault/screens/homepage.dart';
import 'package:vault/screens/videoplayer.dart';
import 'package:vault/widgets/custombutton.dart';
import 'package:video_player/video_player.dart';
import '../consts/consts.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'gallery.dart';

class ImagePreviewScreen extends StatefulWidget {
  final File imageFile;
  final String imageName;
  final Function(File)? onImageRemoved;
  final String? folderName; // Callback function

  const ImagePreviewScreen({
    Key? key,
    required this.imageFile,
    required this.imageName,
    this.onImageRemoved,
    required this.folderName,
  }) : super(key: key);

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  int _selectedIndex = 0;

  Future<Map<String, dynamic>> getImageProperties() async {
    // Load the image using the image package
    final imageData = await widget.imageFile.readAsBytes();
    final image = img.decodeImage(imageData);

    // Get image resolution (width and height)
    final width = image?.width;
    final height = image?.height;

    // Get file size
    final fileSize = widget.imageFile.lengthSync();

    // Get date taken from the file's last modified time
    final fileStat = await widget.imageFile.stat();
    final dateTaken = fileStat.modified;

    // Format the date to extract only the date portion
    final formattedDate = DateFormat('yyyy-MM-dd').format(dateTaken);

    // Parse the formatted date back to a DateTime object
    final parsedDate = DateTime.parse(formattedDate);

    return {
      'width': width,
      'height': height,
      'fileSize': fileSize,
      'dateTaken': parsedDate,
    };
  }

  void showImagePropertiesDialog(Map<String, dynamic> properties) {
    String fileNameWithExtension = widget.imageName.split('/').last;

    // Get the file name without extension
    String fileName = fileNameWithExtension.split('.').first;

    // Get the file extension
    String fileExtension = fileNameWithExtension.split('.').last;

    // Shorten the file name if it's too long
    String shortFileName =
    fileName.length > 10 ? fileName.substring(0, 7) + '...' : fileName;

    // Combine the short file name with the file extension
    String shortImageName = '$shortFileName.$fileExtension';
    // print("MK: foldername: ${widget.folderName}");return;
    String formattedDate =
    DateFormat('yyyy-MM-dd').format(properties['dateTaken']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Consts.FG_COLOR,
          title: Center(
            child: Column(
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
                                        'assets/document 1.svg',
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
                                shortImageName,
                                style: const TextStyle(
                                    fontFamily: "Manrope",
                                    fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.fileSize +': ${properties['fileSize']} bytes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Manrope",
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 1.0,horizontal: 5),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.resolution +':  ${properties['width']} x ${properties['height']} pixels',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Manrope",
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 1.0,horizontal: 5),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dateTaken + ': $formattedDate',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Manrope",
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextButton(
                onPressed: () {
                  // Add your cancel logic here
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(Size(285, 44)),
                  // Set button size
                  backgroundColor: MaterialStateProperty.all(
                      Consts.COLOR), // Set background color
                ),
                child: Text(
                  AppLocalizations.of(context)!.ok,
                  style: TextStyle(color: Colors.white, fontFamily: "Manrope",fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showConfirmationDialog() {
    // Get the file name with extension
    showDialog(
      context: context,
      barrierDismissible: false,
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
                                      'assets/deletedailogue.svg',
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
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(
                                  fontFamily: "Manrope",
                                  fontSize: 18, fontWeight: FontWeight.w700),
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
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.thePhotoWillBeCompletelyDeletedandCannotBeRecovered,
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Manrope",
                            color:
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xFF222222).withOpacity(0.5)
                                : Color(0xFFFFFFFF).withOpacity(0.5)
                        ),
                      ),
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
                      Navigator.pop(context);
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
                              : Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handleDeleteTap();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 40)),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).brightness == Brightness.light
                              ? Color(0xFFDD4848)
                              : Consts.COLOR),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child:  Text(
                      AppLocalizations.of(context)!.delete,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Manrope",
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

  @override
  Widget build(BuildContext context) {
    print('MK: widget.folderName: ${widget.folderName}');
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Get the file name with extension
    String fileNameWithExtension = widget.imageName.split('/').last;

    // Get the file name without extension
    String fileName = fileNameWithExtension.split('.').first;

    // Get the file extension
    String fileExtension = fileNameWithExtension.split('.').last;

    // Shorten the file name if it's too long
    String shortFileName =
    fileName.length > 20 ? fileName.substring(0, 10) + '...' : fileName;

    // Combine the short file name with the file extension
    String shortImageName = '$shortFileName.$fileExtension';

    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Media Preview Screen');


    return Scaffold(
      //backgroundColor: Consts.BG_COLOR,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.07),
        child: AppBar(
          //backgroundColor: Consts.FG_COLOR,
          title: Text(
            shortImageName,
            style: TextStyle(
              //color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              fontFamily: "Manrope",
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                // Retrieve image properties
                final properties = await getImageProperties();

                // Show the image properties in a dialog
                showImagePropertiesDialog(properties);
                FirebaseAnalytics.instance.logEvent(
                  name: 'media_preview_properties',
                  parameters: <String, dynamic>{
                    'activity': 'navigated to media properties',
                  },
                );
              },
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: Icon(
                  Icons.info_outline,
                  size: screenWidth * 0.07,
                  // color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Center(
            child: fileExtension.toLowerCase() == 'mp4' ||
                fileExtension.toLowerCase() == 'mov'
                ? VideoPlayerWidget(file: widget.imageFile)
                : Image.file(
              widget.imageFile,
              fit: BoxFit.contain,
            )),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.copyWith(
            // Adjust the fontSize property to change the label size
            bodyMedium: TextStyle(fontSize: 8,
              fontFamily: "Manrope",),
          ),
        ),
        child: Container(
          height: 120,
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFF5F5F5) // Color for light theme
                : Consts.FG_COLOR,
            //showUnselectedLabels: true,
            unselectedItemColor:
            Theme.of(context).brightness == Brightness.light
                ? Color(0xFF222222) // Color for light theme
                : Colors.white,
            selectedItemColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFF222222)// Color for light theme
                : Colors.white,
            unselectedFontSize: 11,
            selectedFontSize: 11,
            items: [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                          Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF222222)// Color for light theme
                          : Colors.white // Color for dark theme
                      ,
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/share (1) 2.svg',
                    ),
                  ),
                ),
                label: AppLocalizations.of(context)!.share,
                backgroundColor: Consts.FG_COLOR,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 1
                          ? Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF222222)// Color for light theme
                          : Colors.white // Color for dark theme
                          : Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF222222)
                          : Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/padlock 6.svg',
                    ),
                  ),
                ),
                label:  AppLocalizations.of(context)!.unlock,
                backgroundColor: Consts.FG_COLOR,
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      _selectedIndex == 2
                          ? Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF222222)// Color for light theme
                          : Colors.white // Color for dark theme
                          : Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF222222)
                          : Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: SvgPicture.asset(
                      'assets/delete 1.svg',
                    ),
                  ),
                ),
                label: AppLocalizations.of(context)!.delete,
                backgroundColor: Consts.FG_COLOR,
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: (index) async {
              setState(() {
                _selectedIndex = index;
                if (_selectedIndex == 0) {
    if (fileExtension.toLowerCase() == 'mp4' ||
    fileExtension.toLowerCase() == 'mov') {
    shareVideo(widget.imageFile);
    } else {
      shareImage(widget.imageFile);
    }
    FirebaseAnalytics.instance.logEvent(
      name: 'media_preview_share_media',
      parameters: <String, dynamic>{
        'activity': 'navigated to share media',
      },
    );
    }
                else if (_selectedIndex == 1) {
                  _showConfirmationOutDialog();
                  FirebaseAnalytics.instance.logEvent(
                    name: 'media_preview_move_out',
                    parameters: <String, dynamic>{
                      'activity': 'media moved out from galleryvault',
                    },
                  );
                  //_handleUnlockTap();
                } else if (_selectedIndex == 2) {
                  _showConfirmationDialog();
                  FirebaseAnalytics.instance.logEvent(
                    name: 'media_preview_delete',
                    parameters: <String, dynamic>{
                      'activity': 'media deleted from galleryvault',
                    },
                  );
                }
              });
            },
          ),
        ),
      ),
    );
  }
  Future<void> shareImage(File imageFile) async {
    try {
      // Share the image file
      await Share.shareFiles([imageFile.path], text: 'Check out this image!');
    } catch (e) {
      // Handle error
      print('Error sharing image: $e');
    }
  }

  Future<void> shareVideo(File videoFile) async {
    try {
      // Share the video file
      await Share.shareFiles([videoFile.path], text: 'Check out this video!');
    } catch (e) {
      // Handle error
      print('Error sharing video: $e');
    }
  }
  void _showConfirmationOutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                                      'assets/lock-padlock-symbol-for-security-interface 2.svg',
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
                              AppLocalizations.of(context)!.moveOut,
                              style: const TextStyle(
                                  fontFamily: "Manrope",
                                  fontSize: 18, fontWeight: FontWeight.w700),
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
                const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                          AppLocalizations.of(context)!.areYouSureYouWantToMoveItemsOutOfGalleryVault,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Manrope",
                            color:
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xFF222222).withOpacity(0.5)
                                : Color(0xFFFFFFFF).withOpacity(0.5),)
                      ),
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
                      Navigator.pop(context);
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
                            : Color(0xFF363C54),
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
                    onPressed: () {
                      Navigator.pop(context);
                      saveImageToGallery(widget.imageFile);
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
                      AppLocalizations.of(context)!.confirm,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Manrope",
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
  Future<void> saveImageToGallery(File imageFile) async {
    try {
      final result = await ImageGallerySaver.saveFile(imageFile.path);
      if (result['isSuccess']) {
        Navigator.pop(context);

        print('Image saved to gallery successfully.');
      } else {
        print('Failed to save image to gallery.');
      }
    } catch (e) {
      print('Error saving image to gallery: $e');
    }

    bool fileExists = await widget.imageFile.exists();
    print('Does the file exist? $fileExists');

    if (!fileExists) {
      print(
          'The image file does not exist at path: ${widget.imageFile.path}');
      return; // Exit since file doesn't exist
    }

    // Attempt to delete the image file
    try {
      // Delete the file

      print('Video file path before deletion: ${widget.imageFile.path}');
      // Open the Hive box
      final box = await Hive.openBox(widget.folderName ??
          'defaultFolderName'); // Provide a default folder name if widget.folderName is null

      print(
          "MK: boxKeys:1 ${box.keys} || ${widget.folderName} || ${box.keys.length}");
      String? keyToRemove;
      for (var key in box.keys) {

        // await box.delete(key);
        // continue;

        print("key to remove $keyToRemove");
        final value = box.get(key);

        // String extension =
        //     widget.imageFile.path.split('.').last.toLowerCase();

        final filePath =
            '${(await getTemporaryDirectory()).path}/$key.png';
        if (value is Uint8List && filePath == widget.imageFile.path) {
          keyToRemove = key;
          break;
        } else if (value is String) {
          print("MK: $value | ${widget.imageFile.path}");
          print("MK: value is string and ${File(value).path == widget.imageFile.path}");
          if (File(value).path == widget.imageFile.path) {
            keyToRemove = key;
            break;
          }
        }
      }

      print("key to remove $keyToRemove ");

      // Delete the associated key from the Hive box
      if (keyToRemove != null) {
        await widget.imageFile.delete();
        await box.delete(keyToRemove);
      } else {}

      // If there is a callback function to notify the parent page, call it
      if (widget.onImageRemoved != null) {
        widget.onImageRemoved!(widget.imageFile);
      }

      print('Video file path after deletion: ${widget.imageFile.path}');
      // Notify the user that the image has been deleted

      print('Image deleted successfully.');

    } catch (e) {
      // Handle any errors that may occur during the deletion
      print('Error deleting image file: $e');

    }
  }
  void _handleDeleteTap() async {
    if (_selectedIndex == 2) {
      // Check if the image file exists before attempting to delete
      bool fileExists = await widget.imageFile.exists();
      print('Does the file exist? $fileExists');

      if (!fileExists) {
        print(
            'The image file does not exist at path: ${widget.imageFile.path}');

        return; // Exit since file doesn't exist
      }

      // Attempt to delete the image file
      try {
        // Delete the file

        print('Video file path before deletion: ${widget.imageFile.path}');
        // Open the Hive box
        final box = await Hive.openBox(widget.folderName ??
            'defaultFolderName'); // Provide a default folder name if widget.folderName is null

        print(
            "MK: boxKeys:1 ${box.keys} || ${widget.folderName} || ${box.keys.length}");
        String? keyToRemove;
        for (var key in box.keys) {

          // await box.delete(key);
          // continue;

          print("key to remove $keyToRemove");
          final value = box.get(key);

          // String extension =
          //     widget.imageFile.path.split('.').last.toLowerCase();

          final filePath =
              '${(await getTemporaryDirectory()).path}/$key.png';
          if (value is Uint8List && filePath == widget.imageFile.path) {
            keyToRemove = key;
            break;
          } else if (value is String) {
            print("MK: $value | ${widget.imageFile.path}");
            print("MK: value is string and ${File(value).path == widget.imageFile.path}");
            if (File(value).path == widget.imageFile.path) {
              keyToRemove = key;
              break;
            }
          }
        }

        print("key to remove $keyToRemove ");

        // Delete the associated key from the Hive box
        if (keyToRemove != null) {
          await widget.imageFile.delete();
          await box.delete(keyToRemove);
        } else {}

        // If there is a callback function to notify the parent page, call it
        if (widget.onImageRemoved != null) {
          widget.onImageRemoved!(widget.imageFile);
        }

        print('Video file path after deletion: ${widget.imageFile.path}');
        // Notify the user that the image has been deleted

        print('Image deleted successfully.');

        Navigator.pop(context);
        // Navigator.push(context,
        //     MaterialPageRoute(builder: (context) =>
        //         HomePage()));
      } catch (e) {
        // Handle any errors that may occur during the deletion
        print('Error deleting image file: $e');

      }
    }
  }
}
