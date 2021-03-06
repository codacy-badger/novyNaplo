import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _formKey = GlobalKey<FormState>(debugLabel: '_FormKey');
TextEditingController extraSpaceUnderStatController =
    TextEditingController(text: globals.extraSpaceUnderStat.toString());

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
                      });
                    },
                    value: globals.statChart,
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
                      });
                    },
                    value: globals.howManyGraph,
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
                        globals.showAllAvsInStats = switchOn;
                      });
                      prefs.setBool("showAllAvsInStats", switchOn);
                      Crashlytics.instance
                          .setBool("showAllAvsInStats", switchOn);
                    },
                    value: globals.showAllAvsInStats,
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
