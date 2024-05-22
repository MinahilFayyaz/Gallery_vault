import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:provider/provider.dart';

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
        title: Text('Change Email Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _newEmailController,
                keyboardType: TextInputType.emailAddress,
                validator: MultiValidator([
                  RequiredValidator(errorText: 'Email is required'),
                  EmailValidator(errorText: 'Enter a valid email'),
                ]),
                decoration: InputDecoration(
                  filled: true,
                  labelText: 'New Email Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Consts.BORDER_RADIUS),
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
                buttontext: 'Change Email',
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
