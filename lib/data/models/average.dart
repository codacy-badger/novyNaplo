class Average {
  double value;
  double diffSinceLast;
  String subject = "";
  double count = 0;
  int databaseId;
  int userId;

  @override
  String toString() {
    return this.subject + ": " + this.value.toStringAsFixed(3);
  }

  Map<String, dynamic> toMap() {
    return {
      'databaseId': databaseId,
      'subject': subject,
      'ownValue': value,
      'userId': userId,
    };
  }
}
//FIXME: Andrew says his average calculations are not always right