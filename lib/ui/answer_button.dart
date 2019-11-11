import 'package:flutter/material.dart';

import 'colors.dart';

class AnswerButton extends StatefulWidget {

  final AnswerButtonController controller;

  final String text;
  final bool isCorrect;

  AnswerButton(this.controller, this.text, this.isCorrect);

  @override
  State<StatefulWidget> createState() => _AnswerButtonState();

}

class AnswerButtonController {

  static const int normal = 0;
  static const int correct = 1;
  static const int incorrect = 2;

  Function(bool) onSubmittedAnswer;
  bool alreadySubmittedAnswer = false;
  int state = normal;

  AnswerButtonController(this.onSubmittedAnswer);

  reset() {
    state = normal;
    alreadySubmittedAnswer = false;
  }

}

class _AnswerButtonState extends State<AnswerButton> {

  _onPressed() {
    if(!widget.controller.alreadySubmittedAnswer) {
      if (widget.isCorrect) {
        widget.controller.onSubmittedAnswer(true);
        setState(() {
          widget.controller.state = AnswerButtonController.correct;
        });
      } else {
        widget.controller.onSubmittedAnswer(false);
        setState(() {
          widget.controller.state = AnswerButtonController.incorrect;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Expanded(
            child: RaisedButton(
              onPressed: _onPressed,
                color: getButtonColor(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.text,
                            style: TextStyle(
                                color: getTextColor(),
                                fontSize: 18,
                                fontWeight: FontWeight.w500)),
                      ),
                    )
                  ]),
                )))
      ]),
    );
  }

  getTextColor(){
    switch(widget.controller.state) {
      case AnswerButtonController.normal:
        return primaryColor;
      case AnswerButtonController.correct:
        return Colors.white;
      case AnswerButtonController.incorrect:
        return Colors.white;
      default:
      // error
        return Colors.white;
    }
  }

  getButtonColor() {
    switch(widget.controller.state) {
      case AnswerButtonController.normal:
        return Colors.white;
      case AnswerButtonController.correct:
        return Colors.green;
      case AnswerButtonController.incorrect:
        return Colors.red;
      default:
        // error
        return Colors.white;
    }
  }
}
