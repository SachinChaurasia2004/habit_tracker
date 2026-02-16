extension StringExtensions on String {
  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Check if string is empty or whitespace
  bool get isBlank => trim().isEmpty;

  /// Check if string is not empty
  bool get isNotBlank => trim().isNotEmpty;

  /// Truncate string to max length
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Remove all whitespace
  String removeWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

extension IntExtensions on int {
  /// Convert to days text
  String get daysText => this == 1 ? 'day' : 'days';

  /// Convert to ordinal (1st, 2nd, 3rd, etc.)
  String get ordinal {
    if (this >= 11 && this <= 13) return '${this}th';
    switch (this % 10) {
      case 1:
        return '${this}st';
      case 2:
        return '${this}nd';
      case 3:
        return '${this}rd';
      default:
        return '${this}th';
    }
  }
}

extension DoubleExtensions on double {
  /// Round to N decimal places
  double roundToDecimals(int decimals) {
    final mod = 10.0 * decimals;
    return ((this * mod).round().toDouble() / mod);
  }

  /// Convert to percentage string
  String toPercentage({int decimals = 0}) {
    return '${roundToDecimals(decimals).toInt()}%';
  }
}