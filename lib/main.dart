import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/errorHandlingHelper.dart';
import 'package:novynaplo/helpers/themeHelper.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:novynaplo/screens/avarages_tab.dart';
import 'package:novynaplo/screens/events_tab.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/reports_tab.dart';
import 'package:novynaplo/screens/settings/settings_tab.dart';
import 'package:novynaplo/screens/login_page.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/statistics_tab.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:novynaplo/screens/calculator_tab.dart';
import 'package:novynaplo/screens/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/screens/loading_screen.dart';
import 'package:novynaplo/screens/homework_tab.dart';
import 'package:novynaplo/screens/exams_tab.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:novynaplo/helpers/backgroundFetchHelper.dart'
    as backgroundFetchHelper;
import 'dart:io' show Platform;

FirebaseAnalytics analytics = FirebaseAnalytics();
final navigatorKey = GlobalKey<NavigatorState>();
bool isNew = true;
bool isNotNew = false;
int fetchAlarmID = 0; //We're using 0, because why not
Map<String, WidgetBuilder> routes;

void main() async {
  //Change to true if needed
  Crashlytics.instance.enableInDevMode = false;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.getBool("isNew") == false) {
    isNew = false;
  } else {
    if (prefs.getBool("isNotNew") != null) {
      if (prefs.getBool("isNotNew") == true) {
        isNotNew = true;
      }
    }
    if (isNotNew == false) {
      String languageCode = Platform.localeName.split('_')[1];
      if (languageCode.toLowerCase().contains('hu')) {
        globals.language = "hu";
      } else {
        globals.language = "en";
      }
      await prefs.setString("FirstOpenTime", DateTime.now().toString());
      await prefs.setString("Language", globals.language);
      await prefs.setBool("getVersion", true);
    }
  }
  routes = <String, WidgetBuilder>{
    "/": (context) =>
        isNew && isNotNew == false ? WelcomeScreen() : LoadingPage(),
    LoginPage.tag: (context) => LoginPage(),
    MarksTab.tag: (context) => MarksTab(),
    AvaragesTab.tag: (context) => AvaragesTab(),
    SettingsTab.tag: (context) => SettingsTab(),
    NoticesTab.tag: (context) => NoticesTab(),
    StatisticsTab.tag: (context) => StatisticsTab(),
    TimetableTab.tag: (context) => TimetableTab(),
    CalculatorTab.tag: (context) => CalculatorTab(),
    HomeworkTab.tag: (context) => HomeworkTab(),
    ExamsTab.tag: (context) => ExamsTab(),
    EventsTab.tag: (context) => EventsTab(),
    ReportsTab.tag: (context) => ReportsTab(),
  };
  runZoned(() async {
    await mainSql.initDatabase();
    await notifications.setupNotifications();
    runApp(
      MyApp(),
    );
    globals.fetchPeriod =
        prefs.getInt("fetchPeriod") == null ? 60 : prefs.getInt("fetchPeriod");
    globals.backgroundFetch = prefs.getBool("backgroundFetch");
    if (globals.backgroundFetch == null ? false : globals.backgroundFetch) {
      globals.backgroundFetchCanWakeUpPhone =
          prefs.getBool("backgroundFetchCanWakeUpPhone") == null
              ? true
              : prefs.getBool("backgroundFetchCanWakeUpPhone");
      await AndroidAlarmManager.initialize();
      await AndroidAlarmManager.cancel(fetchAlarmID);
      await sleep(1000);
      await AndroidAlarmManager.periodic(
        Duration(minutes: globals.fetchPeriod),
        fetchAlarmID,
        backgroundFetchHelper.backgroundFetch,
        wakeup: globals.backgroundFetchCanWakeUpPhone,
        rescheduleOnReboot: globals.backgroundFetchCanWakeUpPhone,
      );
    }
  }, onError: Crashlytics.instance.recordError);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = ErrorMessageBuilder.build();
    globals.globalContext = context;
    return new DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => ThemeHelper().getTheme(brightness),
      themedWidgetBuilder: (context, theme) {
        return MaterialApp(
          builder: (BuildContext context, Widget widget) {
            ErrorWidget.builder = ErrorMessageBuilder.build();
            return widget;
          },
          navigatorKey: navigatorKey,
          theme: theme,
          title: 'Novy Napló',
          debugShowCheckedModeBanner: false,
          routes: routes,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
        );
      },
    );
  }
}
