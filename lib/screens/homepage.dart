import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/screens/gallery.dart';
import 'package:vault/screens/imagepreview.dart';
import 'package:vault/screens/mediapreview.dart';
import 'package:vault/screens/settings/premium.dart';

import '../consts/consts.dart';
import '../permission.dart';
import '../utils/utils.dart';
import 'album.dart';
import 'settings/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> folderNames = []; // List to hold folder names
  List<File> selectedImages = [];
  List<String> selectedImagePaths = [];

  //List<File> folderContents = []; // Define and initialize folderContents list
  Map<String, List<File>> folderContents = {};

  void _copyImageToFolder(File image, String folderName) {
    print('Copying image to folder: $folderName');

    setState(() {
      // Add the selected image to the specified folder
      //folderContents.add(image);

      if (!folderContents.containsKey(folderName)) {
        folderContents[folderName] = [];
      }
      folderContents[folderName]!.add(image);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FolderContentsPage(
            folderName: folderName,
            folderContents: folderContents[folderName] != null
                ? folderContents[folderName]!
                : [],
            updateFolderContents: (updatedContents) =>
                _updateFolderContents(folderName, updatedContents),
          ),
        ),
      );

      print('Navigated to FolderContentsPage');
    });
  }

  void _updateFolderContents(String folderName, List<File> updatedContents) {
    setState(() {
      // Update the folder contents for the specified folder name
      folderContents[folderName] = updatedContents;
    });
  }

  // Method to load folder names from shared preferences
  Future<void> _loadFolderNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    print('Loading folder names and selected image paths');
    List<String>? savedFolderNames = prefs.getStringList('folderNames');
    //List<String>? savedImagePaths = prefs.getStringList('selectedImagePaths');

    var box = await Hive.openBox('selected_images');
    List<String>? savedImagePaths = box.get('images')?.cast<String>();
    setState(() {
      // Check if savedFolderNames is null or empty, if so, add default folders
      if (savedFolderNames == null || savedFolderNames.isEmpty) {
        folderNames.addAll(["Home"]);
        _saveFolderNames();

        print(
            'Loading folder set state names and selected image paths'); // Save default folders to shared preferences
      } else {
        folderNames = savedFolderNames;
      }
      if (savedImagePaths != null) {
        selectedImagePaths = savedImagePaths;
        // Load selected images from their paths
        selectedImages = selectedImagePaths.map((path) => File(path)).toList();
      }
    });
  }

  // Method to save folder names to shared preferences
  Future<void> _saveFolderNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> imagePaths =
        selectedImages.map((image) => image.path).toList();
    print('Image paths to save: $imagePaths');
    await prefs.setStringList('folderNames', folderNames);
    await prefs.setStringList('selectedImagePaths', imagePaths);
    var box = await Hive.openBox('selected_images');
    await box.put('images', imagePaths);
  }

  void _navigateToFolderContents(String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderContentsPage(
          folderName: folderName,
          // isFirstAddButtonClick: isFirstAddButtonClick,
          folderContents: folderContents[folderName] != null
              ? folderContents[folderName]!
              : [],
          updateFolderContents: (updatedContents) =>
              _updateFolderContents(folderName, updatedContents),
        ),
      ),
    );
  }

  // bool isFirstAddButtonClick = true;

// Method to check if it's the app's first launch

  @override
  void initState() {
    super.initState();
    // Load folder names from shared preferences when the widget initializes
    _loadFolderNames();
    //GalleryService.removeFirstLaunch();///Temporary
    // isFirstAppLaunch().then((isFirstLaunch) {
    //   setState(() {
    //     isFirstAddButtonClick = isFirstLaunch;
    //   });
    // });
    // _saveIsFirstAddButtonClick(isFirstAddButtonClick);
  }

  // Future<void> _saveIsFirstAddButtonClick(bool isFirstButtonClick) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isFirstAddButtonClick', isFirstAddButtonClick);
  // }

  Future<void> doneCallback() async {
    final pickedFiles = await ImagePicker().pickMultipleMedia();
    for (final pickedFile in pickedFiles) {
      selectedImages.add(File(pickedFile.path));
    }
    setState(() {
      _saveFolderNames();
    });

    FirebaseAnalytics.instance.logEvent(
      name: 'home_image_picker_from_gallery_clicked',
      parameters: <String, dynamic>{
        'activity': 'Navigating to Gallery',
        'action': 'Add Button clicked',
      },
    );
  }

  void _updateImagesList(File removedImage) {
    setState(() {
      selectedImages.remove(removedImage);
      // Optionally, you can trigger any other necessary updates here
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'HomeScreen');

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
      child: Scaffold(
        //backgroundColor: Consts.BG_COLOR,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(screenHeight * 0.07),
          child: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR,
            leading: Padding(
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsPage(
                              totalAlbums: folderNames.length,
                              folderNames: folderNames)));
                  FirebaseAnalytics.instance.logEvent(
                    name: 'home_settings_clicked',
                    parameters: <String, dynamic>{
                      'activity': 'Navigating to Settings',
                      'action': 'Button clicked',
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Color(0xFFF5F5F5) // Color for light theme
                        : Color(0xFF4A4B56),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Icon(
                    Icons.settings, // You can use any icon here
                    size: screenWidth * 0.06, // Adjust the size as needed
                    //color: Colors.white, // Icon color
                  ),
                ),
              ),
            ),
            title: Text(
              //AppLocalizations.of(context)!.share,
              AppLocalizations.of(context)!.locker,
              style: TextStyle(
                //color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                fontFamily: "Manrope",
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'home_premium_clicked',
                    parameters: <String, dynamic>{
                      'activity': 'Navigating to Premium',
                      'action': 'Button clicked',
                    },
                  );
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PremiumScreen()));
                },
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Theme.of(context).brightness == Brightness.light
                      ? SvgPicture.asset('assets/Frame 81-2.svg')
                      : SvgPicture.asset(
                          "assets/Frame 81.svg",
                        ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.albums,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          '(${folderNames.length} ' +
                              AppLocalizations.of(context)!.albums +
                              ")",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF363C54),
                            fontFamily: "Manrope",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        spacing: screenWidth * 0.02,
                        // Add spacing between the containers
                        runSpacing: screenHeight * 0.01,
                        // Add spacing between the rows
                        children: [
                          GestureDetector(
                            onTap: () async {
                              String? folderName =
                                  await _showAddFolderDialog(context);
                              if (folderName != null && folderName.isNotEmpty) {
                                setState(() {
                                  folderNames.add(
                                      folderName); // Add the new folder to the list
                                  _saveFolderNames();
                                });
                              }
                              FirebaseAnalytics.instance.logEvent(
                                name: 'home_new_album_added',
                                parameters: <String, dynamic>{
                                  'activity':
                                      'Navigating to new album dialogue',
                                  'action': 'Button clicked',
                                },
                              );
                            },
                            child: Container(
                              height: screenHeight * 0.13,
                              width: screenWidth * 0.29,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Color(0xFFF5F5F5) // Color for light theme
                                    : Consts.FG_COLOR,
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.02),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ),
                          ),
                          // Dynamically generate containers for each folder name
                          for (String folderName in folderNames)
                            GestureDetector(
                              onTap: () {
                                _navigateToFolderContents(folderName);
                                FirebaseAnalytics.instance.logEvent(
                                  name: 'home_album_clicked',
                                  parameters: <String, dynamic>{
                                    'activity': 'Navigating to album',
                                    'action': 'Album clicked',
                                  },
                                );
                              },
                              child: Container(
                                height: screenHeight * 0.13,
                                width: screenWidth * 0.29,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Color(
                                          0xFFF5F5F5) // Color for light theme
                                      : Consts.FG_COLOR,
                                  borderRadius: BorderRadius.circular(
                                      screenHeight * 0.02),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                          'assets/46 Open File, Document, Folder.svg'),
                                      SizedBox(height: screenHeight * 0.01),
                                      Text(
                                        folderName,
                                        style: TextStyle(
                                          //color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: "Manrope",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.media,
                          style: TextStyle(
                            fontSize: screenWidth * 0.05,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Manrope",
                          ),
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          '(${selectedImages.length} ' +
                              AppLocalizations.of(context)!.media +
                              ")",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Color(0xFF363C54),
                            fontFamily: "Manrope",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        spacing: screenWidth * 0.02,
                        // Add spacing between the containers
                        runSpacing: screenHeight * 0.01,
                        // Add spacing between the rows
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // Check if it's the first launch and if the "Add" button is clicked before opening any album
                              if (await GalleryService.isFirstAppLaunch()) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Permission(
                                      folderName: '',
                                      successCallback: () async {
                                        doneCallback();
                                      },
                                    ),
                                  ),
                                );
                              } else {
                                doneCallback();
                              }
                            },
                            child: Container(
                              height: screenHeight * 0.13,
                              width: screenWidth * 0.29,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Color(0xFFF5F5F5) // Color for light theme
                                    : Consts.FG_COLOR,
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.02),
                              ),
                              child: Icon(
                                Icons.add,
                                size: 30,
                              ),
                            ),
                          ),
                          ...List.generate(selectedImages.length, (index) {
                            String extension = selectedImages[index]
                                .path
                                .split('.')
                                .last
                                .toLowerCase();
                            if (extension == 'mp4' || extension == 'mov') {
                              // It's a video file

                              return Container(
                                height: screenHeight * 0.13,
                                width: screenWidth * 0.29,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      screenHeight * 0.02),
                                  child: FutureBuilder<Uint8List?>(
                                    future:
                                        GalleryService.generateVideoThumbnail(
                                            selectedImages[index].path),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Container(
                                          color: Colors.grey,
                                        );
                                      } else if (snapshot.hasData) {
                                        return GestureDetector(
                                          onTap: () {
                                            String imageName =
                                                selectedImages[index]
                                                    .path
                                                    .split('/')
                                                    .last;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    MediaPreview(
                                                  imageFile:
                                                      selectedImages[index],
                                                  imageName: imageName,
                                                  // Pass the image name here
                                                  folderName: '',
                                                  onImageRemoved:
                                                      _updateImagesList, // Pass the folder name here
                                                ),
                                              ),
                                            );
                                          },
                                          onLongPress: () {
                                            _showImageOptionsBottomSheet(
                                                context, selectedImages[index]);
                                          },
                                          child: Stack(
                                            alignment: Alignment.center,
                                            fit: StackFit.loose,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Image.memory(
                                                        snapshot.data!,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Icon(
                                                Icons.play_arrow,
                                                color: Colors.white,
                                                size: 30,
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  ),
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () {
                                  String imageName = selectedImages[index]
                                      .path
                                      .split('/')
                                      .last;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MediaPreview(
                                        imageFile: selectedImages[index],
                                        imageName: imageName,
                                        // Pass the image name here
                                        folderName: '',
                                        onImageRemoved: _updateImagesList,
                                        // Pass the folder name here
                                      ),
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  _showImageOptionsBottomSheet(
                                      context, selectedImages[index]);
                                },
                                child: Container(
                                  height: screenHeight * 0.13,
                                  width: screenWidth * 0.29,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.02),
                                    child: Image.file(
                                      selectedImages[index],
                                      fit: BoxFit
                                          .cover, // Fit the image to cover the container
                                    ),
                                  ),
                                ),
                              );
                            }
                          }).toList().reversed,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAlbumSelectionDialog(
      BuildContext context, File image) async {
    return showModalBottomSheet(
      elevation: 0,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Consts.FG_COLOR,
      context: context,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Theme.of(context).brightness == Brightness.light
                        ? ColorFiltered(
                            colorFilter:
                                ColorFilter.mode(Colors.black, BlendMode.srcIn),
                            child: SvgPicture.asset(
                                'assets/Home Indicator.svg')) // Color for light theme
                        : SvgPicture.asset('assets/Home Indicator.svg')),
                SizedBox(
                  height: screenHeight * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.addToAlbum,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Color(0xFF666666) // Color for light theme
                                    : Color(0xFF999999),
                            fontSize: 14,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  alignment: Alignment.topLeft,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    runAlignment: WrapAlignment.start,
                    spacing: screenWidth * 0.02,
                    runSpacing: screenHeight * 0.01,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          String? folderName =
                              await _showAddFolderDialog(context);
                          if (folderName != null && folderName.isNotEmpty) {
                            setState(() {
                              folderNames.add(folderName);
                              _saveFolderNames();
                              // Copy the image to the selected folder
                              _copyImageToFolder(image, folderName);
                            });
                          }
                        },
                        child: Container(
                          height: screenHeight * 0.13,
                          width: screenWidth * 0.29,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Color(0xFFF5F5F5) // Color for light theme
                                    : Consts.BG_COLOR,
                            borderRadius:
                                BorderRadius.circular(screenHeight * 0.02),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 30,
                          ),
                        ),
                      ),
                      // Dynamically generate containers for each folder name
                      for (String folderName in folderNames)
                        GestureDetector(
                          onTap: () {
                            // Copy the image to the selected folder
                            _copyImageToFolder(image, folderName);
                            // Navigate to the folder contents page
                            //_navigateToFolderContents(folderName);
                          },
                          child: Container(
                            height: screenHeight * 0.13,
                            width: screenWidth * 0.29,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Color(0xFFF5F5F5) // Color for light theme
                                  : Consts.BG_COLOR,
                              borderRadius:
                                  BorderRadius.circular(screenHeight * 0.02),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                      'assets/46 Open File, Document, Folder.svg'),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    folderName,
                                    style: TextStyle(
                                      //color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImageOptionsBottomSheet(
      BuildContext context, File image) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final double paddingValue = screenWidth * 0.04;
    final double iconSize = screenWidth * 0.06;

    await showModalBottomSheet(
      context: context,
      elevation: 0,
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Consts.FG_COLOR,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR, // Set background color
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(
                    screenWidth * 0.05)), // Add rounded corners at the top
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, paddingValue * 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Theme.of(context).brightness == Brightness.light
                        ? ColorFiltered(
                            colorFilter:
                                ColorFilter.mode(Colors.black, BlendMode.srcIn),
                            child: SvgPicture.asset(
                                'assets/image-gallery 1.svg')) // Color for light theme
                        : SvgPicture.asset('assets/image-gallery 1.svg'),
                  ),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      AppLocalizations.of(context)!.addToAlbum,
                      style: TextStyle(
                          //color: Colors.white,
                          ),
                    ),
                  ),
                  onTap: () {
                    // Add logic to add image to album
                    _showAlbumSelectionDialog(context, image);
                  },
                ),
                ListTile(
                  leading: Padding(
                      padding: EdgeInsets.only(left: paddingValue),
                      child: Theme.of(context).brightness == Brightness.light
                          ? ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                  Colors.black, BlendMode.srcIn),
                              child:
                                  SvgPicture.asset('assets/download (1) 1.svg'))
                          : SvgPicture.asset('assets/download (1) 1.svg')),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      AppLocalizations.of(context)!.saveToPhoto,
                      style: TextStyle(
                          //color: Colors.white,
                          ),
                    ),
                  ),
                  onTap: () async {
                    _showConfirmationOutDialog(context, image);
                  },
                ),
                ListTile(
                  leading: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Theme.of(context).brightness == Brightness.light
                  //       ? ColorFiltered(
                  //           colorFilter:
                  //               ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  //           child: SvgPicture.asset('assets/delete 1.svg'))
                  //       : SvgPicture.asset('assets/delete 1.svg'),
                  // ),
        ?ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            Colors.black, BlendMode.srcIn),
                        child:
                        SvgPicture.asset('assets/delete 1.svg'))
                        : SvgPicture.asset('assets/delete 1.svg')),
                  title: Padding(
                    padding: EdgeInsets.only(left: paddingValue),
                    child: Text(
                      AppLocalizations.of(context)!.deleteMedia,
                      style: TextStyle(
                          //color: Colors.white,
                          ),
                    ),
                  ),
                  onTap: () {
                    _showConfirmationDialog(context, image);
                    // setState(() {
                    //   selectedImages.remove(image);
                    //   _saveFolderNames(); // Update shared preferences
                    // });
                    // Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showConfirmationDialog(BuildContext context, image) {
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
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
                                    : Color(0xFFFFFFFF).withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
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
                      setState(() {
                        selectedImages.remove(image);
                        _saveFolderNames(); // Update shared preferences
                      });
                      Navigator.pop(context);
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
                    child: Text(
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

  void _showConfirmationOutDialog(BuildContext context, image) {
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                                    : Color(0xFFFFFFFF).withOpacity(0.5),
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
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
                                  : Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final result = await saveImageToGallery(image);
                      Navigator.pop(context);
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

  Future<bool> saveImageToGallery(File image) async {
    try {
      // Save the image to the device's photo gallery
      final result = await ImageGallerySaver.saveFile(image.path);
      return result['isSuccess'];
    } catch (e) {
      print('Error saving image to gallery: $e');
      return false;
    }
  }

  // Method to show the add folder dialog
  Future<String?> _showAddFolderDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0, // No elevation
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white // Color for light theme
              : Consts.FG_COLOR, // White background color
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.createNewAlbum,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Manrope",
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Center(
                  child: Text(
                    AppLocalizations.of(context)!.enterANameForThisAlbum,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Manrope",
                      color: Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF222222).withOpacity(0.5)
                          : Color(0xFFFFFFFF).withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Use Focus widget to request focus for TextField
                Focus(
                  child: TextField(
                    controller: controller,
                    autofocus: true, // Automatically request focus
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.title,
                      filled: true,
                      // Fill the box with the fill color
                      fillColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Color(0xFFF5F5F5) // Color for light theme
                              : Color(0xFF0C0B14),
                      // Box fill color
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Consts.COLOR),
                        // Border color
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Cancel button
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: Size(100, 40),
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xFFF5F5F5) // Color for light theme
                                : Color(0xFF363C54), // Light theme button color
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
                        Navigator.of(context)
                            .pop(controller.text); // Confirm button
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(color: Consts.COLOR),
                        ),
                        minimumSize: Size(100, 40),
                        backgroundColor: Consts.COLOR, // Custom color
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
