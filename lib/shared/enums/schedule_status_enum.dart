enum ScheduleStatus {
  pending('PENDING'),
  paid('PAID'),
  overdue('OVERDUE');

  const ScheduleStatus(this.value);
  final String value;

  static ScheduleStatus fromString(String? s) => switch (s) {
        'PAID'    => ScheduleStatus.paid,
        'OVERDUE' => ScheduleStatus.overdue,
        _         => ScheduleStatus.pending,
      };
}
