import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:novynaplo/global.dart' as globals;

class EventsDetailTab extends StatefulWidget {
  const EventsDetailTab({
    @required this.eventDetails,
    @required this.color,
  });

  final Event eventDetails;
  final Color color;

  @override
  _EventsDetailTabState createState() => _EventsDetailTabState();
}

class _EventsDetailTabState extends State<EventsDetailTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        bottom: true,
        left: false,
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: DecoratedBox(
                decoration: BoxDecoration(color: widget.color),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Text(
                        widget.eventDetails.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                      SizedBox(height: 15),
                      Text(
                        widget.eventDetails.date.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  Html(
                    data: widget.eventDetails.content,
                    onLinkTap: (url) async {
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        FirebaseAnalytics().logEvent(
                          name: "LinkFail",
                          parameters: {"link": url},
                        );
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  SizedBox(height: globals.adsEnabled ? 150 : 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
