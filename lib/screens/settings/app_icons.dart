import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import '../../consts/consts.dart';
import '../../widgets/custombutton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppIcons extends StatefulWidget {
  const AppIcons({Key? key}) : super(key: key);

  @override
  _AppIconsState createState() => _AppIconsState();
}

class _AppIconsState extends State<AppIcons> {
  int selectedIconIndex = 0;
  List<String> iconNames = ['icon1', 'icon2', 'icon3', 'icon4', 'icon5', 'icon6', 'icon7', 'icon8'];
  List<String> imageFiles = [
    'assets/icon.png',
    'assets/Rectangle 4921.png',
    'assets/Rectangle 4921-2.png',
    'assets/Rectangle 4922.png',
    'assets/Rectangle 4923.png',
    'assets/Rectangle 4924-2.png',
    'assets/Rectangle 4924.png',
    'assets/Rectangle 4925.png'
  ];

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'App Icons Screen');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Color(0xFFFFFFFF)
            : Consts.FG_COLOR,
        title: Text(
          AppLocalizations.of(context)!.appIcon,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontFamily: "Manrope",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
        child: Column(
          children: [
            Center(
              child: Text(
                AppLocalizations.of(context)!.tryANewLookForTheAppToReflectTheTypesOfPhotosYouAreStoring,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "Manrope",
                ),
              ),
            ),
            // Row of app icons
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(iconNames.length ~/ 2, (index) {
                      return buildIconTile(index);
                    }),
                  ),
                  SizedBox(height: 10), // Add some space between rows
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(iconNames.length ~/ 2, (index) {
                      return buildIconTile(index + iconNames.length ~/ 2);
                    }),
                  ),
                ],
              ),
            ),

            // Spacer to push the button to the bottom
            Expanded(child: SizedBox()),
            // Apply button at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 47.0),
              child: CustomButton(
                ontap: () => changeAppIcon(),
                buttontext: AppLocalizations.of(context)!.apply,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIconTile(int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedIconIndex = index),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Image.asset(
          imageFiles[index],
          width: 60,
          height: 60,
        ),
        decoration: BoxDecoration(
          border: selectedIconIndex == index
              ? Border.all(color: Consts.COLOR, width: 2)
              : Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> changeAppIcon() async {
    try {
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        await FlutterDynamicIcon.setAlternateIconName(iconNames[selectedIconIndex]);
        debugPrint("App icon change successful");
        FirebaseAnalytics.instance.logEvent(
          name: 'appicon_apply',
          parameters: <String, dynamic>{
            'activity': 'Apps Icon changed',
            'action': 'Button clicked',
          },
        );
      }
    } catch (e) {
      debugPrint("Exception: ${e.toString()}");
    }
  }
}
