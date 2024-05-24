import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../consts/consts.dart';
import '../auth/chagepassword.dart';
import '../auth/changeemail.dart';

class Security extends StatelessWidget {
  const Security({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Security Screen');

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.07),
          child: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR,
            centerTitle: true,
            title: Text(
              AppLocalizations.of(context)!.security,
              style: TextStyle(
                //color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                fontFamily: 'GilroyBold', // Apply Gilroy font family
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
                        AppLocalizations.of(context)!.security,
                        style: TextStyle(
                          //color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'GilroyBold', // Apply Gilroy font family
                        ),
                      ),
                    ),
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle:  AppLocalizations.of(context)!.changePassword,
                    iconData: 'assets/change password.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_change_passcode',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to LanguagesScreen',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                  _buildListtile(
                    context: context,
                    tiletitle:  AppLocalizations.of(context)!.changeEmail,
                    iconData: 'assets/change email.svg',
                    onTap: () {
                      FirebaseAnalytics.instance.logEvent(
                        name: 'settings_change_email',
                        parameters: <String, dynamic>{
                          'activity': 'Navigating to LanguagesScreen',
                          'action': 'Button Clicked',
                        },
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeEmailPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: size.height * 0.0001,
                  ),
                ],
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
  }
