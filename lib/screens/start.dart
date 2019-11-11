import 'package:coding_interview/db/pojo/question.dart';
import 'package:coding_interview/db/questions.dart';
import 'package:coding_interview/ui/animated_background.dart';
import 'package:coding_interview/ui/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:sqflite/sqflite.dart';

import 'interview.dart';

class Start extends StatefulWidget {
  Start({Key key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> with SingleTickerProviderStateMixin {
  int completionPercentage = 0;

  _onPressedPlay() async {
    await calculateCompletionPercentage();
    if (completionPercentage == 100) {
      _showGameFinishedDialog();
    } else {
      Navigator.push(
              context, MaterialPageRoute(builder: (context) => Interview()))
          .then((value) {
        calculateCompletionPercentage();
      });
    }
  }

  _resetProgress() async {
    await Questions.reset();
    calculateCompletionPercentage();
  }

  _showGameFinishedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Game finished'),
          content: const Text(
              'Congrats, you have finished all questions! If you want to play again, you can press the reset button below.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
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

  _onPressedReset() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset progress'),
          content: const Text(
              'Do you really want to reset your progress? This can not be undone!'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                // Close dialog
                Navigator.of(context).pop();
                // Reset progress
                _resetProgress();
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

  @override
  void initState() {
    super.initState();
    calculateCompletionPercentage();
  }

  calculateCompletionPercentage() async {
    int percentage = (await Questions.completionPercentage());
    setState(() {
      completionPercentage = percentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("Coding Interview",
              style: TextStyle(
                  color: Colors.white, fontSize: 30, fontFamily: 'Kirvy'))),
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(children: [
          Padding(
              padding: EdgeInsets.all(32),
              child: Column(children: [
                SizedBox(height: 50),
                Center(
                    child: SizedBox(
                  width: 180,
                  height: 180,
                  child: LiquidCircularProgressIndicator(
                      value: completionPercentage / 100.0,
                      borderWidth: 5.0,
                      borderColor: Colors.white.withAlpha(80),
                      valueColor: AlwaysStoppedAnimation(primaryColor),
                      direction: Axis.vertical,
                      center: Text(completionPercentage.toString() + "%",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontFamily: 'Kirvy'))),
                )),
                SizedBox(height: 70),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        height: 70,
                        child: RaisedButton(
                            onPressed: () => _onPressedPlay(),
                            color: primaryColor,
                            child: Text("Play",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontFamily: 'Kirvy'))),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ButtonTheme(
                        height: 70,
                        child: RaisedButton(
                            onPressed: () => _onPressedReset(),
                            color: primaryColor,
                            child: Text("Reset",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontFamily: 'Kirvy'))),
                      ),
                    ),
                  ],
                ),
              ])),
          Align(
            alignment: FractionalOffset.bottomCenter,
            child: Stack(
              children: <Widget>[
                AnimatedWave(
                    height: 80,
                    offset: 0.0,
                    speed: 0.8,
                    color: primaryColor.withAlpha(80)),
                AnimatedWave(
                    height: 80,
                    offset: 1.5,
                    speed: 0.8,
                    color: primaryColor.withAlpha(80)),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
