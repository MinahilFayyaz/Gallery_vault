import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  final LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
  }

  Future<void> _checkDeviceSupport() async {
    try {
      bool isSupported = await auth.isDeviceSupported();
      setState(() {
        _supportState = isSupported ? _SupportState.supported : _SupportState.unsupported;
      });
    } on PlatformException catch (e) {
      print('Error checking device support: $e');
      setState(() {
        _supportState = _SupportState.unsupported;
      });
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      });

      if (authenticated) {
        _navigateToNextScreen();
      } else {
        _showErrorSnackBar('Authentication failed.');
      }
    } on PlatformException catch (e) {
      print('Error during authentication: $e');
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      _showErrorSnackBar('Error during authentication: ${e.message}');
    }
  }

  void _navigateToNextScreen() {
    final onBoardingProvider = Provider.of<OnBoardingProvider>(context, listen: false);
    onBoardingProvider.checkOnBoardingStatus();
    final isOnBoardingComplete = onBoardingProvider.isBoardingCompleate;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => isOnBoardingComplete ? const LoginPage() : const OnBoardingSceen(),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
                      'assets/Frame 37367.png',
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
                            ontap: _authenticate,
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
