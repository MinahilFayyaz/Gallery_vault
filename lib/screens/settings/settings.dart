import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vault/screens/homepage.dart';
import 'package:vault/screens/languages.dart';
import 'package:vault/screens/settings/app_icons.dart';
import 'package:vault/screens/settings/premium.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../consts/consts.dart';
import '../../provider/themeprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/selectionbuttonwidget.dart';
import '../auth/chagepassword.dart';

class SettingsPage extends StatelessWidget {
  final int totalAlbums;
  final List<String> folderNames;

  const SettingsPage(
      {Key? key, required this.totalAlbums, required this.folderNames})
      : super(key: key);

  Future<bool> _saveImageToGallery(
      BuildContext context, Uint8List imageData, String imageName) async {
    try {
      print('Attempting to save image: $imageName');
      print('Image data length: ${imageData.length}');

      // Attempt to save the image
      final result =
      await ImageGallerySaver.saveImage(imageData, name: imageName);

      if (result['isSuccess'] == true) {
        print('Image $imageName saved to gallery successfully!');
        return true;
      } else {
        print('Failed to save image: ${result['error']}');
        return false;
      }
    } catch (error) {
      // Catch and log any errors that occurred during the save process
      print('Failed to save image $imageName: $error');
      return false;
    }
  }

  Future<bool> _saveFileToGallery(
      BuildContext context, String filePath, String fileName) async {
    try {
      print('Attempting to save file: $fileName');
      // print('Image data length: ${imageData.length}');

      // Attempt to save the image
      final result = await ImageGallerySaver.saveFile(filePath, name: fileName);

      if (result['isSuccess'] == true) {
        print('File $fileName saved to gallery successfully!');
        return true;
      } else {
        print('Failed to save file: ${result['error']}');
        return false;
      }
    } catch (error) {
      // Catch and log any errors that occurred during the save process
      print('Failed to save file $fileName: $error');
      return false;
    }
  }

  Future<void> _exportAllImages(BuildContext context) async {
    try {
      // Calculate total number of images to export
      int totalImages = 0;
      for (final folderName in folderNames) {
        final Box box = await Hive.openBox(folderName);
        totalImages += box.length;
        await box.close();
      }

      // Show initial progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          message: 'Exporting files...',
          progress: 0.0, // Start with 0 progress
        ),
      );

      // Initialize variables to track progress
      int exportedImages = 0;

      // Iterate over each folder name
      for (final folderName in folderNames) {
        // Open the Hive box for the current folder
        final Box box = await Hive.openBox(folderName);

        // Get the keys (image names) from the box
        final List<dynamic> keys = box.keys.toList();

        // Iterate over the keys (image names)
        for (final key in keys) {
          if (box.get(key) is Uint8List) {
            // Get the image data from the box
            final Uint8List imageData = box.get(key) as Uint8List;
            // Save the image to the gallery
            await _saveImageToGallery(context, imageData, key.toString());
          } else if (box.get(key) is String) {
            final String videoPath = box.get(key) as String;
            await _saveFileToGallery(context, videoPath, key.toString());
          }

          // Update progress
          exportedImages++;

          // Calculate progress
          double progress =
          totalImages == 0 ? 1.0 : exportedImages / totalImages;

          // Update progress dialog
          Navigator.of(context).pop(); // Close current dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ProgressDialog(
              progress: progress,
              message: AppLocalizations.of(context)!.exportingFiles + "....",
            ),
          );
        }

        // Close the box after processing all images in the folder
        await box.close();
      }

      // Hide the progress dialog and show a success message
      Navigator.of(context).pop();
      FirebaseAnalytics.instance.logEvent(
        name: 'settings_exported_all_images',
        parameters: <String, dynamic>{
          'activity': 'Navigating to Settings',
          'action': 'exported all images to gallery',
        },
      );// Hide the progress dialog
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('All files exported successfully!')),
      // );
    } catch (error) {
      // Hide the progress dialog and show an error message
      Navigator.of(context).pop();
      FirebaseAnalytics.instance.logEvent(
        name: 'settings_exported_all_images',
        parameters: <String, dynamic>{
          'activity': 'Navigating to Settings',
          'action': 'exported failed to save images to gallery',
        },
      );
    }
  }

  Future<void> _exportAllFiles(BuildContext context) async {
    try {
      // Get the path to the temporary directory
      final Directory directory = await getTemporaryDirectory();

      // Define the path to the zip file
      final String zipFilePath = '${directory.path}/exported_files.zip';

      // Create a zip file
      final File zipFile = File(zipFilePath);
      final ZipFileEncoder zipEncoder = ZipFileEncoder();
      zipEncoder.create(zipFilePath); // Start the zip creation

      // Initialize variables to track progress
      int exportedImages = 0;

      // Calculate total number of images to export
      int totalImages = 0;
      for (final folderName in folderNames) {
        final Box box = await Hive.openBox(folderName);
        totalImages += box.length;
        await box.close();
      }

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ProgressDialog(
          progress: 0, // Start with 0 progress
          message: AppLocalizations.of(context)!.exportingFiles + "....",
        ),
      );

      // Iterate over each folder and export its contents
      for (final String folderName in folderNames) {
        final Box box = await Hive.openBox(folderName);
        final List<dynamic> keys = box.keys.toList();

        // Iterate over the files in the folder
        for (final dynamic key in keys) {
          // final Uint8List imageData = box.get(key) as Uint8List;
          final String imageName = key.toString();
          final String tempFolderPath = '${directory.path}/$folderName';

          // Create the temporary folder if it doesn't exist
          await Directory(tempFolderPath).create(recursive: true);

          File tempFile;

          if (box.get(key) is Uint8List) {
            final Uint8List imageData = box.get(key) as Uint8List;
            final String tempFilePath = '$tempFolderPath/$imageName.png';
            tempFile = File(tempFilePath);
            await tempFile.writeAsBytes(imageData);

            String extension = tempFilePath.split('.').last.toLowerCase();

            zipEncoder.addFile(tempFile, '$folderName/$imageName.$extension');
          } else if (box.get(key) is String) {
            print('MK: saving video here...');
            final String videoPath = box.get(key) as String;
            tempFile = File(videoPath);
            bool isExist = await tempFile.exists();
            if (!isExist) continue;
            String extension = videoPath.split('.').last.toLowerCase();
            zipEncoder.addFile(tempFile, '$folderName/$imageName.$extension');
          }

          // Update progress
          exportedImages++;
          double progress = totalImages == 0 ? 0 : exportedImages / totalImages;

          // Update progress dialog
          Navigator.of(context).pop(); // Close existing dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ProgressDialog(
              progress: progress,
              message: AppLocalizations.of(context)!.exportingFiles + "....",
            ),
          );
        }

        // Close the box for the current folder
        await box.close();
      }

      // Close the zip file
      zipEncoder.close();

      // Hide the progress dialog
      Navigator.of(context).pop();

      print('MK: exportedImages...:0 $exportedImages');
      if (exportedImages > 0) {
        // Notify the user that the zip file has been saved
        FirebaseAnalytics.instance.logEvent(
          name: 'settings_exported_all_images_in_zip',
          parameters: <String, dynamic>{
            'activity': 'Navigating to Settings',
            'action': 'exported all files to zip',
          },
        );

        final XFile xFile = XFile(zipFilePath);
        await Share.shareXFiles([xFile], subject: AppLocalizations.of(context)!.exportFiles);
        // Share the zip file
        //Share.shareFiles([zipFilePath], text: 'Exported files');
      } else {
        FirebaseAnalytics.instance.logEvent(
          name: 'settings_exported_all_files',
          parameters: <String, dynamic>{
            'activity': 'Navigating to Settings',
            'action': 'exported failed to form zip',
          },
        );
      }
    } catch (error) {
      // Hide the progress dialog and show an error message
      Navigator.of(context).pop();
      print('Failed to export files: $error');
      FirebaseAnalytics.instance.logEvent(
        name: 'settings_exported_all_files',
        parameters: <String, dynamic>{
          'activity': 'Navigating to Settings',
          'action': 'exported failed to form zip',
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Setting Screen');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
        // Prevent default back button behavior
        return false;
      },
      child: Scaffold(
        //backgroundColor: Consts.BG_COLOR,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.07),
          child: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR,
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.setting,
              style: TextStyle(
                //color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                fontFamily: "Manrope",
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.height * 0.005),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(context)!.settings,
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Manrope",
                        ),
                      ),
                    ),
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.languages,
                    iconData: 'assets/settings/fi_8933942.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_languages',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to LanguagesScreen',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => languagesScreen(false),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.appIcon,
                    iconData: 'assets/settings/app-store (1) 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_app_icon',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to AppIconScreen',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppIcons(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.exportAllFiles,
                    iconData: 'assets/settings/download (1) 2.svg',
                    onTap: () async {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_export_all_files',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to ExportAllDialogue',
                          'action': 'Button Clicked',
                        },
                      );
                      final userChoice = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          elevation: 0,
                          backgroundColor: Theme.of(context).brightness == Brightness.light
                              ? Colors.white
                              : Consts.FG_COLOR,
                          title: Center(child: Text('Export Files')),
                          content: Text(
                              AppLocalizations.of(context)!.wouldYouLikeToSaveTheImagesToTheGalleryOrDownloadThemAsAZipFile + "?"),
                          actions: [
                            Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      // User chose to save images to the gallery
                                      Navigator.of(context).pop('gallery');
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all(
                                          Size(100, 40)),
                                      // Set button size
                                      backgroundColor:
                                      MaterialStateProperty.all(Consts
                                          .COLOR), // Set background color
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.gallery,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      // User chose to download the zip file
                                      Navigator.of(context).pop('zip');
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all(
                                          Size(100, 40)),
                                      // Set button size
                                      backgroundColor:
                                      MaterialStateProperty.all(Consts
                                          .COLOR), // Set background color
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.downloadZip,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ])
                          ],
                        ),
                      );
                      if (userChoice == 'gallery') {
                        FirebaseAnalytics.instance.logEvent(
                          name: 'settings_export_gallery',
                          parameters: <String, dynamic>{
                            'activity': 'exporting all images to gallery',
                            'action': 'Button Clicked',
                          },
                        );
                        await _exportAllImages(context);
                      } else if (userChoice == 'zip') {
                        FirebaseAnalytics.instance.logEvent(
                          name: 'settings_export_zip',
                          parameters: <String, dynamic>{
                            'activity': 'exporting all images to zip',
                            'action': 'Button Clicked',
                          },
                        );
                        await _exportAllFiles(context);
                      }
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.security,
                    iconData: 'assets/settings/shield 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_security',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to SEcurityScreen',
                          'action': 'Button Clicked',
                        },
                      );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const ChangePasswordPage(),
                      //   ),
                      // );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.theme,
                    iconData: 'assets/settings/theme 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_theme',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to ThemeDialogue',
                          'action': 'Button Clicked',
                        },
                      );
                      Utils(context).showCustomDialog(
                        child: _themetileWidget(
                          context: context,
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.height * 0.01),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(context)!.membership,
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Manrope",
                        ),
                      ),
                    ),
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle:AppLocalizations.of(context)!.restorePurchase,
                    iconData: 'assets/settings/rotate 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_restore_purchase',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to PREMIUMscreen',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.02,
                        vertical: size.height * 0.01),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        AppLocalizations.of(context)!.others,
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Manrope",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.shareThisApp,
                    iconData: 'assets/settings/share (1) 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_share_app',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to shareapp',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.privacyPolicy,
                    iconData: 'assets/settings/padlock 3.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_privacy_policy',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to Privacy policy',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.rateOurApp,
                    iconData: 'assets/settings/star 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_rate_app',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to Rate Our App',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.appVersion,
                    iconData: 'assets/settings/version 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_app_version',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to AppVersion',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle: AppLocalizations.of(context)!.contactUs,
                    iconData: 'assets/settings/email 1.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_contact_us',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to contact us',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildListtile({
    required BuildContext context, // Add BuildContext context
    required String iconData,
    required String tiletitle,
    required Function onTap,
  }) {
    return Card(
      color: Theme.of(context).brightness == Brightness.light
          ? Color(0xFFF5F5F5) // Color for light theme
          : Consts.FG_COLOR,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
        onTap: () {
          onTap();
        },
        child: ListTile(
          leading: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Theme.of(context).brightness == Brightness.light
                  ? Colors.black // Color for light theme
                  : Colors.white, // Color for dark theme
              BlendMode.srcIn,
            ),
            child: SvgPicture.asset(iconData),
          ),
          title: Text(tiletitle),
        ),
      ),
    );
  }

  _themetileWidget({required BuildContext context}) {
    return Consumer<ThemeProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              AppLocalizations.of(context)!.selectTheme,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Manrope",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectionButtonWidget(
                  buttontitle: AppLocalizations.of(context)!.systemTheme,
                  iconCondition: provider.themeMode == ThemeMode.system,
                  ontap: () {
                    provider.themeMode = ThemeMode.system;
                  },
                ),
                const Divider(
                  height: 0,
                ),
                SelectionButtonWidget(
                  iconCondition: provider.themeMode == ThemeMode.light,
                  buttontitle: AppLocalizations.of(context)!.lightTheme,
                  ontap: () {
                    provider.themeMode = ThemeMode.light;
                  },
                ),
                const Divider(
                  height: 0,
                ),
                SelectionButtonWidget(
                  iconCondition: provider.themeMode == ThemeMode.dark,
                  buttontitle: AppLocalizations.of(context)!.darkTheme,
                  ontap: () {
                    provider.themeMode = ThemeMode.dark;
                  },
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class ProgressDialog extends StatefulWidget {
  final double progress;
  final String message;

  ProgressDialog({required this.progress, required this.message});

  @override
  State<ProgressDialog> createState() => _ProgressDialogState();
}

class _ProgressDialogState extends State<ProgressDialog> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  // Function to handle navigation when progress reaches 100%
  void _handleNavigation() {
    if (widget.progress == 1.0) {
      // Close the current dialog
      Navigator.of(context).pop();

      // Show the continue dialog asynchronously after the build is complete
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Column(
              children: [
                SvgPicture.asset('assets/Group 21149.svg'),
                SizedBox(
                  height: 8,
                ),
                Text(
                  AppLocalizations.of(context)!.exportedSuccessfully + "!",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: "Manrope",
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            actions: [
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
                  AppLocalizations.of(context)!.valueContinue,
                  style: TextStyle(color: Colors.white, fontFamily: "Manrope",fontSize: 16),
                ),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: AlertDialog(
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Consts.FG_COLOR,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: widget.progress,
                  ),
                ),
                Text(
                  '${(widget.progress * 100).toStringAsFixed(0)}%',
                  // Format percentage as an integer
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Manrope",
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(widget.message),
          ],
        ),
      ),
    );
  }
}
