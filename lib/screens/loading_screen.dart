import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/helpers/adHelper.dart';
import 'package:novynaplo/screens/marks_tab.dart' as marksTab;
import 'package:novynaplo/config.dart' as config;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/helpers/versionHelper.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/notices_tab.dart' as noticesPage;
import 'package:novynaplo/screens/statistics_tab.dart' as statisticsPage;
import 'package:novynaplo/screens/timetable_tab.dart' as timetablePage;
import 'package:novynaplo/screens/calculator_tab.dart' as calculatorPage;
import 'package:novynaplo/functions/parseMarks.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

var passKey = encrypt.Key.fromUtf8(config.passKey);
var codeKey = encrypt.Key.fromUtf8(config.codeKey);
var userKey = encrypt.Key.fromUtf8(config.userKey);
final passEncrypter = encrypt.Encrypter(encrypt.AES(passKey));
final codeEncrypter = encrypt.Encrypter(encrypt.AES(codeKey));
final userEncrypter = encrypt.Encrypter(encrypt.AES(userKey));
String decryptedCode,
    decryptedUser,
    decryptedPass,
    loadingText = "Kérlek várj...";
var status;
String agent = config.currAgent;
var response;

class LoadingPage extends StatefulWidget {
  static String tag = 'loading-page';
  @override
  _LoadingPageState createState() => new _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  //Network start
  void setUpCalculatorPage(var dJson, avJson) {
    setState(() {
      loadingText = "Jegyszámoló beállítása";
    });
    calculatorPage.avarageList = [];
    calculatorPage.dropdownValues = [];
    for (var n in avJson) {
      calculatorPage.avarageList
          .add(setCalcData(n["Value"], n["Subject"], 0, 0));
      calculatorPage.dropdownValues.add(capitalize(n["Subject"]));
    }
    for (var n in dJson["Evaluations"]) {
      int indexA =
          calculatorPage.avarageList.indexWhere((a) => a.name == n["Subject"]);
      if (indexA >= 0 && n["Type"] != "HalfYear" && n["Form"] != "Percent") {
        calculatorPage.avarageList[indexA].count++;
        calculatorPage.avarageList[indexA].sum += n["NumberValue"];
      }
    }
    calculatorPage.dropdownValue = calculatorPage.dropdownValues[0];
  }

  Future<ConnectivityResult> isNetworkAvailable() async {
    setState(() {
      loadingText = "Hálózat ellenőrzése";
    });
    return await (Connectivity().checkConnectivity());
  }

  Future<String> getToken(code, user, pass) async {
    try {
      if (code == "" || user == "" || pass == "") {
        return "Hiányzó bemenet";
      } else {
        setState(() {
          loadingText = "Token lekérése";
        });
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
          //print(response.body);
          /*var url = 'https://novy.vip/api/globals.php?code=$code&user=$user&pass=$pass';
    var response = await http.get(url);*/
          //print(response.body);
          if (response.statusCode == 200) {
            setState(() {
              loadingText = "Token dekódolása";
            });
            var parsedJson = json.decode(response.body);
            //print('Response body: ${response.body}');
            var status = parsedJson['token_type'];
            if (status == '' || status == null) {
              if (parsedJson["error_description"] == '' ||
                  parsedJson["error_description"] == null) {
                return "Hibás felhasználónév/jelszó";
              } else {
                return parsedJson["error_description"];
              }
            } else {
              globals.token = parsedJson["access_token"];
              return "OK";
            }
            //print(status);
          } else if (response.statusCode == 401) {
            var parsedJson = json.decode(response.body);
            if (parsedJson["error_description"] == '' ||
                parsedJson["error_description"] == null) {
              return "Hibás felhasználónév/jelszó";
            } else {
              return parsedJson["error_description"];
            }
            //print('Response status: ${response.statusCode}');
          } else {
            throw Exception('post error: statusCode= ${response.statusCode}');
          }
        } on SocketException {
          return "Rossz iskola azonosító";
        }
      }
    } catch (e) {
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újra indítása\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel");
    }
  }

  Future<void> getStudentInfo(token, code) async {
    try {
      setState(() {
        loadingText = "Jegyek lekérése";
      });
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
        setState(() {
          loadingText = "Jegyek dekódolása";
        });
        globals.dJson = json.decode(res.body);
        var eval = globals.dJson["Evaluations"];
        if (globals.markCount != 0) globals.markCount = 0;
        if (globals.avarageCount != 0) globals.avarageCount = 0;
        if (globals.noticesCount != 0) globals.noticesCount = 0;
        await getAvarages(token, code);
        eval.forEach((element) => globals.markCount += 1);
        globals.noticesCount = countNotices(globals.dJson);
        noticesPage.allParsedNotices = parseNotices(globals.dJson);
        statisticsPage.allParsedSubjects = categorizeSubjects(globals.dJson);
        statisticsPage.colors =
            getRandomColors(statisticsPage.allParsedSubjects.length);
        timetablePage.lessonsList = await getWeekLessons(token, code);
        setUpCalculatorPage(globals.dJson, globals.avJson);
      }
    } catch (e) {
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újra indítása\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel");
    }
  }

  Future<void> getAvarages(var token, code) async {
    try {
      setState(() {
        loadingText = "Átlagok lekérése";
      });
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
        setState(() {
          loadingText = "Átlagok dekódolása";
        });
        var bodyJson = json.decode(res.body);
        globals.avJson = bodyJson;
        globals.avarageCount = countAvarages(bodyJson);
      }
    } catch (e) {
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újra indítása\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel");
    }
  }

  Future<List<List<Lesson>>> getWeekLessons(token, code) async {
    try {
      setState(() {
        loadingText = "Órarend előkészítése";
      });
      List<List<Lesson>> output = [];
      for (var n = 0; n < 7; n++) {
        output.add([]);
      }
      //calculate when was monday this week
      int monday = 1;
      int sunday = 7;
      DateTime now = new DateTime.now();

      while (now.weekday != monday) {
        now = now.subtract(new Duration(days: 1));
      }
      String startDate = now.year.toString() +
          "-" +
          now.month.toString() +
          "-" +
          now.day.toString();
      now = new DateTime.now();
      while (now.weekday != sunday) {
        now = now.add(new Duration(days: 1));
      }
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
      setState(() {
        loadingText = "Órarend lekérése";
      });

      var res = await http.get(
          'https://$code.e-kreta.hu/mapi/api/v1/LessonAmi?fromDate=$startDate&toDate=$endDate',
          headers: header);
      if (res.statusCode != 200) {
        print(res.statusCode);
      }
      //Process response
      var decoded = json.decode(res.body);
      setState(() {
        loadingText = "Órarend dekódolása\nHázifeladatok lekérése";
      });
      List<Lesson> tempLessonList = [];
      for (var n in decoded) {
        tempLessonList.add(await setLesson(n, token, code));
      }
      tempLessonList.sort((a, b) => a.startDate.compareTo(b.startDate));
      int index = 0;
      int beforeDay = tempLessonList[0].startDate.day;
      //Just a matrix
      for (var n in tempLessonList) {
        if (n.startDate.day != beforeDay) {
          index++;
          beforeDay = n.startDate.day;
        }
        output[index].add(n);
      }
      return output;
    } catch (e) {
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újra indítása\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel");
    }
  }
  //NETWORK END

  void onLoad(var context) async {
    NewVersion newVerDetails = await getVersion();
    if (newVerDetails.returnedAnything) {
      if (config.currentAppVersionCode != newVerDetails.versionCode) {
        setState(() {
          loadingText = "Verzió ellenőrzése";
        });
        await _newVersionAlert(
            context,
            newVerDetails.versionCode,
            newVerDetails.releaseNotes,
            newVerDetails.isBreaking,
            newVerDetails.releaseLink);
      }
    }
    setState(() {
      loadingText = "Addatok olvasása a memóriából";
    });
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final iv = encrypt.IV.fromBase64(prefs.getString("iv"));
      decryptedCode = codeEncrypter.decrypt64(prefs.getString("code"), iv: iv);
      decryptedUser = userEncrypter.decrypt64(prefs.getString("user"), iv: iv);
      decryptedPass =
          userEncrypter.decrypt64(prefs.getString("password"), iv: iv);
      if (prefs.getString("markCardSubtitle") == null) {
        globals.markCardSubtitle = "Téma";
      } else {
        globals.markCardSubtitle = prefs.getString("markCardSubtitle");
      }

      if (prefs.getString("markCardConstColor") == null) {
        globals.markCardConstColor = "Green";
      } else {
        globals.markCardConstColor = prefs.getString("markCardConstColor");
      }

      if (prefs.getString("lessonCardSubtitle") == null) {
        globals.lessonCardSubtitle = "Tanterem";
      } else {
        globals.lessonCardSubtitle = prefs.getString("lessonCardSubtitle");
      }

      if (prefs.getString("markCardTheme") == null) {
        globals.markCardTheme = "Véletlenszerű";
      } else {
        globals.markCardTheme = prefs.getString("markCardTheme");
      }
      if (prefs.getBool("ads") != null) {
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
      //print("ads" + globals.adsEnabled.toString());
    } catch (e) {
      await _ackAlert(context,
          "Hiba a memóriából való olvasás közben ($e)\nAjánlott az alkalmazás újra telepítése");
    }
    auth(context);
  }

  void auth(var context) async {
    try {
      if (await isNetworkAvailable() == ConnectivityResult.none) {
        status = "No internet connection was detected";
      } else {
        status = await getToken(decryptedCode, decryptedUser, decryptedPass);
        if (status == "OK") {
          await getStudentInfo(globals.token, decryptedCode);
        }
      }
      if (status == "OK") {
        try {
          save(context);
        } on PlatformException catch (e) {
          await _ackAlert(context, e.message);
        }
      } else {
        await _ackAlert(context, status);
      }
    } catch (e) {
      await _ackAlert(context,
          "Hiba: $e\nAjánlott az alkalmazás újra indítása\nHa a hiba továbbra is fent áll, akkor lépjen kapcsolatba a fejlesztőkkel");
    }
  }

  void save(var context) async {
    setState(() {
      loadingText = "Mindjárt megvagyunk!";
    });
    FirebaseAnalytics().setUserProperty(name: "School", value: decryptedCode);
    FirebaseAnalytics()
        .setUserProperty(name: "Version", value: config.currentAppVersionCode);
    Navigator.pushReplacementNamed(context, marksTab.MarksTab.tag);
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance.initialize(appId: config.adMob);
    WidgetsBinding.instance.addPostFrameCallback((_) => onLoad(context));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
          backgroundColor: Colors.grey,
          radius: 75.0,
          child: Image.asset('assets/home.png')),
    );
    return Scaffold(
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 5.0),
            Center(
              child: Text(
                "Üdv a Novy Naplóban!",
                style: TextStyle(fontSize: 28),
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

  Future<void> _newVersionAlert(BuildContext context, String version,
      String notes, bool isBreaking, String link) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Új verzió: $version"),
          content: SingleChildScrollView(
            child:
                Column(children: <Widget>[Text("Megjegyzések:"), Text(notes)]),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Frissítés'),
              onPressed: () async {
                if (await canLaunch(link)) {
                  await launch(link);
                } else {
                  FirebaseAnalytics().logEvent(name: "LinkFail");
                  throw 'Could not launch $link';
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _ackAlert(BuildContext context, String content) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Státusz'),
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
}