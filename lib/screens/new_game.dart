import 'package:flutter/material.dart';
import 'package:ultiplay/extensions/string.dart';
import 'package:ultiplay/extensions/enum.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:multi_validator/multi_validator.dart';

class NewGameArguments {
  void Function(Game) onStart;
  void Function() onFinish;

  NewGameArguments(this.onStart, this.onFinish);
}

class NewGame extends StatefulWidget {
  static const routeName = 'new-game';

  @override
  _NewGameState createState() {
    return _NewGameState();
  }
}

class _NewGameState extends State<NewGame> {
  late NewGameArguments _screenArguments;
  late TextEditingController mainTeamController;
  late TextEditingController opponentTeamController;
  late MultiValidator<String> _teamValidator;

  Game? _game;
  final _formKey = GlobalKey<FormState>();
  String _division = Division.open.toString();
  String _mainTeamPosition = Position.offense.toString();
  String _mainTeamSide = FieldSide.left.toString();
  String _genderRule = GenderRatioRule.ruleA.toString();
  String _modality = Modality.grass.toString();
  String _genderRatio = GenderRatio.moreWomen.toString();
  String? _endzoneASide = FieldSide.left.toString();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    mainTeamController = TextEditingController();
    opponentTeamController = TextEditingController();
    _teamValidator = MultiValidator<String>([
      nonEmptyTextValidator,
      differentTeamsValidator,
    ]);
  }

  @override
  void dispose() {
    mainTeamController.dispose();
    opponentTeamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenArguments =
        ModalRoute.of(context)!.settings.arguments as NewGameArguments;
    var _steps = [
      {
        'title': 'Teams',
        'active': true,
        'state': StepState.indexed,
        'content': teams(),
      },
      {
        'title': 'Division',
        'active': true,
        'state': StepState.indexed,
        'content': divisionOptions(),
      },
      {
        'title': 'Gender rule',
        'active': _division == Division.mixed.toString(),
        'state': _division == Division.mixed.toString()
            ? StepState.indexed
            : StepState.disabled,
        'content': genderRatioRules(),
      },
      {
        'title': 'Gender ratio',
        'active': _division == Division.mixed.toString(),
        'state': _division == Division.mixed.toString()
            ? StepState.indexed
            : StepState.disabled,
        'content': Column(
          children: [
            genderRatioOptionsForRuleA(),
            genderRatioOptionsForRuleB(),
          ],
        ),
      },
      {
        'title': 'Modality',
        'active': true,
        'state': StepState.indexed,
        'content': modalityOptions(),
      },
      {
        'title': 'Your initial line',
        'active': true,
        'state': StepState.indexed,
        'content': lineOptions(),
      },
      {
        'title': 'Your initial field side',
        'active': true,
        'state': StepState.indexed,
        'content': fieldSideOptions(),
      },
    ];

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
                    arguments: _screenArguments);
              },
              icon: Icon(Icons.restart_alt),
              color: Colors.white,
            ),
          ],
        ),
        color: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _index,
          controlsBuilder: (context, {onStepCancel, onStepContinue}) {
            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  if (_index < _steps.length - 1)
                    ElevatedButton(
                      onPressed: onStepContinue,
                      child: const Text('Next'),
                    ),
                  if (_index > 0)
                    ElevatedButton(
                      onPressed: onStepCancel,
                      child: const Text('Previous'),
                    ),
                ],
              ),
            );
          },
          onStepCancel: () {
            if (_index > 0) {
              setState(() {
                _index -= 1;
              });
            }
          },
          onStepContinue: () {
            if (_index < _steps.length) {
              setState(() {
                _index += 1;
              });
            }
          },
          onStepTapped: (int index) {
            setState(() {
              _index = index;
            });
          },
          steps: _steps.asMap().entries.map((entry) {
            var index = entry.key;
            var step = entry.value;
            return Step(
                state: index == _index
                    ? StepState.editing
                    : step['state'] as StepState,
                isActive: step['active'] as bool,
                title: Text(step['title'] as String),
                content: step['content'] as Widget);
          }).toList(),
        ),
      ),
    );
  }

  Widget lineOptions() {
    return Column(
      children: [
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

  Widget teams() {
    return Column(
      children: [
        TextFormField(
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(hintText: 'Your team'),
          validator: _teamValidator.validate,
          controller: mainTeamController,
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.always,
          decoration: InputDecoration(hintText: 'Opponent'),
          validator: _teamValidator.validate,
          controller: opponentTeamController,
        ),
      ],
    );
  }

  Widget modalityOptions() {
    return Column(
      children: [
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
      FieldSide endzoneA = FieldSide.values
          .firstWhere((element) => element.toString() == _endzoneASide);
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
          endzoneA: endzoneA,
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
      _screenArguments.onStart(_game as Game);
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

  String? differentTeamsValidator(String? value) {
    if (mainTeamController.text == opponentTeamController.text) {
      return 'Teams should be different';
    }
    return null;
  }

  void openNewGame(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(CurrentGame.routeName,
        arguments:
            CurrentGameArguments(_screenArguments.onFinish, _game as Game));
  }
}
