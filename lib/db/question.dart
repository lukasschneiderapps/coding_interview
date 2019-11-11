class Question {
  final int id;
  final String question;
  final String answer;
  final String wrong1, wrong2, wrong3;
  bool completed;

  Question(
      {this.id,
      this.question,
      this.answer,
      this.wrong1,
      this.wrong2,
      this.wrong3,
      this.completed});
}
