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
  String? _email;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        setState(() {
          _email = user.email;
        });
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
            padding: const EdgeInsets.all(20.0),
            child: Text(
              _email != null
                  ? "We've sent an email to $_email to verify your email address and activate your account"
                  : "We've sent you an email to verify your email address and activate your account",
              textAlign: TextAlign.center,
            ),
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
                        content: Text("Your account isn't verified yet")));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Confirm'),
                    SizedBox(width: 10),
                    Icon(Icons.check),
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
                      content: Text('Validation email sent to $_email')));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Resend verification email'),
                    SizedBox(width: 10),
                    Icon(Icons.send),
                  ],
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
                onPressed: () async {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed(SignIn.routeName);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Logout'),
                    SizedBox(width: 10),
                    Icon(Icons.exit_to_app),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
