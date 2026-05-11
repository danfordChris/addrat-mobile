class AppPreferences {
  final String selectedLanguage;
  final bool hasSeenOnboarding;
  final String? kycStatus;
  final String themeMode;

  const AppPreferences({
    this.selectedLanguage = 'en',
    this.hasSeenOnboarding = false,
    this.kycStatus,
    this.themeMode = 'system',
  });

  AppPreferences copyWith({
    String? selectedLanguage,
    bool? hasSeenOnboarding,
    String? kycStatus,
    String? themeMode,
    bool clearKycStatus = false,
  }) =>
      AppPreferences(
        selectedLanguage: selectedLanguage ?? this.selectedLanguage,
        hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
        kycStatus: clearKycStatus ? null : (kycStatus ?? this.kycStatus),
        themeMode: themeMode ?? this.themeMode,
      );
}
