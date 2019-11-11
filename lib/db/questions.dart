import 'dart:async';

import 'package:coding_interview/db/pojo/question.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';

class Questions {
  static Database _db;

  static Future<Database> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  static Future<List<Question>> _parseQuestions() async {
    String data = await rootBundle.loadString("assets/texts/questions.txt");
    List<String> lines = data.split("\n");
    List<Question> questions = List();

    for (int i = 0; i < lines.length; i += 5) {
      questions.add(Question(
        id: -1,
        question: lines[i],
        answer: lines[i + 1],
        wrong1: lines[i + 2],
        wrong2: lines[i + 3],
        wrong3: lines[i + 4],
        completed: false,
      ));
    }

    return questions;
  }

  static initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "data.db");
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  static Future<FutureOr<void>> _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE questions(id INTEGER PRIMARY KEY, question TEXT, answer TEXT, wrong1 TEXT, wrong2 TEXT, wrong3 TEXT, completed BOOLEAN);");

    // Parse questions from txt and insert into db
    insertQuestions(db, await _parseQuestions());
  }

  static Future<List<Question>> uncompletedRandomlySorted() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery(
        "SELECT * FROM questions WHERE completed=\"false\" ORDER BY RANDOM()");
    List<Question> questions = List();
    for (Map map in list) {
      questions.add(Question(
          id: map["id"],
          question: map["question"],
          answer: map["answer"],
          wrong1: map["wrong1"],
          wrong2: map["wrong2"],
          wrong3: map["wrong3"],
          completed: map["completed"] == "true"));
    }

    return questions;
  }

  static Future reset() async {
    await deleteAllEntries();
    await insertQuestions(await db, await _parseQuestions());
  }

  static Future deleteAllEntries() async {
    var dbClient = await db;
    await dbClient.rawQuery("DELETE FROM questions");
  }

  static Future insertQuestions(Database db, List<Question> questions) async {
    await db.transaction((txn) async {
      for (Question question in questions) {
        await txn.rawInsert("INSERT INTO questions("
            "question, answer, wrong1, wrong2, wrong3, completed) VALUES("
            "\"${question.question}\","
            "\"${question.answer}\","
            "\"${question.wrong1}\","
            "\"${question.wrong2}\","
            "\"${question.wrong3}\","
            "\"${false}\");");
      }
    });
  }

  static Future<int> completionPercentage() async {
    var dbClient = await db;
    int allElementsCount =
        (await dbClient.rawQuery("SELECT * FROM questions")).length;
    int completedElementsCount = (await dbClient
            .rawQuery("SELECT * FROM questions WHERE completed=\"true\""))
        .length;

    if(allElementsCount == 0)
      return 0;

    return (completedElementsCount.toDouble() /
            allElementsCount.toDouble() *
            100.0)
        .toInt();
  }

  static Future updateQuestions(List<Question> questions) async {
    var dbClient = await db;
    await dbClient.transaction((txn) async {
      for (Question question in questions) {
        await txn.rawInsert(
            "UPDATE questions SET completed=\"${question.completed}\" WHERE id=${question.id}");
      }
    });
  }
}
