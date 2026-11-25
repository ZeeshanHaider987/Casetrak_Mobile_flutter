import 'package:shared_preferences/shared_preferences.dart';

abstract class PrefsStore {
  String? get lastEmail;
  Future<void> setLastEmail(String email);
}

class SharedPrefsStore implements PrefsStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;
  static const _lastEmail = 'last_email';

  @override
  String? get lastEmail => _prefs.getString(_lastEmail);

  @override
  Future<void> setLastEmail(String email) => _prefs.setString(_lastEmail, email);
}

class MemoryPrefsStore implements PrefsStore {
  String? _lastEmail;

  @override
  String? get lastEmail => _lastEmail;

  @override
  Future<void> setLastEmail(String email) async => _lastEmail = email;
}
