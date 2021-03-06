import 'package:connectivity/connectivity.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/parseMarks.dart';
import 'package:novynaplo/helpers/networkHelper.dart';
import 'package:novynaplo/helpers/notificationHelper.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/config.dart' as config;
import 'package:novynaplo/helpers/notificationHelper.dart' as notifications;
import 'package:novynaplo/helpers/backgroundFetchHelper.dart';
import 'package:novynaplo/screens/marks_detail_tab.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:novynaplo/translations/translationProvider.dart';

List<Evals> allParsedByDate;
List<List<Evals>> allParsedBySubject;
int selectedIndex = 0;
bool differenSubject = false;
String subjectBefore = "";
final List<Tab> markTabs = <Tab>[
  Tab(text: getTranslatedString("byDate"), icon: Icon(Icons.calendar_today)),
  Tab(text: getTranslatedString("bySubject"), icon: Icon(Icons.view_list)),
];
String label, labelBefore;
TabController _tabController;
List<dynamic> colors;
bool redirectPayload = false;

class MarksTab extends StatefulWidget {
  static String tag = 'marks';
  static String title = capitalize(getTranslatedString("marks"));

  const MarksTab({Key key, this.androidDrawer}) : super(key: key);

  final Widget androidDrawer;

  @override
  MarksTabState createState() => MarksTabState();
}

class MarksTabState extends State<MarksTab>
    with SingleTickerProviderStateMixin {
  GlobalKey<RefreshIndicatorState> _androidRefreshKey =
      GlobalKey<RefreshIndicatorState>(debugLabel: "1");
  GlobalKey<RefreshIndicatorState> _androidRefreshKeyTwo =
      GlobalKey<RefreshIndicatorState>(debugLabel: "2");

  @override
  void initState() {
    //Update refresh key
    _androidRefreshKey = new GlobalKey<RefreshIndicatorState>(debugLabel: "1");
    _androidRefreshKeyTwo =
        new GlobalKey<RefreshIndicatorState>(debugLabel: "2");
    //setup tabcontroller
    _tabController = new TabController(vsync: this, length: 2);
    //Payload handling and fetching data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!globals.didFetch) {
        globals.didFetch = true;
        _androidRefreshKey.currentState?.show();
      }
      if (redirectPayload) {
        redirectPayload = false;
        selectNotification(globals.notificationAppLaunchDetails.payload);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _setData() async {
    allParsedByDate = await parseAllByDate(globals.dJson);
    colors = getRandomColors(allParsedByDate.length);
    allParsedBySubject = sortByDateAndSubject(List.from(allParsedByDate));
  }

  Future<void> _refreshData() async {
    FirebaseAnalytics().logEvent(name: "RefreshData");
    Crashlytics.instance.log("RefreshData");
    if (await NetworkHelper().isNetworkAvailable() == ConnectivityResult.none) {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(getTranslatedString("status")),
            content: Text(getTranslatedString("noNet")),
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
      return;
    }
    await notifications.flutterLocalNotificationsPlugin.show(
      -111,
      getTranslatedString("gettingData"),
      '${getTranslatedString("currGetData")}...',
      platformChannelSpecificsGetNotif,
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var decryptedPass, decryptedUser, decryptedCode, status;
    final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
    var passKey = encrypt.Key.fromUtf8(config.passKey);
    var codeKey = encrypt.Key.fromUtf8(config.codeKey);
    var userKey = encrypt.Key.fromUtf8(config.userKey);
    final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
    final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
    final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
    decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
    decryptedUser = userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
    decryptedPass =
        passEncrypter.decrypt64(prefs.getString("password"), iv: iv);
    for (var i = 0; i < 2; i++) {
      status = await NetworkHelper()
          .getToken(decryptedCode, decryptedUser, decryptedPass);
    }
    if (status == "OK") {
      await NetworkHelper().getStudentInfo(globals.token, decryptedCode);
      await _setData();
      setState(() {
        colors = colors;
        allParsedByDate = allParsedByDate;
        allParsedBySubject = allParsedBySubject;
      });
    } else {
      print(status);
    }
    await notifications.flutterLocalNotificationsPlugin.cancel(-111);
  }

  Widget _dateListBuilder(BuildContext context, int index) {
    if (index >= allParsedByDate.length) {
      return SizedBox(
        height: 150,
      );
    }
    Color color = getMarkCardColor(
      eval: allParsedByDate[index],
      index: index,
    );
    return SafeArea(
      top: false,
      bottom: false,
      child: HeroAnimatingMarksCard(
        eval: allParsedByDate[index],
        iconData: allParsedByDate[index].icon,
        subTitle: getMarkCardSubtitle(
          eval: allParsedByDate[index],
        ), //capitalize(allParsedByDate[index].theme),
        title: capitalize(allParsedByDate[index].subject +
            " " +
            allParsedByDate[index].value),
        color: color,
        heroAnimation: AlwaysStoppedAnimation(0),
        onPressed: MarksDetailTab(
          eval: allParsedByDate[index],
          color: color,
        ),
      ),
    );
  }

  Widget _subjectListBuilder(BuildContext context, int listIndex) {
    if (listIndex >= allParsedBySubject.length) {
      return SizedBox(
        height: 150,
      );
    }
    return ListView.builder(
      itemCount: allParsedBySubject[listIndex].length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        //return Text(allParsedBySubject[listIndex][index].subject);
        int indexSum = 0;
        for (int i = 0; i <= listIndex - 1; i++) {
          indexSum += allParsedBySubject[i].length;
        }
        Color color = getMarkCardColor(
          eval: allParsedBySubject[listIndex][index],
          index: indexSum + index,
        );
        if (index == 0) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: defaultTargetPlatform == TargetPlatform.iOS
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Text(
                  capitalize(allParsedBySubject[listIndex][index].subject) +
                      ":",
                  textAlign: defaultTargetPlatform == TargetPlatform.iOS
                      ? TextAlign.center
                      : TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 106,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: HeroAnimatingSubjectsCard(
                    subTitle: getMarkCardSubtitle(
                      eval: allParsedBySubject[listIndex][index],
                    ),
                    title: capitalize(
                            allParsedBySubject[listIndex][index].subject) +
                        " " +
                        allParsedBySubject[listIndex][index].value,
                    color: color,
                    heroAnimation: AlwaysStoppedAnimation(0),
                    onPressed: MarksDetailTab(
                      eval: allParsedBySubject[listIndex][index],
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return SizedBox(
          width: double.infinity,
          height: 106,
          child: SafeArea(
            top: false,
            bottom: false,
            child: HeroAnimatingSubjectsCard(
              subTitle: getMarkCardSubtitle(
                eval: allParsedBySubject[listIndex][index],
              ),
              title: capitalize(allParsedBySubject[listIndex][index].subject) +
                  " " +
                  allParsedBySubject[listIndex][index].value,
              color: color,
              heroAnimation: AlwaysStoppedAnimation(0),
              onPressed: MarksDetailTab(
                eval: allParsedBySubject[listIndex][index],
                color: color,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      drawer: getDrawer(MarksTab.tag, context),
      appBar: AppBar(
        title: Text(MarksTab.title),
        bottom: TabBar(
          controller: _tabController,
          tabs: markTabs,
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: markTabs.map((Tab tab) {
            if (tab.text == getTranslatedString("byDate")) {
              return RefreshIndicator(
                key: _androidRefreshKey,
                onRefresh: () async {
                  await _refreshData();
                },
                child: allParsedByDate.length == 0
                    ? noMarks()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allParsedByDate.length +
                            (globals.adsEnabled ? 1 : 0),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        itemBuilder: _dateListBuilder,
                      ),
              );
            } else {
              return RefreshIndicator(
                key: _androidRefreshKeyTwo,
                onRefresh: () async {
                  await _refreshData();
                },
                child: allParsedByDate.length == 0
                    ? noMarks()
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: allParsedBySubject.length +
                            (globals.adsEnabled ? 1 : 0),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        itemBuilder: _subjectListBuilder,
                      ),
              );
            }
          }).toList()),
    );
  }

  Widget noMarks() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.emoticonSadOutline,
            size: 50,
          ),
          Text(
            "${getTranslatedString("possibleNoMarks")}!",
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
