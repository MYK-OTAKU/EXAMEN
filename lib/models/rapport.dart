class Rapport {
  final int? id;
  final int enginId;
  final String date;
  final double usage;

  Rapport({
    this.id,
    required this.enginId,
    required this.date,
    required this.usage,
  });

  // Conversion depuis Map (SQLite)
  factory Rapport.fromMap(Map<String, dynamic> map) {
    return Rapport(
      id: map['id'],
      enginId: map['enginId'],
      date: map['date'],
      usage: map['usage'],
    );
  }

  // Conversion vers Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'enginId': enginId,
      'date': date,
      'usage': usage,
    };
  }

  @override
  String toString() {
    return 'Rapport{id: $id, enginId: $enginId, date: $date, usage: $usage}';
  }
}
