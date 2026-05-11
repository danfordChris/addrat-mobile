class NidData {
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? gender;
  final String? dateOfBirth;
  final String? physicalAddress;

  const NidData({
    this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.dateOfBirth,
    this.physicalAddress,
  });
}

class NidExtractor {
  NidExtractor._();

  /// Extracts NID data from recognized text lines.
  /// Returns null if parsing fails or text is insufficient.
  static NidData? extract(List<String> lines) {
    try {
      return _parse(lines);
    } catch (_) {
      return null;
    }
  }

  static NidData? _parse(List<String> lines) {
    final text = lines.join('\n').toUpperCase();

    final dobMatch = RegExp(
            r'(\d{2}[/-]\d{2}[/-]\d{4}|\d{4}[/-]\d{2}[/-]\d{2})')
        .firstMatch(text);
    final dateOfBirth = dobMatch?.group(0);

    String? gender;
    if (text.contains('FEMALE') || text.contains('F ')) {
      gender = 'FEMALE';
    } else if (text.contains('MALE') || text.contains('M ')) {
      gender = 'MALE';
    }

    // Name extraction — look for lines after "NAMES:" or "JINA:" label
    String? firstName, middleName, lastName;
    final nameIdx = lines.indexWhere(
        (l) => RegExp(r'NAMES?:|JINA', caseSensitive: false).hasMatch(l));
    if (nameIdx != -1 && nameIdx + 1 < lines.length) {
      final nameLine = lines[nameIdx + 1].trim();
      final parts = nameLine.split(RegExp(r'\s+'));
      if (parts.isNotEmpty) firstName = _toTitleCase(parts[0]);
      if (parts.length == 2) lastName = _toTitleCase(parts[1]);
      if (parts.length >= 3) {
        middleName = _toTitleCase(parts[1]);
        lastName = _toTitleCase(parts[2]);
      }
    }

    // Address extraction
    String? physicalAddress;
    final addrIdx = lines.indexWhere(
        (l) => RegExp(r'ADDRESS|ANUANI|MAKAZI', caseSensitive: false).hasMatch(l));
    if (addrIdx != -1 && addrIdx + 1 < lines.length) {
      physicalAddress = lines[addrIdx + 1].trim();
    }

    if (firstName == null && lastName == null && dateOfBirth == null) return null;

    return NidData(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      physicalAddress: physicalAddress,
    );
  }

  static String _toTitleCase(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
}
