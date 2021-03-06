import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/screens/settings/settings_tab.dart';
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                      setState(() {
                        globals.markCardTheme = value;
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
                    value: globals.markCardTheme,
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
                      setState(() {
                        globals.markCardSubtitle = value;
                      });
                    },
                    value: globals.markCardSubtitle,
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
                      setState(() {
                        globals.markCardConstColor = value;
                      });
                    },
                    value: globals.markCardConstColor,
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
