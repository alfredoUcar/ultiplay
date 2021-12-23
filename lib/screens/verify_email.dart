import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/screens/sign_in.dart';

class VerifyEmail extends StatefulWidget {
  static const routeName = 'verify-email';
  VerifyEmail({Key? key}) : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        if (user.emailVerified) {
          Navigator.of(context).pushReplacementNamed(Home.routeName);
        }
      } else {
        Navigator.of(context).pushReplacementNamed(SignIn.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Text('Please verify your email'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.currentUser!.reload();
                  if (FirebaseAuth.instance.currentUser!.emailVerified) {
                    Navigator.of(context).pushReplacementNamed(Home.routeName);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Your account isn\'t verified yet')));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Confirm'),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.currentUser!
                      .sendEmailVerification();

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          'Validation email sent to ${FirebaseAuth.instance.currentUser!.email}')));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Resend verification email'),
                    Icon(Icons.send),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
