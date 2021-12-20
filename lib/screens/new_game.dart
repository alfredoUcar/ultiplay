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
  Division? _division;
  Position? _mainTeamPosition;
  FieldSide? _mainTeamSide;
  GenderRatioRule? _genderRule;
  Modality? _modality;
  GenderRatio? _genderRatio;
  FieldSide? _endzoneASide;
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

    var genderRuleSubtitle;
    var genderRatioContent;
    var genderRatioSubtitle;
    switch (_genderRule) {
      case GenderRatioRule.ruleA:
        genderRuleSubtitle = 'Rule A';
        genderRatioContent = genderRatioOptionsForRuleA();
        genderRatioSubtitle = getSubtitleForGenderRuleA();
        break;
      case GenderRatioRule.ruleB:
        genderRuleSubtitle = 'Rule B';
        genderRatioContent = genderRatioOptionsForRuleB();
        genderRatioSubtitle = getSubtitleForGenderRuleB();
        break;
      default:
        genderRuleSubtitle = null;
        genderRatioContent = Container();
    }

    var _steps = [
      {
        'title': 'Teams',
        'subtitle': getTeamsSubtitle(),
        'active': true,
        'state': StepState.indexed,
        'content': teams(),
      },
      {
        'title': 'Division',
        'subtitle': _division?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'content': divisionOptions(),
      },
      {
        'title': 'Gender rule',
        'subtitle': genderRuleSubtitle,
        'active': _division == Division.mixed,
        'state': _division == Division.mixed
            ? StepState.indexed
            : StepState.disabled,
        'content': genderRatioRules(),
      },
      {
        'title': 'Gender ratio',
        'subtitle': genderRatioSubtitle,
        'active': _division == Division.mixed,
        'state': _division == Division.mixed && _genderRule != null
            ? StepState.indexed
            : StepState.disabled,
        'content': genderRatioContent,
      },
      {
        'title': 'Modality',
        'subtitle': _modality?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'content': modalityOptions(),
      },
      {
        'title': 'Your initial line',
        'subtitle': _mainTeamPosition?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'content': lineOptions(),
      },
      {
        'title': 'Your initial field side',
        'subtitle': _mainTeamSide?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'is_valid': true,
        'content': fieldSideOptions(),
      },
    ];

    bool isInLastStep() => _index == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('New game'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (isInLastStep()) ? onSubmit : requireToCompleteAllSteps,
        child: Icon(Icons.play_arrow),
        backgroundColor: !isInLastStep() ? ThemeData().disabledColor : null,
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
            setState(() {
              // search and apply previous non disabled step
              var nextStepIndex = _index;
              var nextStepState;
              do {
                nextStepIndex--;
                nextStepState = _steps[nextStepIndex]['state'] as StepState;
              } while (nextStepIndex < _steps.length &&
                  nextStepState == StepState.disabled);
              if (nextStepState != _steps.length) {
                _index = nextStepIndex;
              }
            });
          },
          onStepContinue: () {
            setState(() {
              // search and apply next non disabled step
              var nextStepIndex = _index;
              var nextStepState;
              do {
                nextStepIndex++;
                nextStepState = _steps[nextStepIndex]['state'] as StepState;
              } while (nextStepIndex < _steps.length &&
                  nextStepState == StepState.disabled);
              if (nextStepState != _steps.length) {
                _index = nextStepIndex;
              }
            });
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
                subtitle: (step['subtitle'] != null)
                    ? Text(step['subtitle'] as String)
                    : null,
                isActive: step['active'] as bool,
                title: Text(step['title'] as String),
                content: step['content'] as Widget);
          }).toList(),
        ),
      ),
    );
  }

  String? getTeamsSubtitle() {
    String? teamsSubtitle;
    if (mainTeamController.text.isNotEmpty &&
        opponentTeamController.text.isNotEmpty) {
      teamsSubtitle =
          '${mainTeamController.text} vs ${opponentTeamController.text}';
    }
    return teamsSubtitle;
  }

  String? getSubtitleForGenderRuleB() {
    String? genderRuleBSubtitle;
    switch (_endzoneASide) {
      case FieldSide.left:
        genderRuleBSubtitle = 'Endzone A is on the left field';
        break;
      case FieldSide.right:
        genderRuleBSubtitle = 'Endzone A is on the right field';
        break;
      default:
        genderRuleBSubtitle = null;
    }
    return genderRuleBSubtitle;
  }

  String? getSubtitleForGenderRuleA() {
    String? genderRuleASubtitle;
    switch (_genderRatio) {
      case GenderRatio.moreMen:
        genderRuleASubtitle = 'Starting with more men';
        break;
      case GenderRatio.moreWomen:
        genderRuleASubtitle = 'Starting with more women';
        break;
      default:
        genderRuleASubtitle = null;
    }
    return genderRuleASubtitle;
  }

  Widget lineOptions() {
    return FormField(
      initialValue: _mainTeamPosition,
      validator: selectValueRequired,
      builder: (field) {
        return Column(
          children: [
            ...Position.values.asMap().entries.map((entry) {
              Position position = entry.value;
              return RadioListTile(
                title: Text(position.name.capitalize()),
                value: position,
                groupValue: _mainTeamPosition,
                onChanged: (Position? value) {
                  setState(() {
                    _mainTeamPosition = value;
                    field.setValue(value);
                    field.validate();
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget teams() {
    return Column(
      children: [
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(hintText: 'Your team'),
          validator: _teamValidator.validate,
          controller: mainTeamController,
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(hintText: 'Opponent'),
          validator: _teamValidator.validate,
          controller: opponentTeamController,
        ),
      ],
    );
  }

  Widget modalityOptions() {
    return FormField(
      initialValue: _modality,
      validator: selectValueRequired,
      builder: (field) {
        return Column(
          children: [
            ...Modality.values.asMap().entries.map((entry) {
              Modality modality = entry.value;
              return RadioListTile(
                title: Text(modality.name.capitalize()),
                value: modality,
                groupValue: _modality,
                onChanged: (Modality? value) {
                  setState(() {
                    _modality = value;
                    field.setValue(value);
                    field.validate();
                  });
                },
              );
            }),
            if (field.hasError)
              Text(
                field.errorText as String,
                style: TextStyle(color: ThemeData().errorColor),
              ),
          ],
        );
      },
    );
  }

  Widget fieldSideOptions() {
    return FormField(
      initialValue: _mainTeamSide,
      validator: selectValueRequired,
      builder: (field) {
        return Column(
          children: [
            ...FieldSide.values.asMap().entries.map((entry) {
              FieldSide side = entry.value;
              return RadioListTile(
                title: Text(side.name.capitalize()),
                value: side,
                groupValue: _mainTeamSide,
                onChanged: (FieldSide? value) {
                  setState(() {
                    _mainTeamSide = value;
                    field.setValue(value);
                    field.validate();
                  });
                },
              );
            }),
            if (field.hasError)
              Text(
                field.errorText as String,
                style: TextStyle(color: ThemeData().errorColor),
              ),
          ],
        );
      },
    );
  }

  Widget divisionOptions() {
    return FormField(
      initialValue: _division,
      validator: selectValueRequired,
      builder: (field) {
        return Column(
          children: [
            ...Division.values.asMap().entries.map((entry) {
              Division division = entry.value;
              return RadioListTile(
                title: Text(division.name.capitalize()),
                value: division,
                groupValue: field.value as Division?,
                onChanged: (Division? value) {
                  setState(() {
                    _division = value;
                    field.setValue(value);
                    field.validate();
                  });
                },
              );
            }),
            if (field.hasError)
              Text(
                field.errorText as String,
                style: TextStyle(color: ThemeData().errorColor),
              ),
          ],
        );
      },
    );
  }

  String? selectValueRequired(value) {
    if (value == null) {
      return 'Select a value';
    }
  }

  Widget genderRatioOptionsForRuleB() {
    return FormField(
      initialValue: _endzoneASide,
      builder: (field) {
        return Column(
          children: [
            ListTile(
              title: Text('Endzone A side'),
            ),
            RadioListTile(
              title: Text('Left'),
              value: FieldSide.left,
              groupValue: _endzoneASide,
              onChanged: updateEndzoneASide,
            ),
            RadioListTile(
              title: Text('Right'),
              value: FieldSide.right,
              groupValue: _endzoneASide,
              onChanged: updateEndzoneASide,
            ),
          ],
        );
      },
    );
  }

  Widget genderRatioOptionsForRuleA() {
    return FormField(
      initialValue: _genderRatio,
      builder: (field) {
        return Column(
          children: [
            ListTile(
              title: Text('Starting with'),
            ),
            RadioListTile(
              title: Text('More women'),
              value: GenderRatio.moreWomen,
              groupValue: _genderRatio,
              onChanged: updateGenderRatio,
            ),
            RadioListTile(
              title: Text('More men'),
              value: GenderRatio.moreMen,
              groupValue: _genderRatio,
              onChanged: updateGenderRatio,
            ),
          ],
        );
      },
    );
  }

  Widget genderRatioRules() {
    return FormField(
      initialValue: _genderRule,
      validator: selectValueRequired,
      builder: (field) {
        return Column(
          children: [
            RadioListTile(
              title: Text('Rule A: prescribed'),
              value: GenderRatioRule.ruleA,
              groupValue: _genderRule,
              onChanged: updateGenderRatioRule,
            ),
            RadioListTile(
              title: Text('Rule B: end zone decides'),
              value: GenderRatioRule.ruleB,
              groupValue: _genderRule,
              onChanged: updateGenderRatioRule,
            ),
          ],
        );
      },
    );
  }

  void onSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_division == Division.mixed) {
        _game = new Game(
          yourTeamName: mainTeamController.text,
          opponentTeamName: opponentTeamController.text,
          initialPosition: _mainTeamPosition as Position,
          initialSide: _mainTeamSide as FieldSide,
          division: _division as Division,
          genderRule: _genderRule,
          initialGenderRatio: _genderRatio,
          modality: _modality as Modality,
          endzoneA: _endzoneASide,
        );
      } else {
        _game = new Game(
          yourTeamName: mainTeamController.text,
          opponentTeamName: opponentTeamController.text,
          initialPosition: _mainTeamPosition as Position,
          initialSide: _mainTeamSide as FieldSide,
          division: _division as Division,
          modality: _modality as Modality,
        );
      }
      _screenArguments.onStart(_game as Game);
      openNewGame(context);
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        dismissDirection: DismissDirection.horizontal,
        content: Text('Please review form'),
      ));
    }
  }

  void requireToCompleteAllSteps() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Complete all steps')));
  }

  void updateGenderRatioRule(GenderRatioRule? value) {
    setState(() {
      _genderRule = value;
    });
  }

  void updateGenderRatio(GenderRatio? value) {
    setState(() {
      _genderRatio = value;
    });
  }

  void updateEndzoneASide(FieldSide? value) {
    setState(() {
      _endzoneASide = value;
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
