import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../consts/consts.dart';
import '../provider/onboardprovider.dart';
import '../utils/utils.dart';
import '../widgets/custombutton.dart';
import 'auth/register.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'languages.dart';

class OnBoardingSceen extends StatefulWidget {
  const OnBoardingSceen({super.key});

  @override
  State<OnBoardingSceen> createState() => _OnBoardingSceenState();
}

class _OnBoardingSceenState extends State<OnBoardingSceen> {
  PageController _controller = PageController();
  @override
  void initState() {
    _controller = PageController(
      initialPage: 0,
    );

    setDefaultSettings();
    super.initState();
  }

  void setDefaultSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('firstLaunch') ?? true;

    if (isFirstLaunch) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => languagesScreen(isFirstLaunch)));
      prefs.setBool('firstLaunch', false);
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Onboarding Screens');
    List<OnBoardingContent> contents = [
      OnBoardingContent(
        image: 'assets/Intro 1.svg',
        title: AppLocalizations.of(context)!.areYouExhausted +"?",
        description: AppLocalizations.of(context)!.doNotWaitUntilYourPrivacyIs + '\n'+AppLocalizations.of(context)!.compromised +'-'+ AppLocalizations.of(context)!.takeActionNow +'!',
      ),
      OnBoardingContent(
        image: 'assets/Intro 2.svg',
        title: AppLocalizations.of(context)!.secureYourData,
        description: AppLocalizations.of(context)!.theAppRequiresAPasswordTo +'\n'+AppLocalizations.of(context)!.accessYourStoredMediaFiles,
      ),
      OnBoardingContent(
        image: 'assets/Intro 3.svg',
        title: AppLocalizations.of(context)!.hidePhotosAndVideos,
        description: AppLocalizations.of(context)!.hideYourCherishedPhotosAnd +'\n'+AppLocalizations.of(context)!.videosEffortlessly +"!",
      ),
    ];
    return Consumer<OnBoardingProvider>(builder: (context, provider, child) {
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
        child: Scaffold(
          //backgroundColor: Consts.BG_COLOR,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (int index) {
                      provider.currentIndex = index;
                    },
                    itemCount: contents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.07,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: size.height * 0.2,
                            ),
                            SvgPicture.asset(
                              contents[index].image,
                              height: size.height * 0.3,
                            ),
                            SizedBox(
                              height: size.height * 0.07,
                            ),
                            Text(
                              contents[index].title,
                              style: const TextStyle(
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                //color: Colors.white
                              ),
                            ),
                            SizedBox(
                              height: size.height * 0.01,
                            ),
                            Text(
                              contents[index].description,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "Manrope",
                                //color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: CustomButton(
                    ontap: () {
                      FirebaseAnalytics.instance.logEvent(
                      name: 'onboarding',
                      parameters: <String, dynamic>{
                        'activity': 'navigated to register',
                      },
                    );
                      if (provider.currentIndex == contents.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      }
                      _controller.nextPage(
                        duration: const Duration(
                          microseconds: 100,
                        ),
                        curve: Curves.bounceIn,
                      );
                    },
                    buttontext: provider.currentIndex == 0
                        ? AppLocalizations.of(context)!.yes
                        : AppLocalizations.of(context)!.valueContinue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      contents.length,
                          (index) => buildDots(
                        context: context,
                        size: size,
                        index: index,
                        currentIndex: provider.currentIndex,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget buildDots({
    required int currentIndex,
    required int index,
    required BuildContext context,
    required Size size,
  }) {
    Color dotColor = currentIndex == index
        ? Consts.COLOR // Selected dot color
        : Theme.of(context).brightness == Brightness.light
    ?Colors.grey.withOpacity(0.5)
    :Colors.white; // Unselected dot color

    return Container(
      height: size.height * 0.007,
      width: currentIndex == index ? size.width * 0.07 : size.width * 0.07,
      margin: const EdgeInsets.only(
        right: 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
        color: dotColor,
      ),
    );
  }
}

class OnBoardingContent {
  String image;
  String title;
  String description;
  OnBoardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}


