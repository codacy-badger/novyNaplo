import 'dart:core';
import 'package:novynaplo/screens/marks_tab.dart' as marksPage;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'classManager.dart';
import 'utils.dart';
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;

//TODO: Add option to translate notices, events, evals, homework and subjects
int _index = 0;
var sum;
var jegyek;
List<Evals> jegyArray = [];
var stringEvals = [];
var catIndex = 0;

Future<List<dynamic>> parseAllByDate(var input) async {
  jegyArray = [];
  try {
    jegyek = input["Evaluations"];
    jegyArray = [];
    for (var n in jegyek) {
      jegyArray.add(setEvals(n));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAllByDate');
    return [];
  }
  jegyArray.sort((a, b) => b.createDateString.compareTo(a.createDateString));
  await batchInsertEval(jegyArray);
  return jegyArray;
}

Future<List<Avarage>> parseAvarages(var input) async {
  List<Avarage> atlagArray = [];
  try {
    for (var n in input) {
      atlagArray.add(setAvarage(
          n["Subject"], n["Value"], n["classValue"], n["Difference"]));
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseAvarages');
    return [];
  }
  await batchInsertAvarage(atlagArray);
  return atlagArray;
}

Future<List<Notices>> parseNotices(var input) async {
  if (input != null && input["Notes"] != null) {
    List<Notices> noticesArray = [];
    var notices = input["Notes"];
    for (var n in notices) {
      noticesArray.add(setNotices(n));
    }
    await batchInsertNotices(noticesArray);
    return noticesArray;
  } else {
    return [];
  }
}

List<String> parseSubjects(var input) {
  List<String> subjectsArray = [];
  var subjects = input["SubjectAverages"];
  for (var n in subjects) {
    subjectsArray.add(capitalize(n["Subject"]));
  }
  return subjectsArray;
}

//*USED BY STATISTICS
List<List<Evals>> categorizeSubjects() {
  List<Evals> jegyArray = new List.from(marksPage.allParsedByDate);
  List<List<Evals>> jegyMatrix = [[]];
  jegyArray.sort((a, b) => a.subject.compareTo(b.subject));
  String lastString = "";
  for (var n in jegyArray) {
    if ((n.form != "Percent" && n.type != "HalfYear") ||
        n.subject == "Magatartas" ||
        n.subject == "Szorgalom") {
      if (n.subject != lastString) {
        jegyMatrix.add([]);
        lastString = n.subject;
      }
      jegyMatrix.last.add(n);
    }
  }
  jegyMatrix.removeAt(0);
  _index = 0;
  for (var n in jegyMatrix) {
    n.sort((a, b) => a.createDate.compareTo(b.createDate));
    _index++;
  }
  return jegyMatrix;
}

List<dynamic> categorizeSubjectsFromEvals(List<Evals> input) {
  List<Evals> jegyArray = input;
  List<List<Evals>> jegyMatrix = [[]];
  jegyArray.sort((a, b) => a.subject.compareTo(b.subject));
  String lastString = "";
  for (var n in jegyArray) {
    if ((n.form != "Percent" && n.type != "HalfYear") ||
        n.subject == "Magatartas" ||
        n.subject == "Szorgalom") {
      if (n.subject != lastString) {
        jegyMatrix.add([]);
        lastString = n.subject;
      }
      jegyMatrix.last.add(n);
    }
  }
  jegyMatrix.removeAt(0);
  _index = 0;
  for (var n in jegyMatrix) {
    n.sort((a, b) => a.createDate.compareTo(b.createDate));
    _index++;
  }
  return jegyMatrix;
}

List<List<Evals>> sortByDateAndSubject(List<Evals> input) {
  input.sort((a, b) => a.subject.compareTo(b.subject));
  int _currentIndex = 0;
  List<List<Evals>> _tempArray = [[]];
  if (input != null && input.length != 0) {
    String _beforeSubject = input[0].subject;
    for (var n in input) {
      if (n.subject != _beforeSubject) {
        _currentIndex++;
        _tempArray.add([]);
        _beforeSubject = n.subject;
      }
      _tempArray[_currentIndex].add(n);
    }
    for (List<Evals> n in _tempArray) {
      n.sort((a, b) => b.createDateString.compareTo(a.createDateString));
    }
  }
  return _tempArray;
}

Future<List<List<Lesson>>> makeTimetableMatrix(List<Lesson> lessons) async {
  if (lessons == null) return [];
  //Variables
  int index = 0;
  List<List<Lesson>> output = [[]];
  DateTime tempDate;
  //Find this monday and sunday
  DateTime now = new DateTime.now();
  now = new DateTime(now.year, now.month, now.day);
  int monday = 1;
  int sunday = 7;
  while (now.weekday != monday) {
    now = now.subtract(new Duration(days: 1));
  }
  DateTime startMonday = now;
  now = new DateTime.now();
  now = new DateTime(now.year, now.month, now.day);
  while (now.weekday != sunday) {
    now = now.add(new Duration(days: 1));
  }
  DateTime endSunday = now;
  for (var n in lessons) {
    if (n.date.compareTo(startMonday) >= 0 &&
        n.date.compareTo(endSunday) <= 0) {
      if (tempDate == null) {
        tempDate = n.date;
      }
      if (n.date.isSameDay(tempDate)) {
        output[index].add(n);
      } else {
        tempDate = n.date;
        output.add([]);
        index++;
      }

      if (timetablePage.fetchedDayList
              .where((element) =>
                  element.day == n.date.day &&
                  element.month == n.date.month &&
                  element.year == n.date.year)
              .length ==
          0) {
        timetablePage.fetchedDayList.add(n.date);
      }
      timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    } else {
      timetablePage.fetchedDayList.removeWhere((element) =>
          element.day == n.date.day &&
          element.month == n.date.month &&
          element.year == n.date.year);
      await deleteFromDb(n.databaseId, "Timetable");
    }
  }
  return output;
}

Future<List<Exam>> parseExams(var input) async {
  List<Exam> examArray = [];
  try {
    for (var n in input) {
      Exam temp = new Exam();
      temp.id = n["Id"];
      temp.dateWriteString = n["Datum"];
      temp.dateWrite = DateTime.parse(n["Datum"]);
      temp.dateGivenUpString = n["BejelentesDatuma"];
      temp.dateGivenUp = DateTime.parse(n["BejelentesDatuma"]);
      temp.subject = n["Tantargy"];
      temp.teacher = n["Tanar"];
      temp.nameOfExam = n["SzamonkeresMegnevezese"];
      temp.typeOfExam = n["SzamonkeresModja"];
      temp.classGroupId = n["OsztalyCsoportUid"];
      examArray.add(temp);
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseExams');
    return [];
  }
  return examArray;
}

Future<List<Event>> parseEvents(var input) async {
  List<Event> eventArray = [];
  try {
    for (var n in input) {
      Event temp = new Event();
      temp.id = n["EventId"];
      temp.dateString = n["Date"];
      temp.date = DateTime.parse(n["Date"]);
      temp.endDateString = n["EndDate"];
      temp.endDate = DateTime.parse(n["EndDate"]);
      temp.content = n["Content"];
      temp.content = temp.content.replaceAll("\n", "<br>");
      temp.title = n["Title"];
      eventArray.add(temp);
    }
  } catch (e, s) {
    Crashlytics.instance.recordError(e, s, context: 'parseEvents');
    return [];
  }
  return eventArray;
}
