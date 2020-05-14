import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:novynaplo/functions/classManager.dart';
import 'package:novynaplo/functions/utils.dart';
import 'package:novynaplo/functions/widgets.dart';
import 'package:novynaplo/global.dart' as globals;

class MarksDetailTab extends StatelessWidget {
  const MarksDetailTab({@required this.color, @required this.eval});

  final Evals eval;
  final Color color;

  Widget _buildBody() {
    return SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeroAnimatingMarksCard(
            eval: null,
            iconData: eval.icon == null
                ? parseSubjectToIcon(subject: eval.subject)
                : eval.icon,
            subTitle: "",
            title: capitalize(eval.subject + " " + eval.value),
            color: color,
            heroAnimation: AlwaysStoppedAnimation(1),
            onPressed: null,
          ),
          Divider(
            height: 0,
            color: Colors.grey,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Padding(
                      padding:
                          const EdgeInsets.only(left: 15, top: 16, bottom: 16),
                      child: Text(
                        'Jegy információk:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                    break;
                  case 1:
                    return SizedBox(
                      child: Text("Tantárgy: " + eval.subject,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 2:
                    return SizedBox(
                      child: Text("Téma: " + eval.theme.toString(),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 3:
                    return SizedBox(
                      child: Text("Jegy típusa: " + eval.mode.toString(),
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 4:
                    return SizedBox(
                      child: Text("Értékelés típusa: " + eval.formName,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 5:
                    if (eval.form == "Mark" ||
                        eval.form == "Diligence" ||
                        eval.form == "Deportment") {
                      switch (eval.numberValue) {
                        case 1:
                          return SizedBox(
                            child: Text("Értékelés: " + eval.value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          );
                          break;
                        case 2:
                          return SizedBox(
                            child: Text("Értékelés: " + eval.value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          );
                          break;
                        case 3:
                          return SizedBox(
                            child: Text("Értékelés: " + eval.value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow[800])),
                          );
                          break;
                        case 4:
                          return SizedBox(
                            child: Text("Értékelés: " + eval.value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightGreen)),
                          );
                          break;
                        case 5:
                          return SizedBox(
                            child: Text("Értékelés: " + eval.value,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          );
                          break;
                        default:
                          return SizedBox(
                            child: Text("Értékelés: " + eval.value,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          );
                          break;
                      }
                    } else if (eval.form == "Percent") {
                      if (eval.numberValue >= 90) {
                        return SizedBox(
                          child: Text("Értékelés: " + eval.value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        );
                      } else if (eval.numberValue >= 75) {
                        return SizedBox(
                          child: Text("Értékelés: " + eval.value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreen)),
                        );
                      } else if (eval.numberValue >= 60) {
                        return SizedBox(
                          child: Text("Értékelés: " + eval.value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800])),
                        );
                      } else if (eval.numberValue >= 40) {
                        return SizedBox(
                          child: Text("Értékelés: " + eval.value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)),
                        );
                      } else {
                        return SizedBox(
                          child: Text("Értékelés: " + eval.value,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        );
                      }
                    } else {
                      return SizedBox(
                        child: Text("Értékelés: " + eval.value,
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                    }
                    break;
                  case 6:
                    if (eval.form == "Mark" ||
                        eval.form == "Diligence" ||
                        eval.form == "Deportment") {
                      switch (eval.numberValue) {
                        case 1:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " +
                                    eval.numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          );
                          break;
                        case 2:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " +
                                    eval.numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          );
                          break;
                        case 3:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " +
                                    eval.numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellow[800])),
                          );
                          break;
                        case 4:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " +
                                    eval.numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightGreen)),
                          );
                          break;
                        case 5:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " +
                                    eval.numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green)),
                          );
                          break;
                        default:
                          return SizedBox(
                            child: Text(
                                "Értékelés számmal: " +
                                    eval.numberValue.toString(),
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                          );
                          break;
                      }
                    } else if (eval.form == "Percent") {
                      if (eval.numberValue >= 90) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " +
                                  eval.numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green)),
                        );
                      } else if (eval.numberValue >= 75) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " +
                                  eval.numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightGreen)),
                        );
                      } else if (eval.numberValue >= 60) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " +
                                  eval.numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow[800])),
                        );
                      } else if (eval.numberValue >= 40) {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " +
                                  eval.numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange)),
                        );
                      } else {
                        return SizedBox(
                          child: Text(
                              "Értékelés számmal: " +
                                  eval.numberValue.toString(),
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red)),
                        );
                      }
                    } else {
                      return SizedBox(
                        child: Text(
                            "Értékelés számmal: " + eval.numberValue.toString(),
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      );
                    }
                    break;
                  case 7:
                    return SizedBox(
                      child: Text("Súly: " + eval.weight,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 8:
                    return SizedBox(
                      child: Text("Tanár: " + eval.teacher,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 9:
                    return SizedBox(
                      child: Text("Beírás dátuma: " + eval.dateString,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  case 10:
                    return SizedBox(
                      child: Text("Létrehozás dátuma: " + eval.createDateString,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold)),
                    );
                    break;
                  default:
                    return SizedBox(height: 18);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    globals.globalContext = context;
    return Scaffold(
      appBar: AppBar(title: Text(capitalize(eval.subject + " " + eval.value))),
      body: _buildBody(),
    );
  }
}
