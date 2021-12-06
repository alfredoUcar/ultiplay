import 'package:flutter/material.dart';
import 'package:ultiplay/extensions/string.dart';
import 'package:ultiplay/extensions/enum.dart';
import 'package:ultiplay/models/game.dart';
import 'current_game.dart';

class NewGame extends StatefulWidget {
  static const routeName = 'new-game';

  @override
  _NewGameState createState() {
    return _NewGameState();
  }
}

class _NewGameState extends State<NewGame> {
  late Function onStart;
  late TextEditingController mainTeamController;
  late TextEditingController opponentTeamController;

  Game? _game;
  final _formKey = GlobalKey<FormState>();
  String _division = Division.open.toString();
  String _mainTeamPosition = Position.offense.toString();
  String _mainTeamSide = FieldSide.left.toString();
  String _genderRule = GenderRatioRule.ruleA.toString();
  String _modality = Modality.grass.toString();
  String _genderRatio = GenderRatio.moreWomen.toString();
  String? _endzoneASide = FieldSide.left.toString();

  @override
  void initState() {
    mainTeamController = TextEditingController();
    opponentTeamController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    mainTeamController.dispose();
    opponentTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    onStart = ModalRoute.of(context)!.settings.arguments as Function;

    return Scaffold(
      appBar: AppBar(
        title: Text('New game'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onSubmit,
        child: Icon(Icons.play_arrow),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.home),
              color: Colors.white,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, NewGame.routeName,
                    arguments: onStart);
              },
              icon: Icon(Icons.restart_alt),
              color: Colors.white,
            ),
          ],
        ),
        color: Colors.blue,
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
                  controller: mainTeamController,
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: 'Opponent'),
                  validator: nonEmptyTextValidator,
                  controller: opponentTeamController,
                ),
                modalityOptions(),
                lineOptions(),
                fieldSideOptions(),
                divisionOptions(),
                genderRatioRules(),
                genderRatioOptionsForRuleA(),
                genderRatioOptionsForRuleB(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget lineOptions() {
    return Column(
      children: [
        ListTile(
          title: Text('Your initial line'),
        ),
        ...Position.values.asMap().entries.map((entry) {
          Position position = entry.value;
          return RadioListTile(
            title: Text(position.name.capitalize()),
            value: position.toString(),
            groupValue: _mainTeamPosition,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _mainTeamPosition = value;
                });
              }
            },
          );
        }),
      ],
    );
  }

  Widget modalityOptions() {
    return Column(
      children: [
        ListTile(
          title: Text('Modality'),
        ),
        ...Modality.values.asMap().entries.map((entry) {
          Modality modality = entry.value;
          return RadioListTile(
            title: Text(modality.name.capitalize()),
            value: modality.toString(),
            groupValue: _modality,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _modality = value;
                });
              }
            },
          );
        }),
      ],
    );
  }

  Widget fieldSideOptions() {
    return Column(
      children: [
        ListTile(
          title: Text('Your initial side'),
        ),
        ...FieldSide.values.asMap().entries.map((entry) {
          FieldSide side = entry.value;
          return RadioListTile(
            title: Text(side.name.capitalize()),
            value: side.toString(),
            groupValue: _mainTeamSide,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _mainTeamSide = value;
                });
              }
            },
          );
        }),
      ],
    );
  }

  Widget divisionOptions() {
    return Column(
      children: [
        ListTile(
          title: Text('Division'),
        ),
        ...Division.values.asMap().entries.map((entry) {
          Division division = entry.value;
          return RadioListTile(
            title: Text(division.name.capitalize()),
            value: division.toString(),
            groupValue: _division,
            onChanged: (String? newDivision) {
              if (newDivision != null) {
                setState(() {
                  _division = newDivision;
                });
              }
            },
          );
        }),
      ],
    );
  }

  Widget genderRatioOptionsForRuleB() {
    return Visibility(
      visible: _division == Division.mixed.toString() &&
          _genderRule == GenderRatioRule.ruleB.toString(),
      child: Column(
        children: [
          ListTile(
            title: Text('Endzone A side'),
          ),
          RadioListTile(
            title: Text('Left'),
            value: FieldSide.left.toString(),
            groupValue: _endzoneASide,
            onChanged: updateEndzoneASide,
          ),
          RadioListTile(
            title: Text('Right'),
            value: FieldSide.right.toString(),
            groupValue: _endzoneASide,
            onChanged: updateEndzoneASide,
          ),
        ],
      ),
    );
  }

  Widget genderRatioOptionsForRuleA() {
    return Visibility(
      visible: _division == Division.mixed.toString() &&
          _genderRule == GenderRatioRule.ruleA.toString(),
      child: Column(
        children: [
          ListTile(
            title: Text('Starting with'),
          ),
          RadioListTile(
            title: Text('More women'),
            value: GenderRatio.moreWomen.toString(),
            groupValue: _genderRatio,
            onChanged: updateGenderRatio,
          ),
          RadioListTile(
            title: Text('More men'),
            value: GenderRatio.moreMen.toString(),
            groupValue: _genderRatio,
            onChanged: updateGenderRatio,
          ),
        ],
      ),
    );
  }

  Widget genderRatioRules() {
    return Visibility(
      visible: _division == Division.mixed.toString(),
      child: Column(
        children: [
          ListTile(
            title: Text('Gender ratio'),
          ),
          RadioListTile(
            title: Text('Rule A: prescribed'),
            value: GenderRatioRule.ruleA.toString(),
            groupValue: _genderRule,
            onChanged: updateGenderRatioRule,
          ),
          RadioListTile(
            title: Text('Rule B: end zone decides'),
            value: GenderRatioRule.ruleB.toString(),
            groupValue: _genderRule,
            onChanged: updateGenderRatioRule,
          ),
        ],
      ),
    );
  }

  void onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Position position = Position.values
          .firstWhere((element) => element.toString() == _mainTeamPosition);
      FieldSide side = FieldSide.values
          .firstWhere((element) => element.toString() == _mainTeamSide);
      Modality modality = Modality.values
          .firstWhere((element) => element.toString() == _modality);

      if (_division == Division.mixed.toString()) {
        GenderRatioRule genderRule = GenderRatioRule.values
            .firstWhere((element) => element.toString() == _genderRule);
        GenderRatio genderRatio = GenderRatio.values
            .firstWhere((element) => element.toString() == _genderRatio);

        _game = new Game(
          yourTeamName: mainTeamController.text,
          opponentTeamName: opponentTeamController.text,
          initialPosition: position,
          initialSide: side,
          division: Division.mixed,
          genderRule: genderRule,
          initialGenderRatio: genderRatio,
          modality: modality,
        );
      } else {
        _game = new Game(
          yourTeamName: mainTeamController.text,
          initialSide: side,
          opponentTeamName: opponentTeamController.text,
          initialPosition: position,
          modality: modality,
        );
      }
      onStart(_game);
      openNewGame(context);
    }
  }

  void updateGenderRatioRule(String? value) {
    setState(() {
      _genderRule = value ?? GenderRatioRule.ruleA.toString();
    });
  }

  void updateGenderRatio(String? value) {
    setState(() {
      _genderRatio = value ?? GenderRatio.moreWomen.toString();
    });
  }

  void updateEndzoneASide(String? value) {
    setState(() {
      _endzoneASide = value ?? FieldSide.left.toString();
    });
  }

  String? nonEmptyTextValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  void openNewGame(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => CurrentGame(_game as Game)));
  }
}
