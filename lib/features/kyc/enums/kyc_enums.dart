enum EmploymentStatus {
  employed('EMPLOYED', 'Employed'),
  selfEmployed('SELF_EMPLOYED', 'Self-Employed'),
  unemployed('UNEMPLOYED', 'Unemployed');

  const EmploymentStatus(this.value, this.label);
  final String value;
  final String label;

  static EmploymentStatus? fromString(String? s) => switch (s?.toUpperCase()) {
        'EMPLOYED'       => EmploymentStatus.employed,
        'SELF_EMPLOYED'  => EmploymentStatus.selfEmployed,
        'UNEMPLOYED'     => EmploymentStatus.unemployed,
        _                => null,
      };
}

enum MaritalStatus {
  single('SINGLE'),
  married('MARRIED'),
  divorced('DIVORCED'),
  widowed('WIDOWED');

  const MaritalStatus(this.value);
  final String value;

  String get label => switch (this) {
        MaritalStatus.single   => 'Single',
        MaritalStatus.married  => 'Married',
        MaritalStatus.divorced => 'Divorced',
        MaritalStatus.widowed  => 'Widowed',
      };

  static MaritalStatus? fromString(String? s) => switch (s?.toUpperCase()) {
        'SINGLE'   => MaritalStatus.single,
        'MARRIED'  => MaritalStatus.married,
        'DIVORCED' => MaritalStatus.divorced,
        'WIDOWED'  => MaritalStatus.widowed,
        _          => null,
      };
}

enum Gender {
  male('MALE'),
  female('FEMALE');

  const Gender(this.value);
  final String value;

  String get label => switch (this) {
        Gender.male   => 'Male',
        Gender.female => 'Female',
      };

  static Gender? fromString(String? s) => switch (s?.toUpperCase()) {
        'MALE'   => Gender.male,
        'FEMALE' => Gender.female,
        _        => null,
      };
}

enum IncomeSource {
  salary('SALARY'),
  business('BUSINESS'),
  agriculture('AGRICULTURE'),
  rental('RENTAL'),
  remittance('REMITTANCE'),
  other('OTHER');

  const IncomeSource(this.value);
  final String value;

  String get label => value.replaceAll('_', ' ');

  static IncomeSource? fromString(String? s) => switch (s?.toUpperCase()) {
        'SALARY'      => IncomeSource.salary,
        'BUSINESS'    => IncomeSource.business,
        'AGRICULTURE' => IncomeSource.agriculture,
        'RENTAL'      => IncomeSource.rental,
        'REMITTANCE'  => IncomeSource.remittance,
        'OTHER'       => IncomeSource.other,
        _             => null,
      };
}


enum KycStepScreens {
  personalInfo('PERSONAL_INFO', 'Personal Information', 1),
  employmentInfo('EMPLOYMENT_INFO', 'Employment Information', 2),
  financialInfo('FINANCIAL_INFO', 'Financial Information', 3),
  kycReview('KYC_REVIEW', 'Review & Submit', 4);

  const KycStepScreens(this.value, this.description, this.stepNumber);

  final String value;
  final String description;
  final int stepNumber;

  static KycStepScreens? fromString(String? s) => switch (s?.toUpperCase()) {
        'PERSONAL_INFO' => KycStepScreens.personalInfo,
        'EMPLOYMENT_INFO' => KycStepScreens.employmentInfo,
        'FINANCIAL_INFO' => KycStepScreens.financialInfo,
          'KYC_REVIEW' => KycStepScreens.kycReview,
        _ => null,
      };

  static KycStepScreens? fromStep(int? step) => switch (step) {
        1 => KycStepScreens.personalInfo,
        2 => KycStepScreens.employmentInfo,
        3 => KycStepScreens.financialInfo,
        4 => KycStepScreens.kycReview,
        _ => null,
      };
}


