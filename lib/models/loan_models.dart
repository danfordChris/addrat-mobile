class LoanModel {
  final int id;
  final int? userId;
  final double principalAmount;
  final double? applicationFee;
  final double? monthlyInterest;
  final double? totalAmountDue;
  final int? durationMonths;
  final int? termDays;
  final String status;
  final double? outstandingPrincipal;
  final double? totalRepaid;
  final int? daysPastDue;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final DateTime? approvedAt;
  final DateTime? disbursedAt;

  const LoanModel({
    required this.id,
    this.userId,
    required this.principalAmount,
    this.applicationFee,
    this.monthlyInterest,
    this.totalAmountDue,
    this.durationMonths,
    this.termDays,
    required this.status,
    this.outstandingPrincipal,
    this.totalRepaid,
    this.daysPastDue,
    this.dueDate,
    this.createdAt,
    this.approvedAt,
    this.disbursedAt,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['id'] as int,
        userId: json['userId'] as int?,
        principalAmount: (json['principalAmount'] as num).toDouble(),
        applicationFee: json['applicationFee'] != null
            ? (json['applicationFee'] as num).toDouble()
            : null,
        monthlyInterest: json['monthlyInterest'] != null
            ? (json['monthlyInterest'] as num).toDouble()
            : null,
        totalAmountDue: json['totalAmountDue'] != null
            ? (json['totalAmountDue'] as num).toDouble()
            : null,
        durationMonths: json['durationMonths'] as int?,
        termDays: json['termDays'] as int?,
        status: json['status'] as String,
        outstandingPrincipal: json['outstandingPrincipal'] != null
            ? (json['outstandingPrincipal'] as num).toDouble()
            : null,
        totalRepaid: json['totalRepaid'] != null
            ? (json['totalRepaid'] as num).toDouble()
            : null,
        daysPastDue: json['daysPastDue'] as int?,
        dueDate: json['dueDate'] != null
            ? DateTime.tryParse(json['dueDate'] as String)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        approvedAt: json['approvedAt'] != null
            ? DateTime.tryParse(json['approvedAt'] as String)
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
