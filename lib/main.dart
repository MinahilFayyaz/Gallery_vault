import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'consts/consts.dart';
import 'consts/style.dart';
import 'controller/language_change_controller.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'provider/authprovider.dart';
import 'provider/onboardprovider.dart';
import 'provider/themeprovider.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async{
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
   await GetStorage.init(); // Initialize GetStorage
   final String languageCode = GetStorage().read('selectedLanguageCode') ?? 'en';
   await Hive.initFlutter();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  analytics.logAppOpen();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  runApp(MyApp(locale : languageCode));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_)
          => LanguageChangeController()),
          ChangeNotifierProvider(create: (_) {
            return ThemeProvider(context);
          }),
          ChangeNotifierProvider(create: (_) {
            return OnBoardingProvider();
          }),
          ChangeNotifierProvider(
            create: (context) => AuthProvider(),
          ),
        ],
        builder: (context, child) {
          removesplash();
          return Consumer2<ThemeProvider, LanguageChangeController>(
              builder: (context, value, languageController, child) {
                if (locale.isEmpty){
                  languageController.changeLanguage(const Locale('en'));
                }
                return GetMaterialApp(
                    debugShowCheckedModeBanner: false,
                    title: Consts.APP_NAME,
                    theme: Styles.themeData(
                      context: context,
                      isDarkTheme: false,
                    ),
                    darkTheme: Styles.themeData(
                      context: context,
                      isDarkTheme: true,
                    ),
                    themeMode: context.watch<ThemeProvider>().themeMode,
                  locale: locale.isEmpty ? const Locale('en') : Locale(locale),
                  localizationsDelegates: const [
                    AppLocalizations.delegate, // Add this line
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: L10n.all,
                  home: SplashScreen(),
                );
              });
        });
  }

  void removesplash() async {
    return await Future.delayed(const Duration(seconds: 3), () {
      FlutterNativeSplash.remove();
    });
  }
}