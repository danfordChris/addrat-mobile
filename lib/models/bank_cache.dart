class BankCache {
  final String branchesJson;
  final DateTime cachedAt;

  BankCache({
    required this.branchesJson,
    required this.cachedAt,
  });

  bool get isStale => DateTime.now().difference(cachedAt).inDays > 7;

  Map<String, dynamic> toMap() => {
    'branchesJson': branchesJson,
    'cachedAt': cachedAt.toIso8601String(),
  };

  factory BankCache.fromMap(Map<dynamic, dynamic> map) => BankCache(
    branchesJson: map['branchesJson'] as String,
    cachedAt: DateTime.parse(map['cachedAt'] as String),
  );
}
