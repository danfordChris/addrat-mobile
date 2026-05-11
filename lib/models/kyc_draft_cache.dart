class KycDraftCache {
  final int step;
  final String? personalInfoJson;
  final String? employmentInfoJson;
  final String? financialDetailsJson;
  final DateTime lastUpdated;

  KycDraftCache({
    required this.step,
    this.personalInfoJson,
    this.employmentInfoJson,
    this.financialDetailsJson,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() => {
    'step': step,
    'personalInfoJson': personalInfoJson,
    'employmentInfoJson': employmentInfoJson,
    'financialDetailsJson': financialDetailsJson,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory KycDraftCache.fromMap(Map<dynamic, dynamic> map) => KycDraftCache(
    step: map['step'] as int,
    personalInfoJson: map['personalInfoJson'] as String?,
    employmentInfoJson: map['employmentInfoJson'] as String?,
    financialDetailsJson: map['financialDetailsJson'] as String?,
    lastUpdated: DateTime.parse(map['lastUpdated'] as String),
  );
}
