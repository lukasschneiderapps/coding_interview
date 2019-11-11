import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:coding_interview/db/pojo/question.dart';
import 'package:coding_interview/db/questions.dart';
import 'package:coding_interview/ui/colors.dart';
import 'package:coding_interview/ui/question_card.dart';
import 'package:flutter/material.dart';

class Interview extends StatefulWidget {
  @override
  _InterviewState createState() => _InterviewState();
}

class _InterviewState extends State<Interview>
    with SingleTickerProviderStateMixin {
  AnimationController _fadeInAnimation;
  final AudioCache audioPlayer = AudioCache();

  List<Question> randomQuestions;
  Question currentQuestion;

  int questionIndex = 0;

  int correctAnswers = 0;
  int incorrectAnswers = 0;

  bool finishedGame = false;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    _fadeInAnimation.dispose();
    super.dispose();
  }

  bool _onSwitchToNextAnswerLock = false;

  _onSwitchToNextAnswer(bool correct) async {
    if (!_onSwitchToNextAnswerLock) {
      _onSwitchToNextAnswerLock = true;

      // Update stats
      if (correct) {
        correctAnswers++;
      } else {
        incorrectAnswers++;
      }

      // Play sound
      if (correct) {
        audioPlayer.play("sounds/correct.wav");
      } else {
        audioPlayer.play("sounds/incorrect.wav");
      }

      // Update question
      randomQuestions[questionIndex].completed = correct;

      // Wait
      Future.delayed(const Duration(milliseconds: 1700), () {
        // Switch to next question
        if (questionIndex + 1 < randomQuestions.length) {
          questionIndex++;
          updateQuestion();
        } else {
          _finishGame();
        }

        _onSwitchToNextAnswerLock = false;
      });
    }
  }

  _onCancelButtonClicked() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel interview'),
          content: const Text(
              'Do you really want to cancel this interview? Your progress will be lost!'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                // Close dialog
                Navigator.of(context).pop();
                // Go to main menu
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                // Close dialog
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() {
    _onCancelButtonClicked();
    return Future<bool>.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
            leading: new IconButton(
              icon: new Icon(Icons.close, color: Colors.white),
              onPressed: () => {_onCancelButtonClicked()},
            ),
            centerTitle: true,
            title: Text("Interview",
                style: TextStyle(
                    color: Colors.white, fontSize: 30, fontFamily: 'Kirvy'))),
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Opacity(
                opacity: _fadeInAnimation.value,
                child: QuestionCard(
                    controller: QuestionCardController(
                        _onSwitchToNextAnswer, _fadeInAnimation.isCompleted),
                    randomQuestions: randomQuestions,
                    questionIndex: questionIndex),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future getRandomQuestions() async {
    // Get 10 random questions
    List<Question> questionsTmp = await Questions.uncompletedRandomlySorted();
    randomQuestions = questionsTmp.sublist(0, min(questionsTmp.length, 10));
  }

  void initAnimations() {
    _fadeInAnimation = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeInAnimation.addListener(() {
      setState(() {});
    });
  }

  void updateQuestion() {
    setState(() {
      currentQuestion = randomQuestions[questionIndex];
    });

    // Start fading in animation
    _fadeInAnimation.reset();
    _fadeInAnimation.forward();
  }

  void initialize() async {
    initAnimations();
    await getRandomQuestions();
    updateQuestion();
  }

  void _finishGame() {
    if (!finishedGame) {
      finishedGame = true;

      // Save question progress
      Questions.updateQuestions(randomQuestions);

      // Show result dialog
      int correctAnswersPercentage =
          ((correctAnswers.toDouble() / randomQuestions.length.toDouble()) *
                  100.0)
              .toInt();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              title: Text('Congratulations!'),
              content: Text(
                  "You have answered $correctAnswersPercentage% of the answers correctly."),
              actions: <Widget>[
                FlatButton(
                  child: Text('Continue'),
                  onPressed: () {
                    // Close dialog
                    Navigator.of(context).pop();
                    // Go to main menu
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
