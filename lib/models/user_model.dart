class UserModel {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? kycStatus;

  const UserModel({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.kycStatus,
  });

  String get fullName => [firstName, lastName].whereType<String>().join(' ');

  String get initials {
    final f = firstName?.isNotEmpty == true ? firstName![0] : '';
    final l = lastName?.isNotEmpty == true ? lastName![0] : '';
    final combined = '$f$l'.toUpperCase();
    return combined.isNotEmpty ? combined : phoneNumber.substring(0, 2);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        phoneNumber: json['phoneNumber'] as String,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        kycStatus: json['kycStatus'] as String?,
      );
}
