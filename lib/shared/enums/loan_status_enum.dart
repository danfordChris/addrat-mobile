enum LoanStatus {
  pending('PENDING'),
  approved('APPROVED'),
  disbursementPending('DISBURSEMENT_PENDING'),
  disbursementFailed('DISBURSEMENT_FAILED'),
  active('ACTIVE'),
  overdue('OVERDUE'),
  rejected('REJECTED'),
  completed('COMPLETED'),
  closed('CLOSED');

  const LoanStatus(this.value);
  final String value;

  static LoanStatus fromString(String? s) => switch (s) {
        'APPROVED' => LoanStatus.approved,
        'DISBURSEMENT_PENDING' => LoanStatus.disbursementPending,
        'DISBURSEMENT_FAILED' => LoanStatus.disbursementFailed,
        'ACTIVE'   => LoanStatus.active,
        'OVERDUE'  => LoanStatus.overdue,
        'REJECTED' => LoanStatus.rejected,
        'COMPLETED' => LoanStatus.completed,
        'CLOSED'   => LoanStatus.closed,
        _          => LoanStatus.pending,
      };

  bool get isLive => this == LoanStatus.active || this == LoanStatus.overdue;
}
