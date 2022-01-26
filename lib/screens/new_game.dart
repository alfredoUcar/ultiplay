import 'package:flutter/material.dart';
import 'package:multi_validator/multi_validator.dart';
import 'package:provider/provider.dart';
import 'package:ultiplay/extensions/string.dart';
import 'package:ultiplay/extensions/enum.dart';
import 'package:ultiplay/models/game.dart';
import 'package:ultiplay/screens/current_game.dart';
import 'package:ultiplay/states/current_game.dart' as States;

class NewGame extends StatefulWidget {
  static const routeName = 'new-game';

  @override
  _NewGameState createState() {
    return _NewGameState();
  }
}

class _NewGameState extends State<NewGame> {
  bool _teamsStepIsValid = true;
  late TextEditingController mainTeamController;
  late TextEditingController opponentTeamController;
  late MultiValidator<String> _teamValidator;

  final _formKey = GlobalKey<FormState>();

  Division? _division;
  bool _divisionStepIsValid = true;

  Position? _mainTeamPosition;
  bool _positionStepIsValid = true;

  FieldSide? _mainTeamSide;
  bool _mainTeamSideStepIsValid = true;

  GenderRatioRule? _genderRule;
  bool _genderRuleStepIsValid = true;

  Modality? _modality;
  bool _modalityStepIsValid = true;

  GenderRatio? _genderRatio;
  FieldSide? _endzoneASide;
  bool _genderRatioStepIsValid = true;

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
        'is_valid': _teamsStepIsValid,
        'content': teams(),
      },
      {
        'title': 'Division',
        'subtitle': _division?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'is_valid': _divisionStepIsValid,
        'content': divisionOptions(),
      },
      {
        'title': 'Gender rule',
        'subtitle': genderRuleSubtitle,
        'active': _division == Division.mixed,
        'state': _division == Division.mixed
            ? StepState.indexed
            : StepState.disabled,
        'is_valid': _genderRuleStepIsValid,
        'content': genderRatioRules(),
      },
      {
        'title': 'Gender ratio',
        'subtitle': genderRatioSubtitle,
        'active': _division == Division.mixed && _genderRule != null,
        'state': _division == Division.mixed && _genderRule != null
            ? StepState.indexed
            : StepState.disabled,
        'is_valid': _genderRatioStepIsValid,
        'content': genderRatioContent,
      },
      {
        'title': 'Modality',
        'subtitle': _modality?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'is_valid': _modalityStepIsValid,
        'content': modalityOptions(),
      },
      {
        'title': 'Your initial line',
        'subtitle': _mainTeamPosition?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'is_valid': _positionStepIsValid,
        'content': lineOptions(),
      },
      {
        'title': 'Your initial field side',
        'subtitle': _mainTeamSide?.name.capitalize(),
        'active': true,
        'state': StepState.indexed,
        'is_valid': _mainTeamSideStepIsValid,
        'content': fieldSideOptions(),
      },
    ];

    bool isInLastStep() => _index == _steps.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('New game'),
        centerTitle: true,
      ),
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
              color: Theme.of(context).colorScheme.surface,
            ),
            IconButton(
              onPressed:
                  (isInLastStep()) ? onSubmit : requireToCompleteAllSteps,
              icon: Icon(Icons.play_arrow),
              color: !isInLastStep()
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.surface,
            ),
            IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, NewGame.routeName);
              },
              icon: Icon(Icons.restart_alt),
              color: Theme.of(context).colorScheme.surface,
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
            var state;
            if (index == _index) {
              // current step
              state = StepState.editing;
            } else if (index > _index) {
              // next steps
              state = step['state'] as StepState;
            } else {
              // previous steps
              if (step['is_valid'] as bool) {
                state = StepState.complete;
              } else {
                state = StepState.error;
              }
            }
            return Step(
                state: state,
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
      validator: (value) {
        var error = selectValueRequired(value);
        setState(() {
          _positionStepIsValid = (error == null);
        });
        return error;
      },
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
          validator: (value) {
            var error = _teamValidator.validate(value);
            _teamsStepIsValid = (error == null);
            return error;
          },
          controller: mainTeamController,
        ),
        TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(hintText: 'Opponent'),
          validator: (value) {
            var error = _teamValidator.validate(value);
            _teamsStepIsValid = (error == null) && _teamsStepIsValid;
            return error;
          },
          controller: opponentTeamController,
        ),
      ],
    );
  }

  Widget modalityOptions() {
    return FormField(
      initialValue: _modality,
      validator: (value) {
        var error = selectValueRequired(value);
        setState(() {
          _modalityStepIsValid = (error == null);
        });
        return error;
      },
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
      validator: (value) {
        var error = selectValueRequired(value);
        setState(() {
          _mainTeamSideStepIsValid = (error == null);
        });
        return error;
      },
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
      validator: (value) {
        var error = selectValueRequired(value);
        setState(() {
          _divisionStepIsValid = (error == null);
        });
        return error;
      },
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
      validator: (value) {
        if (_genderRule != GenderRatioRule.ruleB) {
          return null;
        }
        var error = selectValueRequired(value);
        setState(() {
          _genderRatioStepIsValid = (error == null);
        });
        return error;
      },
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
      validator: (value) {
        if (_genderRule != GenderRatioRule.ruleA) {
          return null;
        }
        var error = selectValueRequired(value);
        setState(() {
          _genderRatioStepIsValid = (error == null);
        });
        return error;
      },
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
      validator: (value) {
        if (_division != Division.mixed) {
          return null;
        }
        var error = selectValueRequired(value);
        setState(() {
          _genderRuleStepIsValid = (error == null);
        });
        return error;
      },
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
      var game;
      if (_division == Division.mixed) {
        game = new Game(
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
        game = new Game(
          yourTeamName: mainTeamController.text,
          opponentTeamName: opponentTeamController.text,
          initialPosition: _mainTeamPosition as Position,
          initialSide: _mainTeamSide as FieldSide,
          division: _division as Division,
          modality: _modality as Modality,
        );
      }
      startGame(context, game);
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

  void startGame(BuildContext context, Game game) {
    game.start();
    Provider.of<States.CurrentGame>(context, listen: false).game = game;
    Navigator.of(context).pop();
    Navigator.of(context).pushNamed(CurrentGame.routeName);
  }
}
