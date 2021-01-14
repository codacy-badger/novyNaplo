import 'dart:io';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:in_app_review/in_app_review.dart';
import 'package:novynaplo/data/database/databaseHelper.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/lesson.dart';
import 'package:novynaplo/data/models/student.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseMarks.dart';
import 'package:novynaplo/helpers/logicAndMath/parsing/parseTimetable.dart';
import 'package:novynaplo/helpers/logicAndMath/setUpMarkCalculator.dart';
import 'package:novynaplo/helpers/ui/getRandomColors.dart';
import 'package:novynaplo/ui/screens/login_page.dart' as loginPage;
import 'package:novynaplo/i18n/translationProvider.dart';
import 'package:novynaplo/helpers/ui/adHelper.dart';
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/ui/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;
import 'package:path/path.dart' as fpath;
import 'package:sqflite/sqflite.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

String loadingText = "${getTranslatedString("plsWait")}...";
var status;
String agent = config.userAgent;
var response;
bool hasError = false;
int tokenIndex = 0;

class LoadingPage extends StatefulWidget {
  static String tag = 'loading-page';
  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  //Runs after initState
  void onLoad(var context) async {
    FirebaseCrashlytics.instance.log("Shown Loading screen");
    try {
      await globals.setGlobals();
      List<Student> allUsers = await DatabaseHelper.getAllUsers();
      if (allUsers.length <= 0) {
        //Yes I know I misspelled it, live with it
        String path =
            fpath.join(await getDatabasesPath(), 'NovyNalploDatabase.db');
        File file = new File(path);
        if (file.existsSync()) {
          //file.delete();
          setState(() {
            loadingText = getTranslatedString("migrateDB");
          });
          if (globals.prefs.getString("code") == null) {
            Navigator.pushReplacementNamed(context, loginPage.LoginPage.tag);
            return;
          } else {
            FirebaseAnalytics().logEvent(
              name: "migrateDB",
            );
            var decryptedPass, decryptedUser, decryptedCode;
            final iv = encrypt.IV.fromBase64(globals.prefs.getString("iv"));
            var passKey = encrypt.Key.fromUtf8(config.passKey);
            var codeKey = encrypt.Key.fromUtf8(config.codeKey);
            var userKey = encrypt.Key.fromUtf8(config.userKey);
            final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
            final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
            final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
            decryptedCode = codeEncrypter.decrypt64(
              globals.prefs.getString("code"),
              iv: iv,
            );
            decryptedUser = userEncrypter.decrypt64(
              globals.prefs.getString("user"),
              iv: iv,
            );
            decryptedPass = passEncrypter.decrypt64(
              globals.prefs.getString("password"),
              iv: iv,
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => loginPage.LoginPage(
                  isAutoFill: true,
                  userDetails: Student(
                    school: decryptedCode,
                    username: decryptedUser,
                    password: decryptedPass,
                  ),
                ),
              ),
            );
            return;
          }
        } else {
          Navigator.pushReplacementNamed(context, loginPage.LoginPage.tag);
          return;
        }
      }
      globals.currentUser = allUsers.firstWhere(
        (element) => element.current,
        orElse: () => allUsers[0],
      );
      //FIXME status szöveg hozzáadása
      setState(() {
        loadingText = getTranslatedString("checkVersion");
      });
      FirebaseCrashlytics.instance
          .setCustomKey("Version", config.currentAppVersionCode);
      if (globals.verCheckOnStart) {
        await getVersion();
      }
      if (globals.prefs.getString("FirstOpenTime") != null) {
        if (DateTime.parse(globals.prefs.getString("FirstOpenTime"))
                    .difference(DateTime.now()) >=
                Duration(days: 14) &&
            globals.prefs.getBool("ShouldAsk") &&
            DateTime.parse(globals.prefs.getString("LastAsked"))
                    .difference(DateTime.now()) >=
                Duration(days: 2) &&
            config.isAppPlaystoreRelease) {
          setState(() {
            loadingText = getTranslatedString("reviewProcess");
          });
          await showReviewWindow(context);
        }
      }
      //Load ADS
      if (globals.prefs.getBool("ads") != null) {
        FirebaseCrashlytics.instance
            .setCustomKey("Ads", globals.prefs.getBool("ads"));
        if (globals.prefs.getBool("ads")) {
          adBanner.load();
          adBanner.show(
            anchorType: AnchorType.bottom,
          );
          globals.adsEnabled = true;
          globals.adModifier = 1;
        } else {
          globals.adModifier = 0;
          globals.adsEnabled = false;
        }
      } else {
        globals.adsEnabled = false;
      }
      //*Marks
      setState(() {
        loadingText = getTranslatedString("readMarks");
      });
      List<Evals> tempEvals = await DatabaseHelper.getAllEvals();
      marksPage.colors = getRandomColors(tempEvals.length);
      marksPage.allParsedByDate = tempEvals;
      marksPage.allParsedBySubject = sortByDateAndSubject(tempEvals);
      //*Load variables required to show statistics
      setState(() {
        loadingText = getTranslatedString("setUpStatistics");
      });
      statisticsPage.allParsedSubjects =
          categorizeSubjectsFromEvals(marksPage.allParsedByDate);
      statisticsPage.allParsedSubjectsWithoutZeros = List.from(
        statisticsPage.allParsedSubjects
            .where((element) => element[0].numberValue != 0),
      );
      //*Load variables required to use the markCalculator
      setState(() {
        loadingText = getTranslatedString("setUpMarkCalc");
      });
      setUpCalculatorPage(statisticsPage.allParsedSubjects);
      //*Notices
      setState(() {
        loadingText = getTranslatedString("readNotices");
      });
      noticesPage.allParsedNotices = await DatabaseHelper.getAllNotices();
      //*Events
      setState(() {
        loadingText = getTranslatedString("readEvents");
      });
      eventsPage.allParsedEvents = await DatabaseHelper.getAllEvents();
      //*Absences
      setState(() {
        loadingText = getTranslatedString("readAbsences");
      });
      absencesPage.allParsedAbsences =
          await DatabaseHelper.getAllAbsencesMatrix();
      //*Homework
      setState(() {
        loadingText = getTranslatedString("readHw");
      });
      homeworkPage.globalHomework =
          await DatabaseHelper.getAllHomework(ignoreDue: false);
      //*Exams
      setState(() {
        loadingText = getTranslatedString("readHw");
      });
      examsPage.allParsedExams = await DatabaseHelper.getAllExams();
      //*Timetable
      //?EXAMS AND HOMEWORK MUST BE LOADED BEFORE TIMETABLE
      setState(() {
        loadingText = getTranslatedString("readTimetable");
      });
      List<Lesson> tempLessonList = await DatabaseHelper.getAllTimetable();
      timetablePage.lessonsList = await makeTimetableMatrix(tempLessonList);
      //*Done
      FirebaseAnalytics().logEvent(name: "login");
      Navigator.pushReplacementNamed(context, marksPage.MarksTab.tag);
      globals.isLoaded = true;
      return;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, reason: 'onLoad');
      await _ackAlert(
        context,
        "${getTranslatedString("errReadMem")} ($e, $s) ${getTranslatedString("restartApp")}",
      );
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: config.adMob);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onLoad(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = CircleAvatar(
      backgroundColor: Colors.grey,
      radius: 75.0,
      child: Image.asset('assets/home.png'),
    );
    return Scaffold(
      body: Center(
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 5.0),
            Center(
              child: Text(
                getTranslatedString("Welcome to novynaplo"),
                style: TextStyle(fontSize: 28),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                "Ver: " + config.currentAppVersionCode,
                style: TextStyle(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            SpinKitPouringHourglass(color: Colors.lightBlueAccent),
            SizedBox(height: 10),
            Text(
              loadingText,
              style: TextStyle(color: Colors.blueAccent, fontSize: 20),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  Future<void> _ackAlert(BuildContext context, String content) async {
    hasError = true;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(getTranslatedString("status")),
          content: Text(content),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showReviewWindow(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            globals.prefs.setString("LastAsked", DateTime.now().toString());
            globals.prefs.setBool("ShouldAsk", true);
            FirebaseAnalytics().logEvent(
              name: "seenReviewPopUp",
              parameters: {"Action": "Later"},
            );
            return true;
          },
          child: AlertDialog(
            title: Text(getTranslatedString("review")),
            content: Text(getTranslatedString("plsRateUs")),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  getTranslatedString("yes"),
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () async {
                  final InAppReview inAppReview = InAppReview.instance;

                  if (await inAppReview.isAvailable()) {
                    inAppReview.requestReview();
                  } else {
                    inAppReview.openStoreListing();
                  }
                  globals.prefs.setBool("ShouldAsk", false);
                  FirebaseAnalytics().logEvent(
                    name: "ratedApp",
                  );
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text(
                  getTranslatedString("later"),
                  style: TextStyle(color: Colors.orange),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  globals.prefs
                      .setString("LastAsked", DateTime.now().toString());
                  globals.prefs.setBool("ShouldAsk", true);
                  FirebaseAnalytics().logEvent(
                    name: "seenReviewPopUp",
                    parameters: {"Action": "Later"},
                  );
                },
              ),
              FlatButton(
                child: Text(
                  getTranslatedString("never"),
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  globals.prefs.setBool("ShouldAsk", false);
                  Navigator.of(context).pop();
                  FirebaseAnalytics().logEvent(
                    name: "seenReviewPopUp",
                    parameters: {"Action": "Never"},
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}