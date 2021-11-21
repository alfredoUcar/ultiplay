import 'package:flutter/material.dart';
import 'package:ultiplay/models/game.dart';

class NewGame extends StatefulWidget {
  final Function onStart;
  const NewGame({Key? key, required this.onStart}) : super(key: key);

  @override
  _NewGameState createState() {
    return _NewGameState(onStart);
  }
}

class _NewGameState extends State<NewGame> {
  final Function onStart;

  _NewGameState(this.onStart);

  Game? _game;
  bool _mixedGenderChecked = false;
  final _formKey = GlobalKey<FormState>();
  String _mainTeamPosition = Position.offense.toString();
  String _genderRule = GenderRatio.ruleA.toString();
  String? _mainTeam;
  String? _opponentTeam;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New game'),
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(hintText: 'Your team'),
                  validator: nonEmptyTextValidator,
                  onSaved: (String? value) {
                    _mainTeam = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Opponent'),
                  validator: nonEmptyTextValidator,
                  onSaved: (String? value) {
                    _opponentTeam = value;
                  },
                ),
                ListTile(
                  title: Text('Your line'),
                ),
                RadioListTile(
                  title: Text('Offense'),
                  value: Position.offense.toString(),
                  groupValue: _mainTeamPosition,
                  onChanged: updateLinePosition,
                ),
                RadioListTile(
                  title: Text('Defense'),
                  value: Position.defense.toString(),
                  groupValue: _mainTeamPosition,
                  onChanged: updateLinePosition,
                ),
                CheckboxListTile(
                  value: _mixedGenderChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _mixedGenderChecked = value ?? false;
                    });
                  },
                  title: Text('Mixed'),
                ),
                Visibility(
                  visible: _mixedGenderChecked,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Gender ratio'),
                      ),
                      RadioListTile(
                        title: Text('Rule A'),
                        value: GenderRatio.ruleA.toString(),
                        groupValue: _genderRule,
                        onChanged: updateGenderRatioRule,
                      ),
                      RadioListTile(
                        title: Text('Rule B'),
                        value: GenderRatio.ruleB.toString(),
                        groupValue: _genderRule,
                        onChanged: updateGenderRatioRule,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        Position position = Position.values.firstWhere(
                            (element) =>
                                element.toString() == _mainTeamPosition);
                        if (_mixedGenderChecked) {
                          GenderRatio ratio = GenderRatio.values.firstWhere(
                              (element) => element.toString() == _genderRule);
                          _game = new Game(
                            yourTeamName: _mainTeam ?? 'main team',
                            opponentTeamName: _opponentTeam ?? 'second team',
                            initialPosition: position,
                            gender: Gender.mixed,
                            genderRatio: ratio,
                          );
                        } else {
                          _game = new Game(
                            yourTeamName: _mainTeam ?? 'main team',
                            opponentTeamName: _opponentTeam ?? 'second team',
                            initialPosition: position,
                          );
                        }
                        onStart(_game);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('Start game'))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void updateLinePosition(String? value) {
    setState(() {
      _mainTeamPosition = value ?? Position.offense.toString();
    });
  }

  void updateGenderRatioRule(String? value) {
    setState(() {
      _genderRule = value ?? GenderRatio.ruleA.toString();
    });
  }

  String? nonEmptyTextValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }
}
