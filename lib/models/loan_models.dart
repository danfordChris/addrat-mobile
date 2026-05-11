class LoanModel {
  final String id;
  final String status;
  final double principalAmount;
  final double outstandingAmount;
  final double interestRate;
  final int termMonths;
  final DateTime? nextDueDate;
  final DateTime? disbursedAt;

  const LoanModel({
    required this.id,
    required this.status,
    required this.principalAmount,
    required this.outstandingAmount,
    required this.interestRate,
    required this.termMonths,
    this.nextDueDate,
    this.disbursedAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['id'] as String,
        status: json['status'] as String,
        principalAmount: (json['principalAmount'] as num).toDouble(),
        outstandingAmount: (json['outstandingAmount'] as num).toDouble(),
        interestRate: (json['interestRate'] as num).toDouble(),
        termMonths: json['termMonths'] as int,
        nextDueDate: json['nextDueDate'] != null
            ? DateTime.tryParse(json['nextDueDate'] as String)
            : null,
        disbursedAt: json['disbursedAt'] != null
            ? DateTime.tryParse(json['disbursedAt'] as String)
            : null,
      );
}

class LoanApplicationDto {
  final double amount;
  final int termMonths;
  final String purpose;

  const LoanApplicationDto({
    required this.amount,
    required this.termMonths,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'termMonths': termMonths,
        'purpose': purpose,
      };
}
