import 'dart:math';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:coding_interview/db/pojo/question.dart';
import 'package:flutter/material.dart';

import 'answer_button.dart';
import 'colors.dart';

class QuestionCardController {
  final Function(bool) onSwitchToNextAnswer;
  final bool fadeInAnimationCompleted;

  QuestionCardController(
      this.onSwitchToNextAnswer, this.fadeInAnimationCompleted);
}

class QuestionCard extends StatefulWidget {
  final QuestionCardController controller;

  Question currentQuestion;

  AnswerButtonController answerController1;
  AnswerButtonController answerController2;
  AnswerButtonController answerController3;
  AnswerButtonController answerController4;

  List<Question> randomQuestions;
  int questionIndex;

  QuestionCard({
    @required this.controller,
    @required this.randomQuestions,
    @required this.questionIndex,
  }) {
    answerController1 = AnswerButtonController(_onSubmittedAnswer);
    answerController2 = AnswerButtonController(_onSubmittedAnswer);
    answerController3 = AnswerButtonController(_onSubmittedAnswer);
    answerController4 = AnswerButtonController(_onSubmittedAnswer);

    if (randomQuestions != null) {
      currentQuestion = randomQuestions[questionIndex];
    }
  }

  _onSubmittedAnswer(bool correct) {
    if (answerController1.alreadySubmittedAnswer ||
        answerController2.alreadySubmittedAnswer ||
        answerController3.alreadySubmittedAnswer ||
        answerController4.alreadySubmittedAnswer) {
      return;
    }

    if (!controller.fadeInAnimationCompleted) {
      return;
    }

    answerController1.alreadySubmittedAnswer = true;
    answerController2.alreadySubmittedAnswer = true;
    answerController3.alreadySubmittedAnswer = true;
    answerController4.alreadySubmittedAnswer = true;

    controller.onSwitchToNextAnswer(correct);
  }

  @override
  State<StatefulWidget> createState() => QuestionCardState();
}

class QuestionCardState extends State<QuestionCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              "Question ${widget.questionIndex + 1}/${widget.randomQuestions == null ? 10 : widget.randomQuestions.length}",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Kirvy')),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
                widget.currentQuestion == null
                    ? "-/-"
                    : widget.currentQuestion.question,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400)),
          ),
          SizedBox(height: 16),
          ListView(shrinkWrap: true, children: _getAnswerButtons())
        ]),
      ),
    );
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    setState(() {
      widget.answerController1.reset();
      widget.answerController2.reset();
      widget.answerController3.reset();
      widget.answerController4.reset();
    });
  }

  List<Widget> _getAnswerButtons() {
    List<Widget> shuffledButtons = [
      AnswerButton(
          widget.answerController1,
          widget.currentQuestion == null
              ? "-/-"
              : widget.currentQuestion.answer,
          true),
      AnswerButton(
          widget.answerController2,
          widget.currentQuestion == null
              ? "-/-"
              : widget.currentQuestion.wrong1,
          false),
      AnswerButton(
          widget.answerController3,
          widget.currentQuestion == null
              ? "-/-"
              : widget.currentQuestion.wrong2,
          false),
      AnswerButton(
          widget.answerController4,
          widget.currentQuestion == null
              ? "-/-"
              : widget.currentQuestion.wrong3,
          false),
    ];

    if (widget.currentQuestion != null) {
      shuffledButtons.shuffle(Random(widget.currentQuestion.id));
    }

    return shuffledButtons;
  }
}
