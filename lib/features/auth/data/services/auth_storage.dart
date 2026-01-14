import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class SessionData {
  final String token;
  final UserModel user;

  SessionData(this.token, this.user);
}

class AuthStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  Future<void> persist(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, user.toRawJson());
  }

  Future<SessionData?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final rawUser = prefs.getString(_userKey);
    final user = UserModel.fromRawJson(rawUser);
    if (token == null || user == null) return null;
    return SessionData(token, user);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
