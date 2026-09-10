import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SetupStorage {
  SetupStorage._();

  static const String _setupCompletedKey = 'setup_completed';
  static const String _userNameKey = 'user_name';
  static const String _userPhoneKey = 'user_phone';
  static const String _emergencyContactsKey = 'emergency_contacts';

  // ============================================================
  // SETUP STATUS
  // ============================================================

  static Future<bool> isSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_setupCompletedKey) ?? false;
  }

  // ============================================================
  // USER DETAILS
  // ============================================================

  static Future<void> saveUserDetails({
    required String name,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _userNameKey,
      name,
    );

    await prefs.setString(
      _userPhoneKey,
      phone,
    );
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

  static Future<List<Map<String, String>>> getEmergencyContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final storedContacts =
        prefs.getString(_emergencyContactsKey);

    if (storedContacts == null || storedContacts.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(storedContacts);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map<Map<String, String>>(
            (contact) => Map<String, String>.from(contact),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // COMPLETE SETUP
  // ============================================================

  static Future<void> markSetupCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _setupCompletedKey,
      true,
    );
  }

  // ============================================================
  // CLEAR ALL SETUP DATA
  // ============================================================

  static Future<void> clearSetup() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_setupCompletedKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userPhoneKey);
    await prefs.remove(_emergencyContactsKey);
  }
}