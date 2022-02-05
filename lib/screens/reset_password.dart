import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/sign_in.dart';
import 'package:ultiplay/states/session.dart';

class ResetPassword extends StatefulWidget {
  static const routeName = 'reset-password';
  ResetPassword({Key? key}) : super(key: key);

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Text(
                  'Ultiplay',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30)),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    Provider.of<Session>(context, listen: false)
                        .sendPasswordResetEmail(email: emailController.text)
                        .then((_) => null);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Password reset email sent')));
                    Navigator.of(context)
                        .pushReplacementNamed(SignIn.routeName);
                  },
                  child: Text('Reset password')),
            ],
          ),
        ),
      ),
    );
  }
}
