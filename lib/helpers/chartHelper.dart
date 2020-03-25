import 'package:charts_flutter/flutter.dart' as charts;
import 'package:novynaplo/screens/statistics_tab.dart' as stats;
import 'dart:math';

//TODO optimize this entire thing
class LinearMarkChartData {
  final int count;
  final double value;
  String id;

  LinearMarkChartData(this.count, this.value, {this.id});
}

var chartColorList = [
  charts.MaterialPalette.green.shadeDefault,
  charts.MaterialPalette.blue.shadeDefault,
  charts.MaterialPalette.red.shadeDefault,
  charts.MaterialPalette.deepOrange.shadeDefault,
  charts.MaterialPalette.lime.shadeDefault,
  charts.MaterialPalette.purple.shadeDefault,
  charts.MaterialPalette.cyan.shadeDefault,
  charts.MaterialPalette.yellow.shadeDefault,
  charts.MaterialPalette.indigo.shadeDefault,
  charts.MaterialPalette.pink.shadeDefault,
  charts.MaterialPalette.teal.shadeDefault,
];

List<charts.Series<LinearMarkChartData, int>> createAllSubjectChartData(
    var allParsedInput) {
  var linearMarkDataList = [];
  List<dynamic> subjectMarks = [];
  int index = 0;
  for (var y in allParsedInput) {
    if (index != 0) {
      subjectMarks.add([]);
      subjectMarks[index - 1].add(y[0].split(":")[0]);
      for (var n in y) {
        subjectMarks[index - 1].add(int.parse(n.split(":")[1]));
      }
    }
    index++;
  }
  index = 0;
  for (var n in subjectMarks) {
    linearMarkDataList.add(makeChartPoints(n));
    index++;
  }
  return makeChartReturnList(linearMarkDataList);
}

List<LinearMarkChartData> makeChartPoints(var list) {
  List<LinearMarkChartData> returnList = [];
  int locIndex = 0;
  int sum = 0;
  for (var n in list) {
    if (locIndex != 0) {
      sum += n;
      returnList.add(
          new LinearMarkChartData(locIndex - 1, sum / locIndex, id: list[0]));
    }
    locIndex++;
  }
  return returnList;
}

List<charts.Series<LinearMarkChartData, int>> makeChartReturnList(input) {
  List<charts.Series<LinearMarkChartData, int>> returnList = [];
  List<LinearMarkChartData> tempList = [];
  var chartTempList = [
    charts.MaterialPalette.green.shadeDefault,
    charts.MaterialPalette.blue.shadeDefault,
    charts.MaterialPalette.red.shadeDefault,
    charts.MaterialPalette.deepOrange.shadeDefault,
    charts.MaterialPalette.lime.shadeDefault,
    charts.MaterialPalette.purple.shadeDefault,
    charts.MaterialPalette.cyan.shadeDefault,
    charts.MaterialPalette.yellow.shadeDefault,
    charts.MaterialPalette.indigo.shadeDefault,
    charts.MaterialPalette.pink.shadeDefault,
    charts.MaterialPalette.teal.shadeDefault,
  ];
  int index = 0;
  for (var n in input) {
    tempList = [];
    for (var y in n) {
      tempList.add(y);
    }
    if (chartTempList.length == 0) {
      chartTempList = [
        charts.MaterialPalette.green.shadeDefault,
        charts.MaterialPalette.blue.shadeDefault,
        charts.MaterialPalette.red.shadeDefault,
        charts.MaterialPalette.deepOrange.shadeDefault,
        charts.MaterialPalette.lime.shadeDefault,
        charts.MaterialPalette.purple.shadeDefault,
        charts.MaterialPalette.cyan.shadeDefault,
        charts.MaterialPalette.yellow.shadeDefault,
        charts.MaterialPalette.indigo.shadeDefault,
        charts.MaterialPalette.pink.shadeDefault,
        charts.MaterialPalette.teal.shadeDefault,
      ];
    }
    var rndInt = getRandomBetween(0, chartTempList.length);
    var color = chartTempList[rndInt];
    chartTempList.removeAt(rndInt);
    returnList.add(new charts.Series<LinearMarkChartData, int>(
        id: tempList[0].id,
        colorFn: (_, __) => color,
        domainFn: (LinearMarkChartData marks, _) => marks.count,
        measureFn: (LinearMarkChartData marks, _) => marks.value,
        data: tempList));
    index++;
  }
  return returnList;
}

int getRandomBetween(int min, int max) {
  final _random = new Random();
  return min + _random.nextInt(max - min);
}

void getAllSubjectsAv(input) {
  int index = 1;
  int sum = 0;
  for (var n in input[0]) {
    sum += int.parse(n.split(":")[1]);
    stats.globalAllSubjectAv.value = sum / index;
    if (index == input[0].length - 1) {
      stats.globalAllSubjectAv.diffSinceLast = sum / index;
    }
    index++;
  }
  stats.globalAllSubjectAv.diffSinceLast =
      (stats.globalAllSubjectAv.diffSinceLast - sum / (index - 1)) * -1;
}

void getWorstAndBest(input) {
  //TODO extend to on 100% marks
  List<stats.AV> tempList = [];
  stats.AV temp = new stats.AV();
  int index = 1;
  int sum = 0;
  for (var n in input) {
    index = 1;
    sum = 0;
    for (var y in n) {
      sum += int.parse(y.split(":")[1]);
      temp.subject = y.split(":")[0];
      temp.value = sum / index;
      if (index == n.length - 1) {
        temp.diffSinceLast = sum / index;
      }
      index++;
    }
    temp.count = index;
    temp.diffSinceLast = (temp.diffSinceLast - sum / (index - 1)) * -1;
    tempList.add(temp);
    temp = new stats.AV();
  }
  tempList.sort((a, b) =>
      b.value.toStringAsFixed(3).compareTo(a.value.toStringAsFixed(3)));
  stats.worstSubjectAv = tempList.last;
  double curValue = tempList[0].value;
  index = 0;
  List<stats.AV> tempListTwo = [];
  while (curValue == tempList[index].value) {
    tempListTwo.add(tempList[index]);
    index++;
  }
  tempListTwo.sort((a, b) => b.count.compareTo(a.count));
  stats.bestSubjectAv = tempListTwo[0];
}

void getPieChart(var input) {
  List<stats.LinearPiData> tempData = [];
  int index = 0;
  String name = "";
  for (var n in input) {
    if(n[0].split(":")[0].toLowerCase().startsWith("magyar")){
      name = n[0].split(":")[0].split(" ")[1];
    }else{
      name = n[0].split(":")[0];
    }
    if (index != 0) {
      tempData.add(new stats.LinearPiData(index, n.length, name));
    }
    index++;
  }
  tempData.sort((a, b) => a.value.compareTo(b.value));
  stats.pieList = [
    new charts.Series<stats.LinearPiData, int>(
      id: 'MarksCountPie',
      colorFn: (_, index) {
        return charts.MaterialPalette.blue.shadeDefault;
      },
      domainFn: (stats.LinearPiData sales, _) => sales.id,
      measureFn: (stats.LinearPiData sales, _) => sales.value,
      data: tempData,
      // Set a label accessor to control the text of the arc label.
      labelAccessorFn: (stats.LinearPiData row, _) =>
          '${row.name}: ${row.value}',
    )
  ];
}
