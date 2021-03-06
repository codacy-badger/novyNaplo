import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/screens/notices_detail_tab.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/global.dart' as globals;
import 'package:novynaplo/translations/translationProvider.dart';

List<Notices> allParsedNotices;
var colors = getRandomColors(allParsedNotices.length);

class NoticesTab extends StatefulWidget {
  static String tag = 'notices';
  static String title = getTranslatedString("notices");

  @override
  _NoticesTabState createState() => _NoticesTabState();
}

class _NoticesTabState extends State<NoticesTab> {
  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(NoticesTab.title),
      ),
      drawer: getDrawer(NoticesTab.tag, context),
      body: _body(context),
    );
  }

  @override
  void initState() {
    super.initState();
    if (colors == [] ||
        colors == null ||
        colors.length < allParsedNotices.length) {
      colors = getRandomColors(allParsedNotices.length);
    }
  }
}

Widget _body(BuildContext context) {
  if (allParsedNotices.length == 0) {
    return noNotice();
  } else {
    return ListView.builder(
      itemCount: allParsedNotices.length + globals.adModifier,
      padding: EdgeInsets.symmetric(vertical: 12),
      itemBuilder: _noticesBuilder,
    );
  }
}

Widget noNotice() {
  return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(
      MdiIcons.emoticonHappyOutline,
      size: 50,
    ),
    Text(
      "${getTranslatedString("noNotice")}!",
      textAlign: TextAlign.center,
    )
  ]));
}

Widget _noticesBuilder(BuildContext context, int index) {
  if (index >= allParsedNotices.length) {
    return SizedBox(
      height: 100,
    );
  } else {
    Color currColor = colors[index];
    return SafeArea(
        top: false,
        bottom: false,
        child: AnimatedTitleSubtitleCard(
          title: allParsedNotices[index].title,
          subTitle: allParsedNotices[index].teacher,
          color: currColor,
          heroAnimation: AlwaysStoppedAnimation(0),
          onPressed: NoticeDetailTab(
            id: index,
            title: allParsedNotices[index].title,
            teacher: allParsedNotices[index].teacher,
            content: allParsedNotices[index].content,
            date: allParsedNotices[index].dateString,
            subject: allParsedNotices[index].subject,
            color: currColor,
          ),
        ));
  }
}
