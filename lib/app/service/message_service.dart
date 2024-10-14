import 'package:sqflite/sqflite.dart';
import 'package:transpeach/app/core/constants/db_const.dart';
import 'package:transpeach/app/core/persistence/database_provider.dart';
import 'package:transpeach/app/model/message.dart';

class MessageService {
  static MessageService instance = MessageService();

  Future<Message> save(Message message) async {
    try {
      final Database db = await DatabaseProvider().getDatabase();

      if (message.id != 0 && message.id != null) {
        await db.update(
          DatabaseTables.MESSAGES.toShortString(),
          message.toJson(),
          where: 'id = ?', 
          whereArgs: [message.id]
        );
        return message;
      }
      return await getById(await db.insert(DatabaseTables.MESSAGES.toShortString(), message.toJson()));
    } catch (ex) {
      rethrow;
    }
  }

  Future<Message> getById(int id) async {
    try {
      final Database db = await DatabaseProvider().getDatabase();

      var data = await db.query(
          DatabaseTables.MESSAGES.toShortString(),
          where: 'id = ?',
          whereArgs: [id]
        );

      return Message.fromJson(data[0]);
    } catch (ex) {
      print(ex);
      rethrow;
    }
  }

  Future<bool> deleteById(int id) async {
    try {
      final Database db = await DatabaseProvider().getDatabase();

      await db.delete(
        DatabaseTables.MESSAGES.toShortString(),
        where: 'id = ?',
        whereArgs: [id]
      );

      return true;
    } catch (ex) {
      rethrow;
    }
  }

  Future<List<Message>> getAll() async {
    try {
      final Database db = await DatabaseProvider().getDatabase();

      List<Map<String, Object?>> data = await db.query(
        DatabaseTables.MESSAGES.toShortString(),
      );

      List<Message> messages = [];

      for (var el in data) {
        messages.add(Message.fromJson(el));
      }

      return messages;
    } catch (ex) {
      rethrow;
    }
  }
}
