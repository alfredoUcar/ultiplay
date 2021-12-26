import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ultiplay/screens/sign_in.dart';

class GlobalMenu extends StatefulWidget {
  GlobalMenu({Key? key}) : super(key: key);

  @override
  _GlobalMenuState createState() => _GlobalMenuState();
}

class _GlobalMenuState extends State<GlobalMenu> {
  User? _user;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text(
              _user?.email ?? 'loading...',
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 20,
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text('Logout'),
            onTap: () async {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed(SignIn.routeName);
            },
          ),
        ],
      ),
    );
  }
}
