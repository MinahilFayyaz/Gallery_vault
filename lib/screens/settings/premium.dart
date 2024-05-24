import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../consts/consts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Premium Screen');
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Consts.BG_COLOR,
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: size.height  * 0.4, // Set the desired height
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/image 16.png'),
                      fit: BoxFit.cover, // Cover the entire container with the image
                    ),
                  ),
                ),
                Padding(
                  padding:EdgeInsets.all(size.width * 0.05),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: SvgPicture.asset('assets/cancel.svg',
                        width: size.width * 0.06,
                        height: size.width * 0.06,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.only(top : size.height * 0.28),
                  child: Align(
                    alignment: Alignment.bottomLeft, // Align to the bottom center of the image
                    child: Container(
                      width: double.infinity, // Stretch to the full width
                      padding: EdgeInsets.symmetric(horizontal:size.width * 0.05), // Optional padding for aesthetics
                      color: Colors.transparent, // Transparent background
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.getFullAccess,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              fontFamily: "Manrope",
                              color: Color(0xFFFFC600), // Set text color
                            ),// Center the text
                          ),
                          SizedBox(height: 8), // Optional spacing between title and subtitle
                          Text(
                            AppLocalizations.of(context)!.galleryVault +" - "+ AppLocalizations.of(context)!.photoVault,
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "Manrope",
                              fontWeight: FontWeight.w700,
                              color: Colors.white, // Set text color
                            ),// Center the text
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.03,
              ),
              child: Padding(
                padding: EdgeInsets.only(left: size.width * 0.05,
                right: size.width * 0.05,
                bottom: size.width * 0.05),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset('assets/Frame.svg'),
                          SizedBox(width: size.width * 0.05),
                          Text(
                            "100% "+AppLocalizations.of(context)!.adsFree,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "Manrope",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset('assets/Frame.svg'),
                          SizedBox(width: size.width * 0.05),
                          Text(
                            AppLocalizations.of(context)!.uploadUnlimitedPhotoAndVideos,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Manrope",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0,
                          right: 8.0, top: 8.0, bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset('assets/Frame.svg'),
                          SizedBox(width: size.width * 0.05),
                          Text(
                            AppLocalizations.of(context)!.premiumSupport,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Manrope",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: GestureDetector(
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'premium_purchase',
                    parameters: <String, dynamic>{
                      'activity': 'Continuing with one time purchase',
                      'action': 'Button Clicked',
                    },
                  );
                },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.oneTimePurchase + ' / Rs1500.00',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Manrope",
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.015,),
            Text(
              AppLocalizations.of(context)!.aOneTimePurchaseToEnjoyAllThePremiumFeatures +"\n"+AppLocalizations.of(context)!.withoutTheWorryOfMonthlySubscriptions,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.699999988079071),
                fontSize: 12,
                fontFamily: "Manrope",
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: size.height * 0.027,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
              child: GestureDetector(
                onTap: () {
                  FirebaseAnalytics.instance.logEvent(
                    name: 'premium_continue_without_ads',
                    parameters: <String, dynamic>{
                      'activity': 'Continuing without ads',
                      'action': 'Button Clicked',
                    },
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.90, // Use MediaQuery for width
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-1, 0.00),
                      end: Alignment(1.00, 0),
                      colors: [Color(0xFFFFB700), Color(0xFFFF4C00)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context)!.valueContinue,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: "Manrope",
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SvgPicture.asset('assets/arrow_back.svg'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: size.height * 0.02,),
            GestureDetector(
              onTap: (){
                FirebaseAnalytics.instance.logEvent(
                  name: 'premium_continue_with_ads',
                  parameters: <String, dynamic>{
                    'activity': 'Continuing with ads',
                    'action': 'Button Clicked',
                  },
                );
              },
              child: Padding(padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05
              ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.continueWithAds,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      fontFamily: "Manrope",
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
