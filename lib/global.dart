import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io' show Platform;
import 'data/database/databaseHelper.dart';
import 'data/models/student.dart';
import 'package:novynaplo/ui/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/ui/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/ui/screens/marks_tab.dart' as marksPage;
import 'package:novynaplo/ui/screens/homework_tab.dart' as homeworkPage;
import 'package:novynaplo/ui/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/ui/screens/events_tab.dart' as eventsPage;
import 'package:novynaplo/ui/screens/absences_tab.dart' as absencesPage;
import 'package:novynaplo/ui/screens/timetable_tab.dart' as timetablePage;

//Variables used globally;
//* Session
SharedPreferences prefs; //Global shared preferences
bool didFetch = false; //True if we fetched the data, false if we didn't
bool isLoaded =
    false; //Stores whether the app has passed the loading stage, this variable is used to delay and show notifications
Database db; //Global database access
Student currentUser = Student(); //The currently shown user
//* "Permanent"
String markCardSubtitle = "Téma"; //Marks subtitle
String markCardTheme = "Értékelés nagysága"; //Marks color theme
String markCardConstColor = "Orange"; //If theme is constant what color is it
String lessonCardSubtitle = "Tanterem"; //Lesson card's subtitle
String howManyGraph =
    "Kör diagram"; //What should we show? A pie- or a bar-chart
bool adsEnabled = false; //Do we have to show ads
bool chartAnimations = true; //Do we need to animate the charts
bool shouldVirtualMarksCollapse = false; //Should we group virtual marks
bool backgroundFetch = true; //Should we fetch data in the background?
bool backgroundFetchCanWakeUpPhone =
    true; //Should we wake the phone up to fetch data?
bool backgroundFetchOnCellular = false; //Should we fetch on cellular data
bool verCheckOnStart =
    true; //Should we check for updates upon startup, can be slow, but reminds user to update
int adModifier = 0;
int extraSpaceUnderStat = 0; //How many extra padding do we need?
int fetchPeriod = 60; //After how many minutes should we fetch the new data?
bool notifications = true; //Should we send notifications
double howLongKeepDataForHw = 7; //How long should we show homeworks (in days)
bool colorAvsInStatisctics =
    true; //Should we color the name of subjects based on their values
String language =
    "hu"; //Language to show stuff in, defualts to hungarian as you can see
bool collapseNotifications =
    true; //Automatically collapse all notifications, on by default

Future<void> resetAllGlobals() async {
  await DatabaseHelper.clearAllTables();
  await prefs.clear();
  await prefs.setBool("ads", adsEnabled);
  await prefs.setBool("isNew", true);
  didFetch = false;
  marksPage.allParsedByDate = [];
  marksPage.allParsedBySubject = [];
  statisticsPage.allParsedSubjects = [];
  statisticsPage.allParsedSubjectsWithoutZeros = [];
  noticesPage.allParsedNotices = [];
  eventsPage.allParsedEvents = [];
  absencesPage.allParsedAbsences = [];
  homeworkPage.globalHomework = [];
  examsPage.allParsedExams = [];
  timetablePage.lessonsList = [];
}

Future<void> setGlobals() async {
  prefs = await SharedPreferences.getInstance();
  if (prefs.getString("FirstOpenTime") == null) {
    await prefs.setString("FirstOpenTime", DateTime.now().toString());
    await prefs.setString("LastAsked", DateTime.now().toString());
  }

  if (prefs.getBool("getVersion") != null) {
    verCheckOnStart = prefs.getBool("getVersion");
  } else {
    await prefs.setBool("getVersion", true);
    verCheckOnStart = true;
  }

  if (prefs.getBool("ShouldAsk") == null) {
    await prefs.setBool("ShouldAsk", true);
  }

  if (prefs.getBool("ads") != null) {
    FirebaseCrashlytics.instance.setCustomKey("Ads", prefs.getBool("ads"));
    adsEnabled = prefs.getBool("ads");
    if (adsEnabled) adModifier = 1;
  }
  if (prefs.getString("Language") != null) {
    language = prefs.getString("Language");
  } else {
    //String countryCode = Platform.localeName.split('_')[0];
    String languageCode = Platform.localeName.split('_')[1];
    if (languageCode.toLowerCase().contains('hu')) {
      language = "hu";
    } else {
      language = "en";
    }
    prefs.setString("Language", language);
  }
  FirebaseAnalytics().setUserProperty(
    name: "Language",
    value: language,
  );
  FirebaseCrashlytics.instance.setCustomKey("Language", language);

  if (prefs.getBool("colorAvsInStatisctics") != null) {
    colorAvsInStatisctics = prefs.getBool("colorAvsInStatisctics");
  } else {
    await prefs.setBool("colorAvsInStatisctics", true);
    colorAvsInStatisctics = true;
  }

  if (prefs.getDouble("howLongKeepDataForHw") != null) {
    howLongKeepDataForHw = prefs.getDouble("howLongKeepDataForHw");
  } else {
    prefs.setDouble("howLongKeepDataForHw", 7);
    howLongKeepDataForHw = 7;
  }
  FirebaseCrashlytics.instance
      .setCustomKey("howLongKeepDataForHw", howLongKeepDataForHw);

  if (prefs.getBool("notifications") != null) {
    notifications = prefs.getBool("notifications");
  } else {
    await prefs.setBool("notifications", true);
    notifications = true;
  }
  FirebaseCrashlytics.instance.setCustomKey("notifications", notifications);
  FirebaseAnalytics().setUserProperty(
    name: "Notifications",
    value: notifications ? "ON" : "OFF",
  );

  if (prefs.getBool("backgroundFetchOnCellular") != null) {
    backgroundFetchOnCellular = prefs.getBool("backgroundFetchOnCellular");
  } else {
    await prefs.setBool("backgroundFetchOnCellular", false);
    backgroundFetchOnCellular = false;
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "backgroundFetchOnCellular",
    backgroundFetchOnCellular,
  );

  if (prefs.getInt("fetchPeriod") == null) {
    fetchPeriod = 60;
    prefs.setInt("fetchPeriod", 60);
  } else {
    fetchPeriod = prefs.getInt("fetchPeriod");
  }

  if (prefs.getBool("backgroundFetch") == null) {
    backgroundFetch = true;
    await prefs.setBool("backgroundFetch", true);
  } else {
    backgroundFetch = prefs.getBool("backgroundFetch");
  }
  FirebaseCrashlytics.instance.setCustomKey("backgroundFetch", backgroundFetch);

  if (prefs.getBool("backgroundFetchCanWakeUpPhone") == null) {
    backgroundFetchCanWakeUpPhone = true;
    await prefs.setBool("backgroundFetchCanWakeUpPhone", true);
  } else {
    backgroundFetchCanWakeUpPhone =
        prefs.getBool("backgroundFetchCanWakeUpPhone");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "backgroundFetchCanWakeUpPhone",
    backgroundFetchCanWakeUpPhone,
  );

  if (prefs.getString("howManyGraph") == null) {
    howManyGraph = "Kör diagram";
    prefs.setString("howManyGraph", howManyGraph);
  } else {
    howManyGraph = prefs.getString("howManyGraph");
  }
  FirebaseCrashlytics.instance.setCustomKey("howManyGraph", howManyGraph);

  if (prefs.getInt("extraSpaceUnderStat") != null) {
    extraSpaceUnderStat = prefs.getInt("extraSpaceUnderStat");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("extraSpaceUnderStat", extraSpaceUnderStat);

  if (prefs.getBool("shouldVirtualMarksCollapse") == null) {
    shouldVirtualMarksCollapse = false;
    await prefs.setBool("shouldVirtualMarksCollapse", false);
  } else {
    shouldVirtualMarksCollapse = prefs.getBool("shouldVirtualMarksCollapse");
  }
  FirebaseCrashlytics.instance.setCustomKey(
    "shouldVirtualMarksCollapse",
    shouldVirtualMarksCollapse,
  );

  if (prefs.getString("markCardSubtitle") == null) {
    markCardSubtitle = "Téma";
    prefs.setString("markCardSubtitle", "Téma");
  } else {
    markCardSubtitle = prefs.getString("markCardSubtitle");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("markCardSubtitle", markCardSubtitle);

  if (prefs.getString("markCardConstColor") == null) {
    markCardConstColor = "Green";
    prefs.setString("markCardConstColor", "Green");
  } else {
    markCardConstColor = prefs.getString("markCardConstColor");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("markCardConstColor", markCardConstColor);

  if (prefs.getString("lessonCardSubtitle") == null) {
    lessonCardSubtitle = "Tanterem";
    prefs.setString("lessonCardSubtitle", "Tanterem");
  } else {
    lessonCardSubtitle = prefs.getString("lessonCardSubtitle");
  }
  FirebaseCrashlytics.instance
      .setCustomKey("lessonCardSubtitle", lessonCardSubtitle);

  if (prefs.getString("markCardTheme") == null) {
    markCardTheme = "Véletlenszerű";
    prefs.setString("markCardTheme", "Véletlenszerű");
  } else {
    markCardTheme = prefs.getString("markCardTheme");
  }
  FirebaseCrashlytics.instance.setCustomKey("markCardTheme", markCardTheme);

  if (prefs.getBool("chartAnimations") == null) {
    chartAnimations = true;
    await prefs.setBool("chartAnimations", true);
  } else {
    chartAnimations = prefs.getBool("chartAnimations");
  }
  FirebaseCrashlytics.instance.setCustomKey("ChartAnimations", chartAnimations);

  if (prefs.getBool("collapseNotifications") == null) {
    collapseNotifications = true;
    await prefs.setBool("collapseNotifications", true);
  } else {
    collapseNotifications = prefs.getBool("collapseNotifications");
  }

  FirebaseCrashlytics.instance
      .setCustomKey("collapseNotifications", collapseNotifications);
}
