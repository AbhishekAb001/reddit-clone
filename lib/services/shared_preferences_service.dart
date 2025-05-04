import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _userIdKey = 'userId';
  static const String _userPhoneKey = 'userPhone';

  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();
  static SharedPreferences? _preferences;

  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  Future<void> init() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  Future<void> setLoggedIn(bool value) async {
    await _preferences?.setBool(_isLoggedInKey, value);
  }

  bool isLoggedIn() {
    return _preferences?.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setUserId(String userId) async {
    await _preferences?.setString(_userIdKey, userId);
  }

  String? getUserId() {
    return _preferences?.getString(_userIdKey);
  }

  Future<void> setUserPhone(String phone) async {
    await _preferences?.setString(_userPhoneKey, phone);
  }

  String? getUserPhone() {
    return _preferences?.getString(_userPhoneKey);
  }

  Future<void> clearUserData() async {
    await _preferences?.clear();
  }
}
