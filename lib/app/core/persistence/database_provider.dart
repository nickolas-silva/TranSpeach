import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:transpeach/app/core/persistence/data.dart';

class DatabaseProvider{
 Future<Database> getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'ts-dev.db'),
        onCreate: (db, version) {
          return db.execute(
            sqlSchema()
          );
        },
        version: 1
    );
  }
}