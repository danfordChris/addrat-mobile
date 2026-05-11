class LoanModel {
  final String id;
  final String status;
  final double principalAmount;
  final double outstandingAmount;
  final DateTime? nextDueDate;

  const LoanModel({
    required this.id,
    required this.status,
    required this.principalAmount,
    required this.outstandingAmount,
    this.nextDueDate,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['id'] as String,
        status: json['status'] as String,
        principalAmount: (json['principalAmount'] as num).toDouble(),
        outstandingAmount: (json['outstandingAmount'] as num).toDouble(),
        nextDueDate: json['nextDueDate'] != null
            ? DateTime.tryParse(json['nextDueDate'] as String)
            : null,
      );
}
