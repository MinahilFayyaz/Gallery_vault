import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/screens/languages.dart';
import '../provider/onboardprovider.dart';
import '../utils/utils.dart';
import '../widgets/custombutton.dart';
import 'auth/login.dart';
import 'onboardingpage.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<OnBoardingProvider>(
      builder: (
          context,
          value,
          child,
          ) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.07),
                    Image.asset(
                      'assets/Group 42161 (2).png',
                      height: size.height * 0.5,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Text(
                            AppLocalizations.of(context)!.galleryVault,
                            style: const TextStyle(
                              fontFamily: "Manrope",
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          Text(
                            AppLocalizations.of(context)!.safeBoxIsThePhotoVaultAppForProtectingPrivatePhotoAndVideo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              fontFamily: "Manrope",
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: size.height * 0.05),
                          CustomButton(
                            ontap: () {
                              FirebaseAnalytics.instance.logEvent(
                                name: 'SplashScreen_get_started',
                                parameters: <String, dynamic>{
                                  'activity': 'Navigating to Onboarding/Login',
                                },
                              );
                              final onBoardingProvider = Provider.of<OnBoardingProvider>(context, listen: false);
                              onBoardingProvider.checkOnBoardingStatus();
                              final isOnBoardingComplete = onBoardingProvider.isBoardingCompleate;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  isOnBoardingComplete ? const LoginPage() : const OnBoardingSceen(),
                                ),
                              );
                            },
                            buttontext: AppLocalizations.of(context)!.getStarted,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
