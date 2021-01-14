import 'package:firebase_analytics/firebase_analytics.dart';

String shortenSubject(String input) {
  if (input.toLowerCase().contains("kötelező komplex természettudomány")) {
    return "KKterm";
  }
  if (input.toLowerCase().contains("komplex természettudomány") &&
      !input.toLowerCase().contains("kötlező")) {
    return "Komplex természet";
  }
  if (input.length >= 30) {
    FirebaseAnalytics().logEvent(
      name: "LongSubject",
      parameters: {
        "subject": input,
      },
    );
  }
  return input;
}