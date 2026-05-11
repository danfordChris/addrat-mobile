class BankModel {
  final int id;
  final String name;
  final String code;

  const BankModel({
    required this.id,
    required this.name,
    required this.code,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) => BankModel(
        id: json['id'] as int,
        name: json['name'] as String,
        code: json['code'] as String,
      );
}

class BranchModel {
  final int id;
  final String name;
  final int bankId;

  const BranchModel({
    required this.id,
    required this.name,
    required this.bankId,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        id: json['id'] as int,
        name: json['name'] as String,
        bankId: json['bankId'] as int,
      );
}
