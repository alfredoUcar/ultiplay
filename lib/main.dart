import 'package:flutter/material.dart';

void main() {
  runApp(Ultiplay());
}

class Ultiplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ultiplay',
      home: Home(),
    );
  }
}

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

class NewGame extends StatelessWidget {
  const NewGame({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New game'),
      ),
    );
  }
}
