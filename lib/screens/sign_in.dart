import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/home.dart';
import 'package:ultiplay/screens/sign_up.dart';
import 'package:ultiplay/states/session.dart';

class SignIn extends StatefulWidget {
  static const routeName = 'sign-in';
  SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                  textInputAction: TextInputAction.done,
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
              ElevatedButton(
                  onPressed: () {
                    singIn(context);
                  },
                  child: Text('Sign in')),
              SizedBox(height: 20),
              Text('Not registered yet?'),
              TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushReplacementNamed(SignUp.routeName);
                  },
                  child: Text('Create an account')),
              Consumer<Session>(
                builder: (context, session, child) {
                  return Visibility(
                      child: CircularProgressIndicator(),
                      visible: session.authenticating);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void singIn(BuildContext context) async {
    try {
      await Provider.of<Session>(context, listen: false).logIn(
          email: emailController.text, password: passwordController.text);
      Navigator.of(context).pushReplacementNamed(Home.routeName);
    } on UserNotFoundException {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found for that email')));
    } on WrongPasswordException {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Wrong password')));
    } on UnexpectedException {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong')));
    }
  }
}
