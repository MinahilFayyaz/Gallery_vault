import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../consts/consts.dart';
import '../../provider/authprovider.dart';
import '../../widgets/custombutton.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({Key? key}) : super(key: key);

  @override
  _ChangeEmailPageState createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final TextEditingController _newEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( AppLocalizations.of(context)!.changeEmail),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Focus(
                child: TextFormField(
                  autofocus: true,
                  controller: _newEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: MultiValidator([
                    RequiredValidator(errorText: AppLocalizations.of(context)!.emailIsRequired),
                    EmailValidator(errorText: AppLocalizations.of(context)!.enterAValidEmail),
                  ]),
                  decoration: InputDecoration(
                    filled: true,
                    labelText:  AppLocalizations.of(context)!.newEmailAddress,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              CustomButton(
                ontap: () {
                  if (_formKey.currentState!.validate()) {
                    // Implement email change logic here
                    final newEmail = _newEmailController.text;
                    Provider.of<AuthProvider>(context, listen: false)
                        .getEmail(email: newEmail);
                    // Navigate back after changing the email
                    Navigator.pop(context);
                  }
                },
                buttontext:  AppLocalizations.of(context)!.changeEmail,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    super.dispose();
  }
}
