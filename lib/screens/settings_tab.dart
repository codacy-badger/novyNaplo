import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/database/getSql.dart';
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:novynaplo/screens/events_tab.dart';
import 'package:novynaplo/screens/homework_tab.dart' as homeworkPage;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/database/deleteSql.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/login_page.dart' as login;
import 'package:novynaplo/main.dart' as main;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/helpers/themeHelper.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:novynaplo/screens/marks_tab.dart';
import 'package:novynaplo/screens/homework_tab.dart';
import 'package:novynaplo/screens/notices_tab.dart';
import 'package:novynaplo/screens/timetable_tab.dart';
import 'package:novynaplo/helpers/backgroundFetchHelper.dart'
    as backgroundFetchHelper;
import 'package:novynaplo/database/mainSql.dart' as mainSql;
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:novynaplo/screens/exams_tab.dart' as examsPage;
import 'package:novynaplo/config.dart' as config;

String latestGithub = "";
String latestPlayStore = "";
final _formKey = GlobalKey<FormState>(debugLabel: '_FormKey');
final _formKeyTwo = GlobalKey<FormState>(debugLabel: '_FormKey2');
String dropDown;
String statDropDown = globals.statChart;
String howManyGraphDropDown = globals.howManyGraph;
String markDropdown = globals.markCardSubtitle;
String lessonDropdown = globals.lessonCardSubtitle;
String markThemeDropdown = globals.markCardTheme;
String constColorDropdown = globals.markCardConstColor;
bool adsSwitch = globals.adsEnabled;
bool animationSwitch = globals.chartAnimations;
bool notificationSwitch = false;
int indexModifier = 0;
bool shouldCollapseSwitch = globals.shouldVirtualMarksCollapse;
bool showAllAvsInStatsSwitch = globals.showAllAvsInStats;
TextEditingController extraSpaceUnderStatController =
    TextEditingController(text: globals.extraSpaceUnderStat.toString());
TextEditingController fetchPeriodController =
    TextEditingController(text: globals.fetchPeriod.toString());

class SettingsTab extends StatefulWidget {
  static String tag = 'settings';
  static String title = getTranslatedString("settings");

  const SettingsTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(SettingsTab.title),
      ),
      drawer: getDrawer(SettingsTab.tag, context),
      body: SettingsBody(),
    );
  }
}

class SettingsBody extends StatefulWidget {
  SettingsBody({Key key}) : super(key: key);

  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  void _onLoad(var context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (main.isNew) {
      main.isNew = false;
      setState(() {
        adsSwitch = true;
        globals.adsEnabled = true;
        globals.adModifier = 1;
      });
      prefs.setBool("ads", true);
      showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return AdsDialog();
          });
    }
    if (globals.markCardTheme == "Egyszínű") {
      setState(() {
        indexModifier = 1;
      });
    } else {
      setState(() {
        indexModifier = 0;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLoad(context));
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    if (Theme.of(context).brightness == Brightness.light) {
      dropDown = "Világos";
    } else {
      dropDown = "Sötét";
    }
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: 11 + globals.adModifier,
      // ignore: missing_return
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UIsettings()),
                      );
                    },
                    icon: Row(
                      children: <Widget>[
                        Icon(
                          MdiIcons.televisionGuide,
                          color: Colors.black,
                        ),
                        SizedBox(height: 1, width: 5),
                        Icon(
                          MdiIcons.translate,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    label: Text('UI ${getTranslatedString("settings")}',
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 1) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MarksTabSettings()),
                      );
                    },
                    icon: Icon(
                      Icons.create,
                      color: Colors.black,
                    ),
                    label: Text(getTranslatedString("marksTabSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 2) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TimetableSettings()),
                      );
                    },
                    icon: Icon(Icons.today, color: Colors.black),
                    label: Text(getTranslatedString("timetableSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 3) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomeworkSettingsTab()),
                      );
                    },
                    icon:
                        Icon(MdiIcons.bagPersonalOutline, color: Colors.black),
                    label: Text(getTranslatedString("homeworkSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 4) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => StatisticSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.chartScatterPlotHexbin,
                        color: Colors.black),
                    label: Text(getTranslatedString("statisticSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 5) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CalculatorSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.calculator, color: Colors.black),
                    label: Text(getTranslatedString("markCalculatorSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 6) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                NetworkAndNotificationSettings()),
                      );
                    },
                    icon: Row(
                      children: <Widget>[
                        Icon(MdiIcons.accessPointNetwork, color: Colors.black),
                        SizedBox(width: 2),
                        Icon(MdiIcons.bellRing, color: Colors.black),
                      ],
                    ),
                    label: Text(
                        getTranslatedString("networkAndNotificationSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 7) {
          return ListTile(
            title: Center(
              child: SizedBox(
                height: 38,
                width: double.infinity,
                child: RaisedButton.icon(
                    color: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeveloperSettings()),
                      );
                    },
                    icon: Icon(MdiIcons.codeTagsCheck, color: Colors.black),
                    label: Text(getTranslatedString("developerSettings"),
                        style: TextStyle(color: Colors.black))),
              ),
            ),
          );
        } else if (index == 8) {
          return ListTile(
            title: Center(
                child: Column(children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await _ackAlert(context,
                              "${getTranslatedString("youCanWriteToTheFollowingEmail")}\nnovysoftware@gmail.com");
                        },
                        icon: Icon(MdiIcons.emailSend, color: Colors.black),
                        label: Text('Bug report (Email)',
                            style: TextStyle(color: Colors.black)))),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          String link =
                              "https://github.com/NovySoft/novyNaplo/issues/new/choose";
                          if (await canLaunch(link)) {
                            await launch(link);
                          } else {
                            FirebaseAnalytics().logEvent(
                              name: "LinkFail",
                              parameters: {"link": link},
                            );
                            throw 'Could not launch $link';
                          }
                        },
                        icon: Icon(Icons.bug_report, color: Colors.black),
                        label: Text('Bug report (Github)',
                            style: TextStyle(color: Colors.black)))),
              ),
            ])),
          );
        } else if (index == 9) {
          return ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          showAboutDialog(
                            context: context,
                            applicationName: "Novy Napló",
                            applicationVersion: config.currentAppVersionCode,
                            applicationLegalese:
                                "This application is contributed under the MIT license",
                            applicationIcon: Image.asset(
                              "assets/icon/icon.png",
                              height: 100,
                              width: 100,
                            ),
                          );
                        },
                        icon: Icon(MdiIcons.cellphoneInformation,
                            color: Colors.black),
                        label: Text(getTranslatedString("appInfo"),
                            style: TextStyle(color: Colors.black)))),
              ),
            ),
          );
        } else if (index == 10) {
          return ListTile(
            title: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return LogOutDialog();
                              });
                        },
                        icon: Icon(MdiIcons.logout, color: Colors.black),
                        label: Text(getTranslatedString("logOut"),
                            style: TextStyle(color: Colors.black)))),
              ),
            ),
          );
        } else {
          return SizedBox(height: 100);
        }
      },
    );
  }
}

class TimetableSettings extends StatefulWidget {
  @override
  _TimetableSettingsState createState() => _TimetableSettingsState();
}

class _TimetableSettingsState extends State<TimetableSettings> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("timetableSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 1,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("${getTranslatedString("timetableSubtitle")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Tanterem",
                        child: Text(
                          getTranslatedString("classroom"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Óra témája",
                        child: Text(
                          getTranslatedString("theme"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Tanár",
                        child: Text(
                          getTranslatedString("teacher"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Kezdés-Bejezés",
                        child: Text(
                          getTranslatedString("startStop"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Időtartam",
                        child: Text(
                          getTranslatedString("period"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance
                          .setString("lessonCardSubtitle", value);
                      prefs.setString("lessonCardSubtitle", value);
                      globals.lessonCardSubtitle = value;
                      setState(() {
                        lessonDropdown = value;
                      });
                    },
                    value: lessonDropdown,
                  ),
                );
                break;
              default:
            }
            return SizedBox(height: 10, width: 10);
          }),
    );
  }
}

class MarksTabSettings extends StatefulWidget {
  @override
  _MarksTabSettingsState createState() => _MarksTabSettingsState();
}

class _MarksTabSettingsState extends State<MarksTabSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("marksTabSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 2 + indexModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 1:
                return ListTile(
                  title: Text("${getTranslatedString("marksCardColorTheme")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Véletlenszerű",
                        child: Text(
                          getTranslatedString("random"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Értékelés nagysága",
                        child: Text(
                          getTranslatedString("evaulationValue"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Egyszínű",
                        child: Text(
                          getTranslatedString("oneColor"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Színátmenetes",
                        child: Text(
                          getTranslatedString("gradient"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance.setString("markCardTheme", value);
                      prefs.setString("markCardTheme", value);
                      globals.markCardTheme = value;
                      setState(() {
                        markThemeDropdown = value;
                      });
                      if (value == "Egyszínű") {
                        setState(() {
                          indexModifier = 1;
                        });
                      } else {
                        setState(() {
                          indexModifier = 0;
                        });
                      }
                    },
                    value: markThemeDropdown,
                  ),
                );
                break;
              case 0:
                return ListTile(
                  title: Text("${getTranslatedString("marksCardSubtitle")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Téma",
                        child: Text(
                          getTranslatedString("theme"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Tanár",
                        child: Text(
                          getTranslatedString("teacher"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Súly",
                        child: Text(
                          getTranslatedString("weight"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Egyszerűsített Dátum",
                        child: Text(
                          getTranslatedString("simplifiedDate"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Pontos Dátum",
                        child: Text(
                          getTranslatedString("exactDate"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance.setString("markCardSubtitle", value);
                      prefs.setString("markCardSubtitle", value);
                      globals.markCardSubtitle = value;
                      setState(() {
                        markDropdown = value;
                      });
                    },
                    value: markDropdown,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text("${getTranslatedString("marksCardColor")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Red",
                        child: Text(
                          getTranslatedString("red"),
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Green",
                        child: Text(
                          getTranslatedString("green"),
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "lightGreenAccent400",
                        child: Text(
                          getTranslatedString("lightGreen"),
                          style: TextStyle(color: Colors.lightGreenAccent[400]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Lime",
                        child: Text(
                          getTranslatedString("lime"),
                          style: TextStyle(color: Colors.lime),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Blue",
                        child: Text(
                          getTranslatedString("blue"),
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "LightBlue",
                        child: Text(
                          getTranslatedString("lightBlue"),
                          style: TextStyle(color: Colors.lightBlue),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Teal",
                        child: Text(
                          getTranslatedString("teal"),
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Indigo",
                        child: Text(
                          getTranslatedString("indigo"),
                          style: TextStyle(color: Colors.indigo),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Yellow",
                        child: Text(
                          getTranslatedString("yellow"),
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Orange",
                        child: Text(
                          getTranslatedString("orange"),
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "DeepOrange",
                        child: Text(
                          getTranslatedString("deepOrange"),
                          style: TextStyle(color: Colors.deepOrange),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Pink",
                        child: Text(
                          getTranslatedString("pink"),
                          style: TextStyle(color: Colors.pink),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "LightPink",
                        child: Text(
                          getTranslatedString("lightPink"),
                          style: TextStyle(color: Colors.pink[300]),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Purple",
                        child: Text(
                          getTranslatedString("purple"),
                          style: TextStyle(color: Colors.purple),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      Crashlytics.instance
                          .setString("markCardConstColor", value);
                      prefs.setString("markCardConstColor", value);
                      globals.markCardConstColor = value;
                      setState(() {
                        constColorDropdown = value;
                      });
                    },
                    value: constColorDropdown,
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
            }
          }),
    );
  }
}

class UIsettings extends StatefulWidget {
  @override
  _UIsettingsState createState() => _UIsettingsState();
}

class _UIsettingsState extends State<UIsettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text("UI ${getTranslatedString("settings")}"),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4 + globals.adModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text(getTranslatedString("theme")),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Sötét",
                        child: Text(
                          getTranslatedString("dark"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Világos",
                        child: Text(
                          getTranslatedString("bright"),
                        ),
                      ),
                    ],
                    onChanged: (String value) {
                      if (value == "Világos") {
                        ThemeHelper()
                            .changeBrightness(context, Brightness.light);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Bright");
                        Crashlytics.instance.setString("Theme", "Bright");
                      } else {
                        ThemeHelper()
                            .changeBrightness(context, Brightness.dark);
                        FirebaseAnalytics()
                            .setUserProperty(name: "Theme", value: "Dark");
                        Crashlytics.instance.setString("Theme", "Dark");
                      }
                      setState(() {
                        dropDown = value;
                      });
                    },
                    value: dropDown,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text("Nyelv (language):"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "hu",
                        child: Text(
                          getTranslatedString("hu"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "en",
                        child: Text(
                          getTranslatedString("en"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString("Language", value);
                      FirebaseAnalytics().setUserProperty(
                        name: "Language",
                        value: value,
                      );
                      Crashlytics.instance.setString("Language", value);
                      setState(() {
                        globals.language = value;
                      });
                    },
                    value: globals.language,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text(getTranslatedString("ads")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        adsSwitch = isOn;
                      });
                      Crashlytics.instance.setBool("Ads", isOn);
                      if (isOn) {
                        FirebaseAnalytics()
                            .setUserProperty(name: "Ads", value: "ON");
                        prefs.setBool("ads", true);
                        globals.adsEnabled = true;
                        globals.adModifier = 1;
                        showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) {
                              return AdsDialog();
                            });
                      } else {
                        FirebaseAnalytics()
                            .setUserProperty(name: "Ads", value: "OFF");
                        prefs.setBool("ads", false);
                        globals.adsEnabled = false;
                        globals.adModifier = 0;
                        adBanner.dispose();
                        showDialog<void>(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) {
                              return new AlertDialog(
                                title: new Text(getTranslatedString("ads")),
                                content: Text(
                                  getTranslatedString("adsOffRestart"),
                                  textAlign: TextAlign.left,
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    value: adsSwitch,
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Text(getTranslatedString("chartAnimations")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        animationSwitch = switchOn;
                        globals.chartAnimations = switchOn;
                      });
                      Crashlytics.instance.setBool("ChartAnimations", switchOn);
                      if (switchOn) {
                        FirebaseAnalytics().setUserProperty(
                            name: "ChartAnimations", value: "YES");
                        prefs.setBool("chartAnimations", true);
                      } else {
                        FirebaseAnalytics().setUserProperty(
                            name: "ChartAnimations", value: "NO");
                        prefs.setBool("chartAnimations", false);
                      }
                    },
                    value: animationSwitch,
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
            }
          }),
    );
  }
}

class StatisticSettings extends StatefulWidget {
  @override
  _StatisticSettingsState createState() => _StatisticSettingsState();
}

class _StatisticSettingsState extends State<StatisticSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("statisticSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 5 + globals.adModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Text("${getTranslatedString("statiscticsGraph")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Mindent",
                        child: Text(
                          getTranslatedString("all"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Összesített",
                        child: Text(
                          getTranslatedString("contracted"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        Crashlytics.instance.setString("statChart", value);
                        prefs.setString("statChart", value);
                        globals.statChart = value;
                        statDropDown = value;
                      });
                    },
                    value: statDropDown,
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text("${getTranslatedString("markCountChart")}:"),
                  trailing: DropdownButton<String>(
                    items: [
                      DropdownMenuItem(
                        value: "Kör diagram",
                        child: Text(
                          getTranslatedString("pieChart"),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "Oszlop diagram",
                        child: Text(
                          getTranslatedString("barChart"),
                        ),
                      ),
                    ],
                    onChanged: (String value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        Crashlytics.instance.setString("howManyGraph", value);
                        prefs.setString("howManyGraph", value);
                        globals.howManyGraph = value;
                        howManyGraphDropDown = value;
                      });
                    },
                    value: howManyGraphDropDown,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Text("${getTranslatedString("showAllAv")}:"),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        showAllAvsInStatsSwitch = switchOn;
                        globals.showAllAvsInStats = switchOn;
                      });
                      prefs.setBool("showAllAvsInStats", switchOn);
                      Crashlytics.instance
                          .setBool("showAllAvsInStats", switchOn);
                    },
                    value: showAllAvsInStatsSwitch,
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Text("${getTranslatedString("colorAv")}:"),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        globals.colorAvsInStatisctics = switchOn;
                      });
                      prefs.setBool("colorAvsInStatisctics", switchOn);
                    },
                    value: globals.colorAvsInStatisctics,
                  ),
                );
                break;
              case 4:
                return ListTile(
                  title: Text(
                      "${getTranslatedString("extraSpaceUnderStat")} (1-500px):"),
                  trailing: SizedBox(
                    width: 50,
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: extraSpaceUnderStatController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslatedString("cantLeaveEmpty");
                          }
                          if (int.parse(value) > 500 || int.parse(value) <= 0) {
                            return getTranslatedString("mustBeBeetween1and500");
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (String input) async {
                          if (_formKey.currentState.validate()) {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              globals.extraSpaceUnderStat = int.parse(input);
                            });
                            prefs.setInt(
                                "extraSpaceUnderStat", int.parse(input));
                            Crashlytics.instance.setInt(
                                "extraSpaceUnderStat", int.parse(input));
                          }
                        },
                      ),
                    ),
                  ),
                );
                break;
              default:
                return SizedBox(height: 100, width: 10);
            }
          }),
    );
  }
}

class CalculatorSettings extends StatefulWidget {
  @override
  _CalculatorSettingsState createState() => _CalculatorSettingsState();
}

class _CalculatorSettingsState extends State<CalculatorSettings> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("markCalculatorSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 1,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title:
                      Text(getTranslatedString("shouldVirtualMarksCollapse")),
                  trailing: Switch(
                    onChanged: (bool switchOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        shouldCollapseSwitch = switchOn;
                        globals.shouldVirtualMarksCollapse = switchOn;
                      });
                      prefs.setBool("shouldVirtualMarksCollapse", switchOn);
                      Crashlytics.instance
                          .setBool("shouldVirtualMarksCollapse", switchOn);
                    },
                    value: shouldCollapseSwitch,
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
            }
          }),
    );
  }
}

class LogOutDialog extends StatefulWidget {
  @override
  _LogOutDialogState createState() => new _LogOutDialogState();
}

class _LogOutDialogState extends State<LogOutDialog> {
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return new AlertDialog(
      title: new Text(getTranslatedString("logOut")),
      content: Text(
        getTranslatedString("sureLogout"),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(getTranslatedString("yes")),
          onPressed: () async {
            FirebaseAnalytics().logEvent(name: "sign_out");
            globals.resetAllGlobals();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => login.LoginPage()),
              ModalRoute.withName('login-page'),
            );
          },
        ),
        FlatButton(
          child: Text(getTranslatedString("no")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class AdsDialog extends StatefulWidget {
  @override
  _AdsDialogState createState() => new _AdsDialogState();
}

class _AdsDialogState extends State<AdsDialog> {
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return new AlertDialog(
      title: new Text(getTranslatedString("ads")),
      content: Text(
        getTranslatedString("turnOnAds"),
        textAlign: TextAlign.left,
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () async {
            globals.adsEnabled = true;
            adBanner.load();
            adBanner.show(
              anchorType: AnchorType.bottom,
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

Future<void> _ackAlert(BuildContext context, String content) async {
  return showDialog<void>(
    barrierDismissible: false,
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

class SendTestNotif extends StatefulWidget {
  @override
  _SendTestNotifState createState() => _SendTestNotifState();
}

class _SendTestNotifState extends State<SendTestNotif> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("sendTestNotifs")),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => Divider(),
        itemCount: 8 + globals.adModifier,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'teszt',
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(getTranslatedString("sendTestNotif"),
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 1:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'marks ' +
                                (allParsedByDate.length == 0
                                    ? "0"
                                    : allParsedByDate[0].id.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("marks")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 2:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'hw ' +
                                (globalHomework.length == 0
                                    ? "0"
                                    : globalHomework[0].id.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("hw")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 3:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'notice ' +
                                (allParsedNotices.length == 0
                                    ? "0"
                                    : allParsedNotices[0].id.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("notice")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 4:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'timetable ' +
                                (lessonsList[0].length == 0
                                    ? "0"
                                    : lessonsList[0][0].id.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("timetable")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 5:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'exam ' +
                                (examsPage.allParsedExams.length == 0
                                    ? "0"
                                    : examsPage.allParsedExams[0].id
                                        .toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("exam")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 6:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'avarage 0',
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("av")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            case 7:
              return ListTile(
                title: Center(
                  child: SizedBox(
                    height: 38,
                    width: double.infinity,
                    child: RaisedButton.icon(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        onPressed: () async {
                          await notifications.flutterLocalNotificationsPlugin
                              .show(
                            1,
                            getTranslatedString("testNotif"),
                            getTranslatedString("thisIsHowItWillLookLike"),
                            notifications.platformChannelSpecifics,
                            payload: 'event ' +
                                (allParsedEvents.length == 0
                                    ? "0"
                                    : allParsedEvents[0].id.toString()),
                          );
                        },
                        icon: Icon(
                          MdiIcons.bellRing,
                          color: Colors.black,
                        ),
                        label: Text(
                            getTranslatedString("sendTestNotif") +
                                " (${getTranslatedString("event")})",
                            style: TextStyle(color: Colors.black))),
                  ),
                ),
              );
              break;
            default:
              return SizedBox(height: 100);
          }
        },
      ),
    );
  }
}

class NetworkAndNotificationSettings extends StatefulWidget {
  @override
  _NetworkAndNotificationSettingsState createState() =>
      _NetworkAndNotificationSettingsState();
}

class _NetworkAndNotificationSettingsState
    extends State<NetworkAndNotificationSettings> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("networkAndNotificationSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 3 + (globals.backgroundFetch ? 3 : 0),
          // ignore: missing_return
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendTestNotif()),
                            );
                          },
                          icon: Icon(
                            MdiIcons.bellRing,
                            color: Colors.black,
                          ),
                          label: Text(getTranslatedString("sendTestNotifs"),
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text(getTranslatedString("notifications")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      if (isOn && globals.offlineModeDb == false) {
                        await _ackAlert(
                          context,
                          getTranslatedString("notifTurnOnWarn"),
                        );
                        globals.offlineModeDb = true;
                        prefs.setBool("offlineModeDb", true);
                      }
                      setState(() {
                        globals.notifications = isOn;
                        prefs.setBool("notifications", isOn);
                        Crashlytics.instance.setBool("notifications", isOn);
                        FirebaseAnalytics().setUserProperty(
                          name: "Notifications",
                          value: isOn ? "ON" : "OFF",
                        );
                      });
                    },
                    value: globals.notifications,
                  ),
                );
                break;
              case 2:
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(getTranslatedString("backgroundFetch")),
                      trailing: Switch(
                        onChanged: (bool isOn) async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          setState(() {
                            globals.backgroundFetch = isOn;
                            prefs.setBool("backgroundFetch", isOn);
                            Crashlytics.instance
                                .setBool("backgroundFetch", isOn);
                          });
                          if (isOn) {
                            if (globals.offlineModeDb == false) {
                              await _ackAlert(
                                context,
                                getTranslatedString(
                                    "backgroundFetchTurnOnWarning"),
                              );
                              globals.offlineModeDb = true;
                              prefs.setBool("offlineModeDb", true);
                            }
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            Crashlytics.instance.log("Canceled alarm: " +
                                main.fetchAlarmID.toString());
                            await sleep(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          } else {
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            Crashlytics.instance.log("Canceled alarm: " +
                                main.fetchAlarmID.toString());
                            await sleep(1500);
                            main.fetchAlarmID++;
                          }
                        },
                        value: globals.backgroundFetch,
                      ),
                    ),
                    SizedBox(height: globals.backgroundFetch ? 0 : 100),
                  ],
                );
                break;
              case 3:
                return ListTile(
                  title: Text(getTranslatedString("backgroundFetchOnCellular")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        globals.backgroundFetchOnCellular = isOn;
                        prefs.setBool("backgroundFetchOnCellular", isOn);
                        Crashlytics.instance
                            .setBool("backgroundFetchOnCellular", isOn);
                      });
                    },
                    value: globals.backgroundFetchOnCellular,
                  ),
                );
                break;
              case 4:
                return ListTile(
                  title: Text(
                      "${getTranslatedString("timeBetweenFetches")} (30-500${getTranslatedString("minutes")}):"),
                  trailing: SizedBox(
                    width: 50,
                    child: Form(
                      key: _formKeyTwo,
                      child: TextFormField(
                        controller: fetchPeriodController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return getTranslatedString("cantLeaveEmpty");
                          }
                          if (int.parse(value) > 500 || int.parse(value) < 30) {
                            return getTranslatedString("mustBeBetween30And50");
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (String input) async {
                          if (_formKeyTwo.currentState.validate()) {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setInt("fetchPeriod", int.parse(input));
                            globals.fetchPeriod = int.parse(input);
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            Crashlytics.instance.log("Canceled alarm: " +
                                main.fetchAlarmID.toString());
                            await sleep(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
                break;
              case 5:
                return Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(getTranslatedString("fetchWakePhone")),
                      trailing: Switch(
                        onChanged: (bool isOn) async {
                          final SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          setState(() {
                            globals.backgroundFetchCanWakeUpPhone = isOn;
                            prefs.setBool(
                                "backgroundFetchCanWakeUpPhone", isOn);
                            Crashlytics.instance
                                .setBool("backgroundFetchCanWakeUpPhone", isOn);
                          });
                          if (isOn) {
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            Crashlytics.instance.log("Canceled alarm: " +
                                main.fetchAlarmID.toString());
                            await sleep(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          } else {
                            await AndroidAlarmManager.cancel(main.fetchAlarmID);
                            Crashlytics.instance.log("Canceled alarm: " +
                                main.fetchAlarmID.toString());
                            await sleep(1500);
                            main.fetchAlarmID++;
                            await AndroidAlarmManager.periodic(
                              Duration(minutes: globals.fetchPeriod),
                              main.fetchAlarmID,
                              backgroundFetchHelper.backgroundFetch,
                              wakeup: globals.backgroundFetchCanWakeUpPhone,
                              rescheduleOnReboot:
                                  globals.backgroundFetchCanWakeUpPhone,
                            );
                          }
                        },
                        value: globals.backgroundFetchCanWakeUpPhone,
                      ),
                    ),
                    SizedBox(height: 100, width: 10),
                  ],
                );
                break;
            }
            return SizedBox(height: 10, width: 10);
          }),
    );
  }
}

class DatabaseSettings extends StatefulWidget {
  @override
  _DatabaseSettingsState createState() => _DatabaseSettingsState();
}

class _DatabaseSettingsState extends State<DatabaseSettings> {
  bool dbSwitch = globals.offlineModeDb;

  @override
  Widget build(BuildContext context) {
    dbSwitch = globals.offlineModeDb;
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("dbSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 4 + globals.adModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          "SQLITE " + getTranslatedString("db"),
                          style: new TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          getTranslatedString("onlyAdvanced"),
                          style: new TextStyle(fontSize: 20, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Text(getTranslatedString("offlineDb")),
                  trailing: Switch(
                    onChanged: (bool isOn) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      setState(() {
                        dbSwitch = isOn;
                        globals.offlineModeDb = isOn;
                      });
                      if (!isOn &&
                          (globals.backgroundFetch || globals.notifications)) {
                        _ackAlert(
                          context,
                          getTranslatedString("dbOffWarning"),
                        );
                        setState(() {
                          globals.backgroundFetch = false;
                          prefs.setBool("backgroundFetch", false);
                          globals.notifications = false;
                          prefs.setBool("notifications", false);
                        });
                      }
                      prefs.setBool("offlineModeDb", isOn);
                      Crashlytics.instance.setBool("offlineModeDb", isOn);
                    },
                    value: dbSwitch,
                  ),
                );
                break;
              case 2:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () async {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) {
                                return AlertDialog(
                                  title:
                                      new Text(getTranslatedString("delete")),
                                  content: Text(
                                    getTranslatedString("sureDeleteDB"),
                                    textAlign: TextAlign.left,
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text(getTranslatedString("yes"),
                                          style: TextStyle(color: Colors.red)),
                                      onPressed: () async {
                                        FirebaseAnalytics()
                                            .logEvent(name: "clear_database");
                                        Crashlytics.instance
                                            .log("clear_database");
                                        await clearAllTables();
                                        Navigator.of(context).pop();
                                        _ackAlert(context,
                                            "Adatbázis sikeresen törölve");
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(getTranslatedString("no")),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            MdiIcons.databaseRemove,
                            color: Colors.black,
                          ),
                          label: Text(getTranslatedString("deleteDB"),
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                );
                break;
              case 3:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => RawSqlQuery()),
                            );
                          },
                          icon: Icon(
                            MdiIcons.databaseImport,
                            color: Colors.black,
                          ),
                          label: Text(getTranslatedString("runRawSQL"),
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
                break;
            }
          }),
    );
  }
}

class RawSqlQuery extends StatefulWidget {
  @override
  _RawSqlQueryState createState() => _RawSqlQueryState();
}

class _RawSqlQueryState extends State<RawSqlQuery> {
  TextEditingController _sqlController = new TextEditingController();
  FocusNode _sqlFocus = new FocusNode();
  String result = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(getTranslatedString("runRawSQL")),
      ),
      body: Column(
        children: <Widget>[
          TextFormField(
            controller: _sqlController,
            focusNode: _sqlFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (term) async {
              final Database db = await mainSql.database;
              if (term.contains("insert")) {
                int tempId = await db.rawInsert(term);
                result = "inserted at id: " + tempId.toString();
              } else if (term.contains("delete")) {
                int tempId = await db.rawDelete(term);
                result = tempId.toString() + " items deleted";
              } else if (term.contains("select")) {
                var temp = await db.rawQuery(term);
                JsonEncoder encoder = new JsonEncoder.withIndent('  ');
                String prettyprint = encoder.convert(temp);
                result = prettyprint;
              } else if (term.contains("update")) {
                int tempId = await db.rawUpdate(term);
                result = tempId.toString() + " items modified";
              }
              setState(() {
                result = result;
              });
              _sqlFocus.unfocus();
            },
          ),
          SizedBox(height: 15),
          DecoratedBox(
            decoration: new BoxDecoration(border: Border.all()),
            child: SizedBox(
              height: 250,
              child: ListView(
                children: [
                  Text(result),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeveloperSettings extends StatefulWidget {
  @override
  _DeveloperSettingsState createState() => _DeveloperSettingsState();
}

class _DeveloperSettingsState extends State<DeveloperSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(getTranslatedString("developerSettings")),
      ),
      body: ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: 3 + globals.adModifier,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return ListTile(
                  title: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          getTranslatedString("developerSettings"),
                          style: new TextStyle(fontSize: 30),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          getTranslatedString("developerSettingsWarning"),
                          style: new TextStyle(fontSize: 20, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
                break;
              case 1:
                return ListTile(
                  title: Center(
                    child: SizedBox(
                      height: 38,
                      width: double.infinity,
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DatabaseSettings()),
                            );
                          },
                          icon:
                              Icon(MdiIcons.databaseEdit, color: Colors.black),
                          label: Text(getTranslatedString("dbSettings"),
                              style: TextStyle(color: Colors.black))),
                    ),
                  ),
                );
                break;
              default:
                return SizedBox(height: 10, width: 10);
                break;
            }
          }),
    );
  }
}

class HomeworkSettingsTab extends StatefulWidget {
  @override
  _HomeworkSettingsTabState createState() => _HomeworkSettingsTabState();
}

class _HomeworkSettingsTabState extends State<HomeworkSettingsTab> {
  double keepDataForHw = 7;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        keepDataForHw = prefs.getDouble("howLongKeepDataForHw");
      });
    });
    super.initState();
  }

  void updateHwTab() async {
    homeworkPage.globalHomework = await getAllHomework(ignoreDue: false);
    homeworkPage.globalHomework.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    homeworkPage.colors = getRandomColors(homeworkPage.globalHomework.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslatedString("homeworkSettings")),
      ),
      body: ListView(
        children: <Widget>[
          Text(
            keepDataForHw >= 0
                ? getTranslatedString("homeworkKeepFor") +
                    " \n${keepDataForHw.toStringAsFixed(0)} ${getTranslatedString("forDay")}"
                : getTranslatedString("homeworkKeepFor") +
                    " \n${getTranslatedString("forInfinity")}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          Slider(
            value: keepDataForHw,
            onChanged: (newValue) {
              setState(() {
                if (newValue.roundToDouble() == 0 ||
                    newValue.roundToDouble() == -0) {
                  keepDataForHw = 0;
                } else {
                  keepDataForHw = newValue.roundToDouble();
                }
              });
            },
            onChangeEnd: (newValue) async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              setState(() {
                if (newValue.roundToDouble() == 0 ||
                    newValue.roundToDouble() == -0) {
                  keepDataForHw = 0;
                } else {
                  keepDataForHw = newValue.roundToDouble();
                }
                globals.howLongKeepDataForHw = keepDataForHw;
                prefs.setDouble("howLongKeepDataForHw", keepDataForHw);
                Crashlytics.instance
                    .setDouble("howLongKeepDataForHw", keepDataForHw);
              });
              updateHwTab();
            },
            min: -1,
            max: 15,
            divisions: 17,
            label: keepDataForHw.toStringAsFixed(0),
          ),
        ],
      ),
    );
  }
}
