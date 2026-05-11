enum KycStatus {
  notStarted('NOT_STARTED'),
  pending('PENDING'),
  approved('APPROVED'),
  rejected('REJECTED');

  const KycStatus(this.value);
  final String value;

  static KycStatus fromString(String? s) => switch (s) {
        'PENDING'  => KycStatus.pending,
        'APPROVED' => KycStatus.approved,
        'VERIFIED' => KycStatus.approved, // legacy backend value
        'REJECTED' => KycStatus.rejected,
        'EXPIRED'  => KycStatus.rejected,
        _          => KycStatus.notStarted,
      };

  static KycStatus? fromStringOrNull(String? s) {
    if (s == null) return null;
    return KycStatus.values.firstWhereOrNull((e) => e.value == s);
  }
}

extension _ListExt<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }
}
