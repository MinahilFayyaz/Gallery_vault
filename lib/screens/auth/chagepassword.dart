import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../widgets/custombutton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final focus = FocusNode();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final oldpasswordController = TextEditingController();
  final List<TextEditingController> _pinControllers = List.generate(4, (_) => TextEditingController());

  final GlobalKey<FormState> _changePasswordFormKey = GlobalKey<FormState>();


  bool isOldPasswordFieldActive = false; // Track if old password field is active
  bool isConfirmPasswordFieldActive = false; // Track if confirm password field is active

  String pin = '';
  late MultiValidator passwordValidator;
  late MatchValidator passwordMatchValidator;


  void _removeLastDigit() {
    setState(() {
      if (isOldPasswordFieldActive) {
        String currentPassword = oldpasswordController.text;
        if (currentPassword.isNotEmpty) {
          String newPassword = currentPassword.substring(0, currentPassword.length - 1);
          oldpasswordController.text = newPassword;
        }
      } else if (isConfirmPasswordFieldActive) {
        String currentPassword = confirmpasswordController.text;
        if (currentPassword.isNotEmpty) {
          String newPassword = currentPassword.substring(0, currentPassword.length - 1);
          confirmpasswordController.text = newPassword;
        }
      } else {
        String currentPassword = passwordController.text;
        if (currentPassword.isNotEmpty) {
          String newPassword = currentPassword.substring(0, currentPassword.length - 1);
          passwordController.text = newPassword;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    for (var controller in _pinControllers) {
      controller.addListener(_onPinChanged);
    }
    final passwordValidator = MultiValidator([
      RequiredValidator(errorText: AppLocalizations.of(context)!.passwordIsRequired),
      MinLengthValidator(4, errorText: AppLocalizations.of(context)!.passwordMustBeAtLeast4DigitsLong),
    ]);
    final passwordMatchValidator = MatchValidator(errorText: AppLocalizations.of(context)!.passwordDonotMatch);

  }

  void _onPinChanged() {
    final pin = _pinControllers.map((controller) => controller.text.trim()).join();

    if (pin.length == 4) {
      _validatePin(pin);
    }
  }

  void _validatePin(String pin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //final savedEmail = prefs.getString('email') ?? '';
    String masterPassword = prefs.getString('password') ?? '';

    if (pin == masterPassword) {
      FirebaseAnalytics.instance.logEvent(
        name: 'login_passcode',
        parameters: <String, dynamic>{
          'activity': 'Navigating to HomeScreen',
          'action': 'correct passcode',
        },
      );
    } else {
      FirebaseAnalytics.instance.logEvent(
        name: 'login_passcode',
        parameters: <String, dynamic>{
          'activity': 'Navigating to Homescreen',
          'action': 'wrong login passcode',
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect pin code. Please try again.'),
          duration: Duration(seconds: 2),
        ),
      );

      for (var controller in _pinControllers) {
        controller.clear();
      }
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    oldpasswordController.dispose();
    confirmpasswordController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Consumer<AuthProvider>(builder: (BuildContext context, provider, Widget? child) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.07),
          child: AppBar(
            backgroundColor: Theme.of(context).brightness == Brightness.light
                ? Color(0xFFFFFFFF) // Color for light theme
                : Consts.FG_COLOR,
            title:  Text(
              AppLocalizations.of(context)!.changePassword,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  fontFamily: "Manrope"
                //color: Colors.white
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
              child: Form(
                key: _changePasswordFormKey,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      onTap: () => setState(() {
                        isOldPasswordFieldActive = true;
                        isConfirmPasswordFieldActive = false;
                      }
                      ), // Set active field
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(focus);
                      },
                      obscureText: provider.isObsecured,
                      maxLength: 4,
                      controller: oldpasswordController,
                      keyboardType: TextInputType.visiblePassword,
                      //textInputAction: TextInputAction.next,
                      validator: passwordValidator.call,
                      decoration: InputDecoration(
                        filled: true,
                        labelText:
                        AppLocalizations.of(context)!.oldPassword,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
                        ),
                        counterText: '',
                        suffix: InkWell(
                          child: Icon(
                            provider.isObsecured ? Icons.visibility : Icons.visibility_off,
                          ),
                          onTap: () {
                            provider.isObsecured = !provider.isObsecured;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      onTap: () => setState(() {
                        isOldPasswordFieldActive = false;
                        isConfirmPasswordFieldActive = false;
                      }), // Set active field
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).requestFocus(focus);
                      },
                      obscureText: provider.isObsecured,
                      maxLength: 4,
                      controller: passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      //textInputAction: TextInputAction.next,
                      validator: passwordValidator.call,
                      decoration: InputDecoration(
                        filled: true,
                        labelText:
                        AppLocalizations.of(context)!.newPassword,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
                        ),
                        counterText: '',
                        suffix: InkWell(
                          child: Icon(
                            provider.isObsecured ? Icons.visibility : Icons.visibility_off,
                          ),
                          onTap: () {
                            provider.isObsecured = !provider.isObsecured;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    TextFormField(
                      onTap: () => setState(() {
                        isOldPasswordFieldActive = false;
                        isConfirmPasswordFieldActive = true;
                      }), // Set active field
                      focusNode: focus,
                      obscureText: provider.isObsecured,
                      controller: confirmpasswordController,
                      maxLength: 4,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      validator: (val) => passwordMatchValidator.validateMatch(val!, passwordController.text.trim()),
                      decoration: InputDecoration(
                        labelText:
                        AppLocalizations.of(context)!.confirmPassword,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
                        ),
                        counterText: '',
                        suffix: InkWell(
                          child: Icon(
                            provider.isObsecured ? Icons.visibility : Icons.visibility_off,
                          ),
                          onTap: () {
                            provider.isObsecured = !provider.isObsecured;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    CustomButton(
                      ontap: () {
                        validate();
                      },
                      buttontext:
                      AppLocalizations.of(context)!.changePassword,
                    ),
                    SizedBox(height: size.height * 0.02),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      childAspectRatio: 1.5,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(8.0),
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 1.0,
                      children: List.generate(
                        12,
                            (index) {
                          if (index == 9) {
                            return Container();
                          } else if (index == 10) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {

                                  setState(() {
                                    if (pin.length < 4) {

                                      pin += '0';
                                      if (isOldPasswordFieldActive == true && isConfirmPasswordFieldActive == false){
                                       oldpasswordController.text = pin;
                                      }
                                      else if (isConfirmPasswordFieldActive== true && isOldPasswordFieldActive ==false) {
                                       confirmpasswordController.text = pin;
                                      }
                                      else {
                                       passwordController.text = pin;
                                      }
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                ),
                                child: Text(
                                  '0',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            );
                          } else if (index == 11) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  _removeLastDigit();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                ),
                                child: Icon(
                                  Icons.backspace,
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    if (pin.length < 4) {
                                      pin += '${index + 1}';
                                      if (isOldPasswordFieldActive == true && isConfirmPasswordFieldActive == false){
                                        print('isOldPasswordFieldActive $isOldPasswordFieldActive $isConfirmPasswordFieldActive');
                                        oldpasswordController.text = pin;
                                      }
                                      else if (isConfirmPasswordFieldActive== true && isOldPasswordFieldActive ==false) {
                                        print('isOldPasswordFieldActive $isOldPasswordFieldActive $isConfirmPasswordFieldActive');
                                        confirmpasswordController.text = pin;
                                      }
                                      else {
                                        print('isOldPasswordFieldActive $isOldPasswordFieldActive $isConfirmPasswordFieldActive');
                                        passwordController.text = pin;
                                      }
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
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
      );
    });
  }

  void validate() async {
    final FormState form = _changePasswordFormKey.currentState!;
    if (form.validate()) {

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String storedOldPassword = prefs.getString('password') ?? ''; // Retrieve stored password
      String enteredOldPassword = oldpasswordController.text.trim(); // Get entered old password

      if (enteredOldPassword == storedOldPassword) {
        // Old password matches, allow password change
        context.read<AuthProvider>().savePassword(password: confirmpasswordController.text.trim());
        Navigator.pop(context);
      } else {
        // Old password does not match, show error message
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
            content: Text(AppLocalizations.of(context)!.incorrectPasscodePleaseTryAgain),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
