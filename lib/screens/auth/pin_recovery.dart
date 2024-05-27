import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:vault/screens/auth/register.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../provider/onboardprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/custombutton.dart';
import '../homepage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PinRecoveryPage extends StatefulWidget {
  const PinRecoveryPage({Key? key}) : super(key: key);

  @override
  State<PinRecoveryPage> createState() => _PinRecoveryPageState();
}

class _PinRecoveryPageState extends State<PinRecoveryPage> {
  final emailController = TextEditingController();
  final focus = FocusNode();
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Pin Recovery Screen');


    return Consumer<AuthProvider>(
      builder: (BuildContext context, provider, Widget? child) {
        return WillPopScope(
          onWillPop: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
            return Future.value(false);
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).brightness == Brightness.light
                  ? Color(0xFFFFFFFF) // Color for light theme
                  : Consts.FG_COLOR,
              title: Text(
                AppLocalizations.of(context)!.step + " 3/3",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  fontFamily: "Manrope"
                  //color: Colors.white,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.07,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Text(
                        AppLocalizations.of(context)!.pinRecovery,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          fontFamily: "Manrope"
                          //color: Colors.white,
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.simplyEnterYourEmailAddressAndWeWillGuideyouThroughTheProcessOfResettingPinSecurely,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                              fontFamily: "Manrope"
                            //color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                      TextFormField(
                        focusNode: focus,
                        //obscureText: provider.isObsecured,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            print('Please enter your email');
                            return 'Please enter your email';
                          }
                          if (!emailRegex.hasMatch(value)) {
                            print('valid emIAIL ADDRESS');
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.enterYourEmail,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.deepPurple),
                          ),
                          // suffix: InkWell(
                          //   child: Icon(
                          //     provider.isObsecured
                          //         ? Icons.visibility
                          //         : Icons.visibility_off,
                          //   ),
                          //   onTap: () {
                          //     provider.isObsecured = !provider.isObsecured;
                          //   },
                          // ),
                        ),
                      ),
                      SizedBox(
                          height: size.height * 0.023,
                      ),
                      CustomButton(
                        ontap: () {
                          if (emailController.text.isEmpty) {
                            print('enter your email address');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.enterYourEmail),
                              ),
                            );
                          } else if (!emailRegex.hasMatch(emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("enter valid email address"),
                              ),
                            );
                          }
                          else {
                            FirebaseAnalytics.instance.logEvent(
                              name: 'pin_recovery_email',
                              parameters: <String, dynamic>{
                                'activity': 'Navigating to HomeScreen',
                                'action': 'Setup Button clicked',
                              },
                            );
                            Provider.of<AuthProvider>(context, listen: false).getEmail(email: emailController.text);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(),
                              ),
                            );
                          }
                        },
                        buttontext: AppLocalizations.of(context)!.setUp,
                      ),

                      SizedBox(
                        height: 16,
                      ),
                      GestureDetector(
                        onTap: (){
                          FirebaseAnalytics.instance.logEvent(
                            name: 'pin_recovery_skip',
                            parameters: <String, dynamic>{
                              'activity': 'Navigating to HomeScreen',
                              'action': 'skip Button clicked',
                            },
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                        child: Text(
                          AppLocalizations.of(context)!.skip,
                          style: TextStyle(color: Theme.of(context).brightness == Brightness.light
                              ? Color(0xFF666666)// Color for light theme
                              : Color(0xFF999999),
                          fontFamily: "Manrope"
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
