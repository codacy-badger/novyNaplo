import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';

List<Avarage> avarageList = [];

class AvaragesTab extends StatelessWidget {
  static String tag = 'avarages';
  static String title = getTranslatedString("avs");

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(AvaragesTab.title),
      ),
      drawer: getDrawer(AvaragesTab.tag, context),
      body: BodyLayout(),
    );
  }
}

class BodyLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return avaragesList(context);
  }
}

Widget avaragesList(BuildContext context) {
  return ListView.separated(
    separatorBuilder: (context, index) => Divider(),
    itemCount: avarageList.length + globals.adModifier,
    itemBuilder: (context, index) {
      Color avgColor = Colors.red;
      if (index >= avarageList.length) {
        return ListTile(
          title: SizedBox(
            height: 100,
          ),
        );
      } else {
        if (avarageList[index].ownValue == null) {
          avgColor = (Colors.red);
        } else if (avarageList[index].ownValue < 2.5) {
          avgColor = (Colors.redAccent[700]);
        } else if (avarageList[index].ownValue < 3 &&
            avarageList[index].ownValue >= 2.5) {
          avgColor = (Colors.redAccent);
        } else if (avarageList[index].ownValue < 4 &&
            avarageList[index].ownValue >= 3) {
          avgColor = (Colors.yellow[800]);
        } else {
          avgColor = (Colors.green);
        }
        return ListTile(
          title: Text(avarageList[index].subject,
              style: TextStyle(color: avgColor)),
          trailing: Text(avarageList[index].ownValue.toString(),
              style: TextStyle(color: avgColor)),
        );
      }
    },
  );
}
