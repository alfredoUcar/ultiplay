import 'package:flutter/material.dart';
import 'package:ultiplay/screens/new_game.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ultiplay'),
        ),
        body: Center(
            child: OutlinedButton(
                child: Text('New game'),
                onPressed: () {
                  openNewGameForm(context);
                })));
  }

  void openNewGameForm(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const NewGame()));
  }
}
