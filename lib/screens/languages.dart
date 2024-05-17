import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault/consts/consts.dart';
import '../controller/language_change_controller.dart';
import '../models/languages_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class languagesScreen extends StatefulWidget {
  languagesScreen(this.isFirstLaunch, {Key? key}) : super(key: key);

  final bool isFirstLaunch;
  @override
  State<languagesScreen> createState() => _languagesScreenState();
}

class _languagesScreenState extends State<languagesScreen> {
  late SharedPreferences _prefs;
  late Language selectedLanguage = languages.isNotEmpty ? languages.first : Language(code: 'en', name: 'English');

  @override
  void initState() {

    filteredLanguages = languages;
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      _loadSelectedLanguage(); // Load selected language
    });
    super.initState();
  }


  List<Language> filteredLanguages = [];

  void filterLanguages(String query) {
    setState(() {
      filteredLanguages = languages
          .where((language) =>
          language.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<Language> languages = [
    Language(code: 'en', name: 'English'),
    Language(code: 'ar', name: 'Arabic'),
    Language(code: 'bn', name: 'Bangali'),
    Language(code: 'zh', name: 'Chinese'),
    Language(code: 'fr', name: 'French'),
    Language(code: 'de', name: 'German'),
    Language(code: 'hi', name: 'Hindi'),
    Language(code: 'id', name: 'Indonesia'),
    Language(code: 'ms', name: 'Malay'),
    Language(code: 'nl', name: 'Dutch'),
    Language(code: 'ga', name: 'Irish'),
    Language(code: 'it', name: 'Italian'),
    Language(code: 'ja', name: 'Japanese'),
    Language(code: 'ko', name: 'Korean'),
    Language(code: 'fa', name: 'Persian'),
    Language(code: 'pl', name: 'Polish'),
    Language(code: 'pt', name: 'Portuguese'),
    Language(code: 'ro', name: 'Romanian'),
    Language(code: 'ru', name: 'Russian'),
    Language(code: 'th', name: 'Thai'),
    Language(code: 'tr', name: 'Turkish'),
    Language(code: 'ur', name: 'Urdu'),
  ];

  Future<void> _loadSelectedLanguage() async {
    String? selectedLanguageCode = _prefs.getString('selectedLanguageCode');
    if (selectedLanguageCode != null) {
      setState(() {
        selectedLanguage = languages.firstWhere(
              (language) => language.code == selectedLanguageCode,
          orElse: () => languages.first, // Set default language if not found
        );
      });
    } else {
      setState(() {
        selectedLanguage = languages.first; // Set default language if not saved
      });
    }
    // Update isSelected flag for loaded selectedLanguage
    languages.forEach((language) {
      language.isSelected = language == selectedLanguage;
    });
  }

  void _setSelectedLanguage(Language language) async {
    setState(() {
      selectedLanguage = language;
      _prefs.setString('selectedLanguageCode', language.code);
      languages.forEach((lang) {
        lang.isSelected = lang == selectedLanguage;
      });
    });

    final languageChangeController = context.read<LanguageChangeController>();
    await languageChangeController.changeLanguage(Locale(language.code));
    Get.updateLocale(Locale(language.code));

    print('widget.isFirst ${widget.isFirstLaunch}');
    if (widget.isFirstLaunch == false) {
      print('widget.isFirst ${widget.isFirstLaunch}');
      Get.reset();
    }

    GetStorage().write('selectedLanguageCode', language.code);

    print('Language set state Changed to: ${language.code}');
  }

  void updateFilteredCountries(String query) {
    print('Query: $query'); // Add this line to see if the method is triggered
    setState(() {
      filteredLanguages = languages.where((language) =>
          language.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    });
  }




  @override
  Widget build(BuildContext context) {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: 'Languages Screen');
    final locale = Localizations.localeOf(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Color(0xFFFFFFFF) // Color for light theme
            : Consts.FG_COLOR,
        centerTitle: true,
        leading: widget.isFirstLaunch
            ? null
            : IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 18,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.languages,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            fontFamily: "Manrope",
          ),
        ),
      ),
      body:  Padding(
        padding: EdgeInsets.all(screenWidth * 0.035),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //SearchBox(onTextChanged: updateFilteredCountries),
            SizedBox(height: screenHeight * 0.01),
            Expanded(
              child: ListView.builder(
                itemCount: filteredLanguages.length,
                itemBuilder: (context, index) {
                  Language currentLanguage = filteredLanguages[index];
                  return GestureDetector(
                    onTap: () {
                      _setSelectedLanguage(currentLanguage);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      child: Card(
                        color: Theme.of(context).brightness == Brightness.light
                            ? Color(0xFFF5F5F5) // Color for light theme
                            : Consts.FG_COLOR,
                        elevation: 0,
                        child: ListTile(
                          onTap: () {
                            _setSelectedLanguage(currentLanguage);
                            FirebaseAnalytics.instance.logEvent(
                              name: 'language_selection',
                              parameters: <String, dynamic>{
                                'activity': 'language set',
                              },
                            );
                          },
                          title: Text(
                            currentLanguage.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Manrope",
                            ),
                          ),
                          trailing: currentLanguage.isSelected
                          ? Icon(Icons.check,
                          color: Consts.COLOR,)
                              : null
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
