class KycStatusResponse {
  final String status;
  final List<int> completedSteps;

  const KycStatusResponse({
    required this.status,
    required this.completedSteps,
  });

  factory KycStatusResponse.fromJson(Map<String, dynamic> json) =>
      KycStatusResponse(
        status: json['status'] as String,
        completedSteps: (json['completedSteps'] as List?)
                ?.map((e) => e as int)
                .toList() ??
            [],
      );
}

class PersonalInfoDto {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String gender;
  final String dateOfBirth;
  final String maritalStatus;
  final String nidaNumber;
  final String physicalAddress;

  const PersonalInfoDto({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.gender,
    required this.dateOfBirth,
    required this.maritalStatus,
    required this.nidaNumber,
    required this.physicalAddress,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        if (middleName != null) 'middleName': middleName,
        'lastName': lastName,
        'gender': gender,
        'dateOfBirth': dateOfBirth,
        'maritalStatus': maritalStatus,
        'nidaNumber': nidaNumber,
        'physicalAddress': physicalAddress,
      };
}

class EmploymentInfoDto {
  final String employmentStatus;
  final String? employerName;
  final String? employerAddress;
  final String? tinNumber;
  final String? businessName;
  final String? businessTinNumber;
  final String? businessRegistrationNumber;
  final int numberOfDependants;

  const EmploymentInfoDto({
    required this.employmentStatus,
    this.employerName,
    this.employerAddress,
    this.tinNumber,
    this.businessName,
    this.businessTinNumber,
    this.businessRegistrationNumber,
    required this.numberOfDependants,
  });

  Map<String, dynamic> toJson() => {
        'employmentStatus': employmentStatus,
        if (employerName != null) 'employerName': employerName,
        if (employerAddress != null) 'employerAddress': employerAddress,
        if (tinNumber != null) 'tinNumber': tinNumber,
        if (businessName != null) 'businessName': businessName,
        if (businessTinNumber != null) 'businessTinNumber': businessTinNumber,
        if (businessRegistrationNumber != null)
          'businessRegistrationNumber': businessRegistrationNumber,
        'numberOfDependants': numberOfDependants,
      };
}

class FinancialDetailsDto {
  final int bankId;
  final int branchId;
  final String accountNumber;
  final String sourceOfIncome;
  final String incomeRange;

  const FinancialDetailsDto({
    required this.bankId,
    required this.branchId,
    required this.accountNumber,
    required this.sourceOfIncome,
    required this.incomeRange,
  });

  Map<String, dynamic> toJson() => {
        'bankId': bankId,
        'branchId': branchId,
        'accountNumber': accountNumber,
        'sourceOfIncome': sourceOfIncome,
        'incomeRange': incomeRange,
      };
}
