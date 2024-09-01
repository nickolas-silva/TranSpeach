import 'package:transpeach/app/core/constants/db_const.dart';

String sqlSchema() {
  return ''
      'CREATE TABLE ${DatabaseTables.MESSAGES.toShortString()} (id INTEGER PRIMARY KEY, text TEXT, sendAt TEXT, isTranslated BOOLEAN, translatedText TEXT);'
  '';
}