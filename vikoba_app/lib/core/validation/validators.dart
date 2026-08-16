/// Field-level validation helpers shared by all forms.
///
/// Each method returns `null` when the input is valid, otherwise a short,
/// user-friendly error string. The UI shows these inline under the offending
/// `TextFormField`.
///
/// IMPORTANT: these are UX-only. The backend re-validates **everything**
/// (see `backend/app/Requests/*.php`) because a mobile client can always be
/// tampered with — never trust the Flutter layer for money rules.
abstract final class Validators {
  /// Normalizes a Tanzanian number to its bare 9-digit form:
  ///   0712345678 -> 12345678
  ///   +255712345678 -> 12345678
  ///   255 712 345 678 -> 12345678
  /// Returns null when the number of digits after stripping prefixes != 9.
  static String? normalizeTzPhone(String? value) {
    var s = (value ?? '').trim().replaceAll(RegExp(r'[\s\-()]'), '');
    if (s.startsWith('+')) s = s.substring(1);
    if (s.startsWith('255')) s = s.substring(3);
    if (s.startsWith('0')) s = s.substring(1);
    return s.length == 9 ? s : null;
  }

  static String? tanzanianPhone(String? value) {
    final s = (value ?? '').trim();
    if (s.isEmpty) return 'Enter a phone number';
    return normalizeTzPhone(s) == null
        ? 'Invalid number — use +255… or 07…'
        : null;
  }

  static String? required(String? value, String label) =>
      (value == null || value.trim().isEmpty) ? '$label is required' : null;

  static String? positiveNumber(String? value, {String label = 'Amount'}) {
    final v = double.tryParse((value ?? '').trim());
    if (v == null) return '$label must be a number';
    if (v <= 0) return '$label must be greater than zero';
    return null;
  }

  static String? wholePositiveInt(String? value) {
    final v = int.tryParse((value ?? '').trim());
    if (v == null) return 'Enter a whole number';
    if (v <= 0) return 'Must be at least 1';
    return null;
  }
}
