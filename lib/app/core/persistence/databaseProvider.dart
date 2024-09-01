import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:transpeach/app/core/constants/db_const.dart';

class DatabaseProvider{
 Future<Database> getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), 'ts-dev.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE ${DatabaseTables.MESSAGES} (id INTEGER PRIMARY KEY, text VARCHAR(255), send_at DATETIME);'
          );
        },
        version: 1
    );
  }
}