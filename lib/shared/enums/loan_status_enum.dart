enum LoanStatus {
  pending('PENDING'),
  approved('APPROVED'),
  active('ACTIVE'),
  overdue('OVERDUE'),
  rejected('REJECTED'),
  closed('CLOSED');

  const LoanStatus(this.value);
  final String value;

  static LoanStatus fromString(String? s) => switch (s) {
        'APPROVED' => LoanStatus.approved,
        'ACTIVE'   => LoanStatus.active,
        'OVERDUE'  => LoanStatus.overdue,
        'REJECTED' => LoanStatus.rejected,
        'CLOSED'   => LoanStatus.closed,
        _          => LoanStatus.pending,
      };

  bool get isLive => this == LoanStatus.active || this == LoanStatus.overdue;
}
