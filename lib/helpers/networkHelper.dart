import 'package:connectivity/connectivity.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/insertSql.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/screens/avarages_tab.dart' as avaragesPage;
import 'package:novynaplo/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:novynaplo/config.dart' as config;
import 'package:http/http.dart' as http;
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String agent = config.currAgent;
var response;
int tokenIndex = 0;

//TODO: UPDATE TO API V3, ONLY WHEN IT WILL BE STABLE TO USE
class NetworkHelper {
  Future<ConnectivityResult> isNetworkAvailable() async {
    return await (Connectivity().checkConnectivity());
  }

  Future<void> getEvents(token, code) async {
    Crashlytics.instance.log("getEvents");
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'User-Agent': '$agent',
      };

      var res = await http.get('https://$code.e-kreta.hu/mapi/api/v1/EventAmi',
          headers: headers);
      if (res.statusCode != 200)
        throw Exception('get error: statusCode= ${res.statusCode}');
      if (res.statusCode == 200) {
        var bodyJson = json.decode(res.body);
        eventsPage.allParsedEvents = await parseEvents(bodyJson);
        eventsPage.allParsedEvents.sort((a, b) => b.date.compareTo(a.date));
        await batchInsertEvents(eventsPage.allParsedEvents);
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getEvents');
    }
  }

  Future<String> getToken(code, user, pass) async {
    //TODO: Look into this function, something is not right
    Crashlytics.instance.log("getToken, try $tokenIndex");
    tokenIndex++;
    try {
      if (code == "" || user == "" || pass == "") {
        return getTranslatedString("missingInput");
      } else {
        var headers = {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          'User-Agent': '$agent',
        };

        var data =
            'institute_code=$code&userName=$user&password=$pass&grant_type=password&client_id=919e0c1c-76a2-4646-a2fb-7085bbbf3c56';
        try {
          response = await http.post(
              'https://$code.e-kreta.hu/idp/api/v1/Token',
              headers: headers,
              body: data);
          if (response.statusCode == 200) {
            var parsedJson = json.decode(response.body);
            var status = parsedJson['token_type'];
            if (status == '' || status == null) {
              if (parsedJson["error_description"] == '' ||
                  parsedJson["error_description"] == null) {
                return getTranslatedString("wrongUserPass");
              } else {
                return parsedJson["error_description"];
              }
            } else {
              globals.tokenDate = DateTime.now();
              globals.token = parsedJson["access_token"];
              print("TokenOK");
              return "OK";
            }
            //print(status);
          } else if (response.statusCode == 401) {
            var parsedJson = json.decode(response.body);
            if (parsedJson["error_description"] == '' ||
                parsedJson["error_description"] == null) {
              return getTranslatedString("wrongUserPass");
            } else {
              return parsedJson["error_description"];
            }
            //print('Response status: ${response.statusCode}');
          } else {
            return 'post error: statusCode= ${response.statusCode}';
          }
        } on SocketException {
          return getTranslatedString("wrongSchId");
        }
      }
    } catch (e, s) {
      var client = http.Client();
      var header = {
        'User-Agent': '$agent',
        'Content-Type': 'application/json',
      };
      var res;
      try {
        res = await client.get('https://api.novy.vip/kretaHeader.json',
            headers: header);
        if (res.statusCode == 200) {
          agent = json.decode(res.body)["header"];
          config.currAgent = agent = json.decode(res.body)["header"];
          if (tokenIndex < 3) {
            getToken(code, user, pass);
          } else {
            Crashlytics.instance.recordError(e, s, context: 'getToken');
            return getTranslatedString("noAns");
          }
        }
      } catch (e, s) {
        Crashlytics.instance.recordError(e, s, context: 'getToken');
        return getTranslatedString("noAnsNovy");
      }
    }
    return "Error";
  }

  Future<void> getStudentInfo(token, code) async {
    Crashlytics.instance.log("getStudentInfo");
    var headers = {
      'Authorization': 'Bearer $token',
      'User-Agent': '$agent',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/StudentAmi?fromDate=null&toDate=null',
        headers: headers);
    if (res.statusCode != 200)
      throw Exception('get error: statusCode= ${res.statusCode}');
    if (res.statusCode == 200) {
      globals.dJson = json.decode(res.body);
      if (!config.isAppPlaystoreRelease) {
        Crashlytics.instance.setUserName(globals.dJson["Name"]);
        Crashlytics.instance.setString("User", globals.dJson["Name"]);
      }
      await getAvarages(token, code);
      await getExams(token, code);
      await getEvents(token, code);
      marksPage.allParsedByDate = await parseAllByDate(globals.dJson);
      marksPage.colors = getRandomColors(marksPage.allParsedByDate.length);
      marksPage.allParsedBySubject =
          sortByDateAndSubject(List.from(marksPage.allParsedByDate));
      noticesPage.allParsedNotices = await parseNotices(globals.dJson);
      statisticsPage.allParsedSubjects = categorizeSubjects();
      statisticsPage.allParsedSubjectsWithoutZeros = List.from(
        statisticsPage.allParsedSubjects
            .where((element) => element[0].numberValue != 0),
      );
      timetablePage.lessonsList = await getThisWeeksLessons(token, code);
      setUpCalculatorPage(statisticsPage.allParsedSubjects);
    }
  }

  Future<void> getAvarages(var token, code) async {
    Crashlytics.instance.log("getAvarages");
    var headers = {
      'Authorization': 'Bearer $token',
      'User-Agent': '$agent',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/TantargyiAtlagAmi',
        headers: headers);
    if (res.statusCode != 200)
      throw Exception('get error: statusCode= ${res.statusCode}');
    if (res.statusCode == 200) {
      var bodyJson = json.decode(res.body);
      globals.avJson = bodyJson;
      avaragesPage.avarageList = await parseAvarages(globals.avJson);
    }
  }

  Future<dynamic> getSchoolList() async {
    Crashlytics.instance.log("getSchoolList");
    List<School> tempList = [];
    School tempSchool = new School();
    var client = http.Client();
    var header = {
      'User-Agent': '$agent',
      'Content-Type': 'application/json',
    };
    var res;
    try {
      res = await client
          .get('https://api.novy.vip/schoolList.json', headers: header)
          .timeout(const Duration(seconds: 10));
    } on TimeoutException catch (_) {
      print("TIMEOUT");
      return "TIMEOUT";
    } finally {
      client.close();
    }
    await sleep(1000);
    if (res.statusCode != 200) {
      print(res.statusCode);
      return res.statusCode;
    }
    List<dynamic> responseJson = json.decode(utf8.decode(res.bodyBytes));
    for (var n in responseJson) {
      tempSchool = new School();
      tempSchool.id = n["InstituteId"];
      tempSchool.name = n["Name"];
      tempSchool.code = n["InstituteCode"];
      tempSchool.url = n["Url"];
      tempSchool.city = n["City"];
      tempList.add(tempSchool);
    }
    return tempList;
  }

  Future<List<List<Lesson>>> getSpecifiedWeeksLesson(date) async {
    Crashlytics.instance.log("getSpecifiedWeeksLesson");
    String code = "";
    String decryptedPass, decryptedUser, decryptedCode, status;
    status = "";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var codeKey = encrypt.Key.fromUtf8(config.codeKey);
    final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
    final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
    decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
    code = decryptedCode;
    if (DateTime.now().isAfter(
      globals.tokenDate.add(
        Duration(minutes: 20),
      ),
    )) {
      var passKey = encrypt.Key.fromUtf8(config.passKey);
      var userKey = encrypt.Key.fromUtf8(config.userKey);
      final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
      final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
      decryptedUser = userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
      decryptedPass =
          passEncrypter.decrypt64(prefs.getString("password"), iv: iv);
      for (var i = 0; i < 2; i++) {
        status = await NetworkHelper()
            .getToken(decryptedCode, decryptedUser, decryptedPass);
      }
    }
    List<List<Lesson>> output = [];
    for (var n = 0; n < 7; n++) {
      output.add([]);
    }
    //calculate when was monday this week
    int monday = 1;
    int sunday = 7;
    DateTime now = date;
    timetablePage.fetchedDayList.add(now);
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    String startDate = now.year.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.day.toString();
    now = date;
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    String endDate = now.year.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.day.toString();
    //Make request
    var header = {
      'Authorization': 'Bearer ${globals.token}',
      'User-Agent': '$agent',
      'Content-Type': 'application/json',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/LessonAmi?fromDate=$startDate&toDate=$endDate',
        headers: header);
    if (res.statusCode != 200) {
      print(res.statusCode);
    }
    //Process response
    var decoded = json.decode(res.body);
    List<Lesson> tempLessonList = [];
    List<Lesson> tempLessonListForDB = [];
    for (var n in decoded) {
      tempLessonList.add(await setLesson(n, globals.token, code));
    }
    tempLessonList.sort((a, b) => a.startDate.compareTo(b.startDate));
    int index = 0;
    if (tempLessonList != null) {
      if (tempLessonList.length != 0) {
        int beforeDay = tempLessonList[0].startDate.day;
        //Just a matrix
        for (var n in tempLessonList) {
          if (n.startDate.day != beforeDay) {
            index++;
            beforeDay = n.startDate.day;
          }
          output[index].add(n);
          tempLessonListForDB.add(n);
        }
        await batchInsertLessons(
          tempLessonListForDB,
          lookAtDate: true,
        );
      }
    }
    return output;
  }

  Future<List<List<Lesson>>> getThisWeeksLessons(token, code) async {
    Crashlytics.instance.log("getThisWeeksLessons");
    List<List<Lesson>> output = [];
    for (var n = 0; n < 7; n++) {
      output.add([]);
    }
    //calculate when was monday this week
    int monday = 1;
    int sunday = 7;
    DateTime now = new DateTime.now();
    timetablePage.fetchedDayList.add(now);
    while (now.weekday != monday) {
      now = now.subtract(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    String startDate = now.year.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.day.toString();
    now = new DateTime.now();
    while (now.weekday != sunday) {
      now = now.add(new Duration(days: 1));
      timetablePage.fetchedDayList.add(now);
    }
    timetablePage.fetchedDayList.sort((a, b) => a.compareTo(b));
    String endDate = now.year.toString() +
        "-" +
        now.month.toString() +
        "-" +
        now.day.toString();
    //Make request
    var header = {
      'Authorization': 'Bearer $token',
      'User-Agent': '$agent',
      'Content-Type': 'application/json',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/LessonAmi?fromDate=$startDate&toDate=$endDate',
        headers: header);
    if (res.statusCode != 200) {
      print(res.statusCode);
    }
    //Process response
    var decoded = json.decode(res.body);
    List<Lesson> tempLessonList = [];
    List<Lesson> tempLessonListForDB = [];
    for (var n in decoded) {
      tempLessonList.add(await setLesson(n, token, code));
    }
    tempLessonList.sort((a, b) => a.startDate.compareTo(b.startDate));
    int index = 0;
    if (tempLessonList != null) {
      if (tempLessonList.length != 0) {
        int beforeDay = tempLessonList[0].startDate.day;
        //Just a matrix
        for (var n in tempLessonList) {
          if (n.startDate.day != beforeDay) {
            index++;
            beforeDay = n.startDate.day;
          }
          output[index].add(n);
          tempLessonListForDB.add(n);
        }
        await batchInsertLessons(tempLessonListForDB);
      }
    }
    return output;
  }

  void setUpCalculatorPage(List<List<Evals>> input) {
    Crashlytics.instance.log("setUpCalculatorPage");
    calculatorPage.dropdownValues = [];
    calculatorPage.dropdownValue = "";
    calculatorPage.avarageList = [];
    if (input != null && input != [[]]) {
      double sum, index;
      for (var n in input) {
        calculatorPage.dropdownValues.add(capitalize(n[0].subject));
        sum = 0;
        index = 0;
        for (var y in n) {
          sum += y.numberValue * double.parse(y.weight.split("%")[0]) / 100;
          index += 1 * double.parse(y.weight.split("%")[0]) / 100;
        }
        CalculatorData temp = new CalculatorData();
        temp.count = index;
        temp.sum = sum;
        calculatorPage.avarageList.add(temp);
      }
    }
    if (calculatorPage.dropdownValues.length != 0)
      calculatorPage.dropdownValue = calculatorPage.dropdownValues[0];
    else
      calculatorPage.dropdownValue = getTranslatedString("possibleNoMarks");
  }

  Future<void> getExams(token, code) async {
    Crashlytics.instance.log("getExams");
    try {
      var headers = {
        'Authorization': 'Bearer $token',
        'User-Agent': '$agent',
      };

      var res = await http.get(
          'https://$code.e-kreta.hu/mapi/api/v1/BejelentettSzamonkeresAmi?DatumTol=null&DatumIg=null',
          headers: headers);
      if (res.statusCode != 200)
        throw Exception('get error: statusCode= ${res.statusCode}');
      if (res.statusCode == 200) {
        //print("res.body ${res.body}");
        var bodyJson = json.decode(res.body);
        examsPage.allParsedExams = await parseExams(bodyJson);
        examsPage.allParsedExams
            .sort((a, b) => b.dateWrite.compareTo(a.dateWrite));
        await batchInsertExams(examsPage.allParsedExams);
        //print("examsPage.allParsedExams ${examsPage.allParsedExams}");
      }
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'getExams');
      return [];
    }
  }

  Future<Homework> setTeacherHomework(
      int hwId, String token, String code) async {
    Crashlytics.instance.log("setTeacherHomework");
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    double keepForDays = prefs.getDouble("howLongKeepDataForHw");

    var header = {
      'Authorization': 'Bearer $token',
      'User-Agent': '$agent',
      'Content-Type': 'application/json',
    };

    var res = await http.get(
        'https://$code.e-kreta.hu/mapi/api/v1/HaziFeladat/TanarHaziFeladat/$hwId',
        headers: header);
    if (res.statusCode != 200) {
      print(res.statusCode);
      return new Homework();
    }
    //Process response
    var decoded = json.decode(res.body);
    Homework temp = setHomework(decoded);
    //*Add it to the database
    //TODO batchify
    await insertHomework(temp);
    //Find the same ids
    var matchedIds = homeworkPage.globalHomework.where((element) {
      return element.id == temp.id;
    });

    //Should we keep it?
    DateTime afterDue = temp.dueDate;
    if (keepForDays != -1) {
      afterDue = afterDue.add(Duration(days: keepForDays.toInt()));
    }

    if (matchedIds.length == 0) {
      if (afterDue.compareTo(DateTime.now()) >= 0) {
        homeworkPage.globalHomework.add(temp);
      }
    } else {
      var matchedindex = homeworkPage.globalHomework.indexWhere((element) {
        return element.id == temp.id;
      });
      if (afterDue.compareTo(DateTime.now()) >= 0) {
        homeworkPage.globalHomework[matchedindex] = temp;
      }
    }
    homeworkPage.globalHomework.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return temp;
  }
}
