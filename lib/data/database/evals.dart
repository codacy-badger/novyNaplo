import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:novynaplo/data/models/evals.dart';
import 'package:novynaplo/data/models/extensions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:novynaplo/global.dart' as globals;

Future<List<Evals>> getAllEvals() async {
  FirebaseCrashlytics.instance.log("getAllEvals");

  final List<Map<String, dynamic>> maps = await globals.db.rawQuery(
    'SELECT * FROM Evals GROUP BY uid, userId ORDER BY databaseId',
  );

  List<Evals> tempList = List.generate(maps.length, (i) {
    Evals temp = new Evals.fromSqlite(maps[i]);
    return temp;
  });

  tempList.sort(
    (a, b) {
      if (a.date.isSameDay(b.date)) {
        return b.createDate.compareTo(a.createDate);
      } else {
        return b.date.compareTo(a.date);
      }
    },
  );
  return tempList;
}

// A function that inserts multiple evals into the database
Future<void> batchInsertEvals(List<Evals> evalList) async {
  FirebaseCrashlytics.instance.log("batchInsertEval");
  bool inserted = false;
  // Get a reference to the database.
  final Batch batch = globals.db.batch();

  //Get all evals, and see whether we should be just replacing
  List<Evals> allEvals = await getAllEvals();
  for (var eval in evalList) {
    var matchedEvals = allEvals.where(
      (element) {
        return (element.uid == eval.uid && element.userId == eval.userId);
      },
    );
    if (matchedEvals.length == 0) {
      inserted = true;
      batch.insert(
        'Evals',
        eval.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      //FIXME Notification dispatch
    } else {
      for (var n in matchedEvals) {
        //!Update didn't work so we delete and create a new one
        if ((n.numberValue != eval.numberValue ||
                n.theme != eval.theme ||
                n.date.toUtc().toIso8601String() !=
                    eval.date.toUtc().toIso8601String() ||
                n.weight != eval.weight) &&
            n.uid == eval.uid) {
          inserted = true;
          batch.delete(
            "Evals",
            where: "databaseId = ?",
            whereArgs: [n.databaseId],
          );
          batch.insert(
            'Evals',
            eval.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
  }
  if (inserted) {
    await batch.commit();
  }
}