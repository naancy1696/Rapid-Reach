import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorageService {
  static const String _setupCompletedKey = 'setupCompleted';
  static const String _userNameKey = 'userName';
  static const String _userPhoneKey = 'userPhone';
  static const String _emergencyContactsKey = 'emergencyContacts';

  // ============================================================
  // SETUP STATUS
  // ============================================================

  static Future<bool> isSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_setupCompletedKey) ?? false;
  }

  static Future<void> setSetupCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_setupCompletedKey, value);
  }

  // ============================================================
  // USER DETAILS
  // ============================================================

  static Future<void> saveUserDetails({
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userPhoneKey, phone);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userNameKey);
  }

  static Future<String?> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_userPhoneKey);
  }

  // ============================================================
  // EMERGENCY CONTACTS
  // ============================================================

  static Future<void> saveEmergencyContacts(
    List<Map<String, String>> contacts,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final encodedContacts = jsonEncode(contacts);

    await prefs.setString(
      _emergencyContactsKey,
      encodedContacts,
    );
  }

  static Future<List<Map<String, String>>>
      getEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final storedContacts =
        prefs.getString(_emergencyContactsKey);

    if (storedContacts == null || storedContacts.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(storedContacts);

    return List<Map<String, String>>.from(
      decoded.map(
        (contact) => Map<String, String>.from(contact),
      ),
    );
  }

  // ============================================================
  // CLEAR ALL DATA
  // ============================================================

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_setupCompletedKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_emergencyContactsKey);
  }
}