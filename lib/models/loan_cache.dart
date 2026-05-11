class LoanCache {
  final String id;
  final String dataJson;

  LoanCache({
    required this.id,
    required this.dataJson,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'dataJson': dataJson,
  };

  factory LoanCache.fromMap(Map<dynamic, dynamic> map) => LoanCache(
    id: map['id'] as String,
    dataJson: map['dataJson'] as String,
  );
}
