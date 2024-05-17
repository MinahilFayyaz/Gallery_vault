import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../consts/consts.dart';

class Dailogue {
  void _showConfirmationDialog(BuildContext context) {
    // Get the file name with extension
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Consts.FG_COLOR,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 70.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                      Brightness.light
                                      ? Color(0xFFF5F5F5) // Color for light theme
                                      : Consts.FG_COLOR,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Image widget inside the Stack
                              Positioned(
                                child: ClipOval(
                                  child: ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                            ? Colors.black // Color for light theme
                                            : Colors.white,
                                        BlendMode.srcIn),
                                    child: SvgPicture.asset(
                                      'assets/deletedailogue.svg',
                                      // Replace with the path to your image
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.delete,
                              style: const TextStyle(
                                  fontFamily: "Manrope",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.thePhotoWillBeCompletely +
                          '\n' +
                          AppLocalizations.of(context)!.deletedAndCannotBe +
                          '\n' +
                          AppLocalizations.of(context)!.recovered,
                      maxLines: 3,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Manrope",
                          color: Theme.of(context).brightness ==
                              Brightness.light
                              ? Color(0xFF222222).withOpacity(0.5)
                              : Color(0xFFFFFFFF).withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      // Add your cancel logic here
                      Navigator.pop(context);
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
                            ? Color(0xFFF5F5F5) // Color for light theme
                            : Color(0xFF363C54), //
                      ), // Set background color
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                          color: Theme.of(context).brightness ==
                              Brightness.light
                              ? Color(0xFF222222) // Color for light theme
                              : Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(100, 40)),
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).brightness == Brightness.light
                              ? Color(0xFFDD4848)
                              : Consts.COLOR),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.delete,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: "Manrope",
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}


void _showConfirmationOutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: 0,
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : Consts.FG_COLOR,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 70.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                    Brightness.light
                                    ? Color(
                                    0xFFF5F5F5) // Color for light theme
                                    : Consts.FG_COLOR,
                                shape: BoxShape.circle,
                              ),
                            ),
                            // Image widget inside the Stack
                            Positioned(
                              child: ClipOval(
                                child: ColorFiltered(
                                  colorFilter: ColorFilter.mode(
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                          ? Colors
                                          .black // Color for light theme
                                          : Colors.white,
                                      BlendMode.srcIn),
                                  child: SvgPicture.asset(
                                    'assets/lock-padlock-symbol-for-security-interface 2.svg',
                                    // Replace with the path to your image
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.moveOut,
                            style: const TextStyle(
                                fontFamily: "Manrope",
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                      AppLocalizations.of(context)!.areYouSureYouWantToMove +"\n 1 item(s)"+ AppLocalizations.of(context)!.outTheGalleryVault,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Manrope",
                        color:
                        Theme.of(context).brightness == Brightness.light
                            ? Color(0xFF222222).withOpacity(0.5)
                            : Color(0xFFFFFFFF).withOpacity(0.5),)
                  ),
                ],
              ),
            ),
            SizedBox(height: 8,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Add your cancel logic here
                    Navigator.pop(context);
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
                          ? Color(0xFFF5F5F5) // Color for light theme
                          : Color(0xFF363C54),
                    ), // Set background color
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                    style: TextStyle(
                        color:
                        Theme.of(context).brightness == Brightness.light
                            ? Color(0xFF222222) // Color for light theme
                            : Colors.white
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(100, 40)),
                    backgroundColor: MaterialStateProperty.all(Consts.COLOR),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.confirm,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: "Manrope",
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}