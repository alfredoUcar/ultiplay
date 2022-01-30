import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/screens/sign_in.dart';
import 'package:ultiplay/screens/verify_email.dart';
import 'package:ultiplay/states/session.dart';

class SignUp extends StatefulWidget {
  static const routeName = 'sign-up';
  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    var session = Provider.of<Session>(context, listen: false);
    if (session.user != null && !session.user!.emailVerified) {
      session.sendEmailVerification();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Validation email sent')));
      Navigator.of(context).pushReplacementNamed(VerifyEmail.routeName);
    }
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: repeatPasswordController,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords must be equal';
                    }
                    return null;
                  },
                  obscureText: true,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Repeat password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    singUp(context);
                  },
                  child: Text('Sign up')),
              SizedBox(height: 20),
              Text('Already registered?'),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(SignIn.routeName);
                  },
                  child: Text('Access with your account')),
              Consumer<Session>(
                builder: (context, session, child) {
                  return Visibility(
                      child: CircularProgressIndicator(),
                      visible: session.registering);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void singUp(BuildContext context) async {
    try {
      await Provider.of<Session>(context, listen: false).signUp(
          email: emailController.text, password: passwordController.text);
      Navigator.of(context).pushReplacementNamed(Home.routeName);
    } on WeakPasswordException catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    } on EmailAlreadyInUseException {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Already exists an account with that email')));
    } on UnexpectedException {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong')));
    }
  }
}
