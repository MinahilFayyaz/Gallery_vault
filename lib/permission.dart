import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vault/screens/gallery.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'consts/consts.dart';
import 'screens/homepage.dart';
import 'widgets/custombutton.dart';

class Permission extends StatefulWidget {
  const Permission(
      {Key? key, this.folderName, this.successCallback = null})
      : super(key: key);

  final String? folderName;
  final dynamic successCallback;

  @override
  State<Permission> createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  final Color fgcolor = Consts.FG_COLOR;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // First Container: Top half with BG_COLOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height / 2,
            child: Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white // Color for light theme
                  : Consts.BG_COLOR,
            ),
          ),
          // Second Container: Bottom half with FG_COLOR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size.height / 2,
            child: Container(
              color: Theme.of(context).brightness == Brightness.light
                  ? Color(0xFFF5F5F5) // Color for light theme
                  : Consts.BG_COLOR,
            ),
          ),
          // Content in the middle
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                // Wrap the image in an AspectRatio widget
                child: Image.asset(
                  'assets/Frame 37366.png',
                  fit: BoxFit.cover, // Adjusts the image to cover the whole area
                ),
                // Get the height of the screen dynamically using MediaQuery
                height: MediaQuery.of(context).size.height * 0.35, // Adjust this factor as needed
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.05,
                  horizontal: size.width * 0.05,
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.allowAccessToTheLocker +'\n'+
                        AppLocalizations.of(context)!.enablesUsersToSecurelyStore +"\n"+
                        AppLocalizations.of(context)!.andManageTheirPrivatePhotos +"\n"+
                        AppLocalizations.of(context)!.withinAProtectedEnvironment+".",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: size.height * 0.08,
                  horizontal: size.width * 0.05,
                ),
                child: CustomButton(
                  ontap: () async {
                    // if (widget.folderName!.isNotEmpty) {
                      await GalleryService.doneFirstLaunch();
                      Navigator.pop(context);
                      if (widget.successCallback != null) {
                        widget.successCallback();
                      }
                  },
                  buttontext: AppLocalizations.of(context)!.gotIt,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
