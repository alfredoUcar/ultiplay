import 'package:flutter/material.dart';

class NewGame extends StatefulWidget {
  const NewGame({Key? key}) : super(key: key);

  @override
  _NewGameState createState() {
    return _NewGameState();
  }
}

class _NewGameState extends State<NewGame> {
  bool _mixedGenreChecked = false;
  final _formKey = GlobalKey<FormState>();
  String _lineMode = 'offense';
  String _genderRule = 'rule-a';
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
                  value: 'offense',
                  groupValue: _lineMode,
                  onChanged: updateLineMode,
                ),
                RadioListTile(
                  title: Text('Defense'),
                  value: 'defense',
                  groupValue: _lineMode,
                  onChanged: updateLineMode,
                ),
                CheckboxListTile(
                  value: _mixedGenreChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _mixedGenreChecked = value ?? false;
                    });
                  },
                  title: Text('Mixed'),
                ),
                Visibility(
                  visible: _mixedGenreChecked,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('Gender ratio'),
                      ),
                      RadioListTile(
                        title: Text('Rule A'),
                        value: 'rule-a',
                        groupValue: _genderRule,
                        onChanged: updateGenderRule,
                      ),
                      RadioListTile(
                        title: Text('Rule B'),
                        value: 'rule-b',
                        groupValue: _genderRule,
                        onChanged: updateGenderRule,
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print('form submitted');
                        _formKey.currentState!.save();
                        print(
                            "$_mainTeam VS $_opponentTeam | mixed: $_mixedGenreChecked | rule: $_genderRule");
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

  void updateLineMode(String? value) {
    setState(() {
      _lineMode = value ?? 'offense';
    });
  }

  void updateGenderRule(String? value) {
    setState(() {
      _genderRule = value ?? 'rule-a';
    });
  }

  String? nonEmptyTextValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }
}
