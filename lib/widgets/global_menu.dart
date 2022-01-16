import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/screens/sign_in.dart';
import 'package:ultiplay/states/session.dart';

class GlobalMenu extends StatelessWidget {
  GlobalMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Session>(builder: (context, session, child) {
      return Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(
                session.user?.email ?? 'loading...',
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
                session.logOut();
                Navigator.of(context).pushReplacementNamed(SignIn.routeName);
              },
            ),
          ],
        ),
      );
    });
  }
}
