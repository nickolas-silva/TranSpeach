enum DatabaseTables {
  MESSAGES("messages");

  const DatabaseTables(this.value);
  final String value;
}

extension ParseToString on DatabaseTables {
  String toShortString() {
    return this.toString().split('.').last;
  }
}