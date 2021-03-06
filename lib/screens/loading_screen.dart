import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:in_app_review/in_app_review.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/helpers/notificationHelper.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/screens/avarages_tab.dart' as avaragesPage;
import 'package:novynaplo/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'dart:io';
import 'package:novynaplo/database/getSql.dart';

var passKey = encrypt.Key.fromUtf8(config.passKey);
var codeKey = encrypt.Key.fromUtf8(config.codeKey);
var userKey = encrypt.Key.fromUtf8(config.userKey);
final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
String decryptedCode,
    decryptedUser,
    decryptedPass,
    loadingText = "${getTranslatedString("plsWait")}...";
var status;
String agent = config.currAgent;
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      await globals.setGlobals();
      if (prefs.getString("iv") == null ||
          prefs.getString("code") == null ||
          prefs.getString("password") == null ||
          prefs.getString("user") == null) {
        Navigator.pushReplacementNamed(context, LoginPage.tag);
        prefs.setBool("isNew", true);
        prefs.setBool("isNotNew", true);
        return;
      }
      setState(() {
        loadingText = getTranslatedString("checkVersion");
      });
      Crashlytics.instance.setString("Version", config.currentAppVersionCode);
      if (globals.verCheckOnStart) {
        await getVersion();
      }
      if (prefs.getString("FirstOpenTime") != null) {
        if (DateTime.parse(prefs.getString("FirstOpenTime"))
                    .difference(DateTime.now()) >=
                Duration(days: 14) &&
            prefs.getBool("ShouldAsk") &&
            DateTime.parse(prefs.getString("LastAsked"))
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
      if (prefs.getBool("ads") != null) {
        Crashlytics.instance.setBool("Ads", prefs.getBool("ads"));
        if (prefs.getBool("ads")) {
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
      //MARKS
      setState(() {
        loadingText = getTranslatedString("readMarks");
      });
      List<Evals> tempEvals = await getAllEvals();
      marksPage.colors = getRandomColors(tempEvals.length);
      marksPage.allParsedByDate = tempEvals;
      marksPage.allParsedBySubject = sortByDateAndSubject(tempEvals);
      //Homework
      setState(() {
        loadingText = getTranslatedString("readHw");
      });
      homeworkPage.globalHomework = await getAllHomework(ignoreDue: false);
      homeworkPage.globalHomework
          .sort((a, b) => a.dueDate.compareTo(b.dueDate));
      //Notices
      setState(() {
        loadingText = getTranslatedString("readNotices");
      });
      noticesPage.allParsedNotices = await getAllNotices();
      //Avarages
      setState(() {
        loadingText = getTranslatedString("readAvs");
      });
      avaragesPage.avarageList = await getAllAvarages();
      //Statisztika
      statisticsPage.allParsedSubjects =
          categorizeSubjectsFromEvals(marksPage.allParsedByDate);
      statisticsPage.allParsedSubjectsWithoutZeros = List.from(
        statisticsPage.allParsedSubjects
            .where((element) => element[0].numberValue != 0),
      );
      NetworkHelper().setUpCalculatorPage(statisticsPage.allParsedSubjects);
      //Timetable
      setState(() {
        loadingText = getTranslatedString("readTimetable");
      });
      timetablePage.lessonsList =
          await makeTimetableMatrix(await getAllTimetable());
      //Sort
      marksPage.allParsedByDate
          .sort((a, b) => b.createDateString.compareTo(a.createDateString));
      //Exams
      setState(() {
        loadingText = getTranslatedString("readExam");
      });
      examsPage.allParsedExams = await getAllExams();
      examsPage.allParsedExams
          .sort((a, b) => b.dateWrite.compareTo(a.dateWrite));
      //Events
      setState(() {
        loadingText = getTranslatedString("readEvents");
      });
      eventsPage.allParsedEvents = await getAllEvents();
      eventsPage.allParsedEvents.sort((a, b) => b.date.compareTo(a.date));
      //DONE
      setState(() {
        loadingText = "${getTranslatedString("almReady")}!";
      });
      if (globals.notificationAppLaunchDetails.didNotificationLaunchApp) {
        //print("NotifLaunchApp");
        if (globals.notificationAppLaunchDetails.payload == "teszt") {
          //print("TESZT");
          Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
          showTesztNotificationDialog();
        } else {
          //print(globals.notificationAppLaunchDetails.payload);
          marksTab.redirectPayload = true;
          await sleep(10);
          Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
        }
      } else {
        Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
      }
      FirebaseAnalytics().logEvent(name: "login");
      return;
    } catch (e, s) {
      Crashlytics.instance.recordError(e, s, context: 'onLoad');
      await _ackAlert(
        context,
        "${getTranslatedString("errReadMem")} ($e, $s) ${getTranslatedString("restartApp")}",
      );
      Navigator.pushReplacementNamed(context, LoginPage.tag);
      prefs.setBool("isNew", true);
      prefs.setBool("isNotNew", true);
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
    globals.globalContext = context;
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            Navigator.of(context).pop();
            prefs.setString("LastAsked", DateTime.now().toString());
            prefs.setBool("ShouldAsk", true);
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
                  prefs.setBool("ShouldAsk", false);
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
                  prefs.setString("LastAsked", DateTime.now().toString());
                  prefs.setBool("ShouldAsk", true);
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
                  prefs.setBool("ShouldAsk", false);
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
