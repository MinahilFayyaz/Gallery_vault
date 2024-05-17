import 'dart:convert';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../utils/utils.dart';
import '../../widgets/custombutton.dart';
import '../homepage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginformKey = GlobalKey<FormState>();
  final List<TextEditingController> _pinControllers =
  List.generate(4, (_) => TextEditingController());
  final passwordMatchValidator =
  MatchValidator(errorText: 'Passwords do not match');
  int _incorrectAttempts = 0;
  final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  Future<void> sendEmail(String recipient, String subject, String body) async {
    // Create SMTP server configuration
    final smtpServer = gmail('minahilfayyaz9@gmail.com', 'tupk ffnb doow jyns');

    // Create the message to send
    final message = Message()
      ..from = Address('minahilfayyaz9@gmail.com', 'Minahil Fayyaz')
      ..recipients.add(recipient)
      ..subject = subject
      ..text = body;

    // Send the email
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Mail Send Successfully")));
    } on MailerException catch (e) {
      print('Message not sent.');
      print(e.message);
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Add listeners to the pin controllers
    for (var controller in _pinControllers) {
      controller.addListener(_onPinChanged);
    }
  }

  void _onPinChanged() {
    // Combine pin inputs from all controllers
    final pin =
    _pinControllers.map((controller) => controller.text.trim()).join();

    // Validate the entered pin when all 4 digits have been entered
    if (pin.length == 4) {
      _validatePin(pin);
    }
  }

  void _validatePin(String pin) async {
    // Retrieve the master password
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('email') ?? '';
    String masterPassword = prefs.getString('password') ?? '';

    // Compare the entered pin with the master password
    if (pin == masterPassword) {
      FirebaseAnalytics.instance.logEvent(
        name: 'login_passcode',
        parameters: <String, dynamic>{
          'activity': 'Navigating to HomeScreen',
          'action': 'correct passcode',
        },
      );
      _incorrectAttempts = 0;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      _incorrectAttempts++;
      // Check if the incorrect attempts exceed 3
      if (_incorrectAttempts >= 3) {

        if (savedEmail == null || savedEmail.isEmpty) {
          // If saved email doesn't exist, prompt user to input email
          await _showEmailInputDialog(prefs);
          return; // Return to avoid further processing until email is entered
        }

        final emailBody = 'Your login passcode is: $masterPassword';
        await sendEmail(savedEmail, 'Login Passcode', emailBody);

        // Reset the incorrect attempts count
        _incorrectAttempts = 0;

        for (var controller in _pinControllers) {
          controller.clear();
        }
      };

    FirebaseAnalytics.instance.logEvent(
        name: 'login_passcode',
        parameters: <String, dynamic>{
          'activity': 'Navigating to Homescreen',
          'action': 'wrong login passcode',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incorrect pin code. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );

      // Clear the pin input fields
      for (var controller in _pinControllers) {
        controller.clear();
      }
    }
  }

  Future<void> _showEmailInputDialog(SharedPreferences prefs) async {
    String email = ''; // Variable to store entered email
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
              child: Text(
                AppLocalizations.of(context)!.enterYourEmail,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: "Manrope",
                ),
              )),
          content:
                Container(
                decoration: BoxDecoration(
        border: Border.all(
        color: Consts.COLOR), // Border around the TextField
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        //color: Consts.BG_COLOR
        ),child :  TextField(
            onChanged: (value) {
              email = value; // Update email as user types
            },
            decoration: InputDecoration(
              hintText: "Email@gmail.com",
              border: InputBorder.none, // Remove default border
              contentPadding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
                ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Add your cancel logic here
                    Navigator.pop(context);
                    for (var controller in _pinControllers) {
                      controller.clear();
                    }
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
                          ? Color(0xFFE8E8E8) // Color for light theme
                          : Consts.BG_COLOR,
                    ), // Set background color
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (email.isEmpty) {
                      print('enter your email address');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.enterYourEmail),
                        ),
                      );
                    } else if (!emailRegex.hasMatch(email)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("enter valid email address"),
                        ),
                      );
                    }
                    else {
                      // Save email to SharedPreferences
                      await prefs.setString('email', email);
                      Navigator.of(context).pop();
                      for (var controller in _pinControllers) {
                        controller.clear();
                      }
                    }// Close dialog
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: const BorderSide(color: Consts.COLOR),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all(Size(100, 40)),
                    // Set button size
                    backgroundColor: MaterialStateProperty.all(
                        Consts.COLOR), // Set background color
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.confirm,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _removeLastDigit() {
    for (int i = _pinControllers.length - 1; i >= 0; i--) {
      if (_pinControllers[i].text.isNotEmpty) {
        _pinControllers[i].clear();
        break;
      }
    }
  }

  @override
  void dispose() {
    _pinControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Login Screen');
    final size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(
      builder: (BuildContext context, provider, Widget? child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) => Utils(context).onWillPop(),
          child: Scaffold(
            body: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                  child: Form(
                    key: _loginformKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.07),
                        Theme.of(context).brightness == Brightness.light
                            ? SvgPicture.asset(
                          'assets/padlock 3.svg',
                          height: size.height * 0.1,
                        )
                            : SvgPicture.asset("assets/padlock 2.svg"),
                        SizedBox(height: size.height * 0.028),
                        Text(
                          AppLocalizations.of(context)!.enterYourPasscode,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            fontFamily: "Manrope"
                            //color: Colors.white,
                          ),
                        ),
                        SizedBox(height: size.height * 0.028),
                        Container(
                          width: 270,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                            Theme.of(context).brightness == Brightness.light
                                ? Color(0xFFF5F5F5) // Color for light theme
                                : Color(0xFF171823),
                            border: Border.all(
                                color: Colors
                                    .deepPurple), // Change border color to purple
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: List.generate(
                              4,
                                  (index) {
                                return Expanded(
                                  child: PinInputField(
                                      controller: _pinControllers[index]),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.05),
                        GridView.count(
                          crossAxisCount: 3,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          childAspectRatio: 1.5,
                          padding: EdgeInsets.all(8.0),
                          mainAxisSpacing: 16.0,
                          crossAxisSpacing: 1.0,
                          children: List.generate(
                            12, // Increase by 1 to include the cancel button
                                (index) {
                              if (index == 9) {
                                // Leave the 9th index empty
                                return Container();
                              } else if (index == 10) {
                                // Display "0" at the 10th index
                                return Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final pinIndex = _pinControllers
                                          .indexWhere((controller) =>
                                      controller.text.isEmpty);
                                      if (pinIndex != -1) {
                                        _pinControllers[pinIndex].text = '0';
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      elevation: 0
                                    ),
                                    child: Text(
                                      '0',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              } else if (index == 11) {
                                // Add a cancel button as the 11th element in the grid view
                                return Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                                  child: CancelButton(
                                    onPressed: () {
                                      _removeLastDigit();
                                    },
                                  ),
                                );
                              } else {
                                // Add numeric buttons from 1 to 9
                                return Padding(
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final pinIndex = _pinControllers
                                          .indexWhere((controller) =>
                                      controller.text.isEmpty);
                                      if (pinIndex != -1) {
                                        _pinControllers[pinIndex].text =
                                        '${index + 1}'; // Increment index by 1 to start counting from 1
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      elevation: 0
                                    ),
                                    child: Text(
                                      //AppLocalizations.of(context)!.digits,
                                      '${index + 1}', // Increment index by 1 to start counting from 1
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
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

class PinInputField extends StatelessWidget {
  final TextEditingController controller;

  const PinInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Set the height of the SizedBox
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.deepPurple,
          fontSize: 60,
        ),
        keyboardType: TextInputType.number,
        maxLength: 1,
        obscureText: true, // Hide the entered text
        decoration: InputDecoration(
          hintText: '*',
          hintStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          counterText: '',
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.only(bottom: 11), // Remove vertical padding
        ),
        onChanged: (_) {
          // No need to handle onChanged when using obscureText
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }
}

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Theme.of(context).brightness == Brightness.light
          ? ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset(
            'assets/Vector.svg'), // Color for light theme
      )
          : SvgPicture.asset('assets/Vector.svg'),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        elevation: 0
      ),
    );
  }
}


