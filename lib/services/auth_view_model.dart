import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/convention_models.dart';
import 'registration_api.dart' show RegistrationAPI, RegistrationAPIError;

class AuthViewModel extends ChangeNotifier {
  AttendeeProfile profile = AttendeeProfile();
  bool isLoggedIn = false;
  bool isLoading = false;
  bool isSendingCode = false;
  String? errorMessage;
  String? infoMessage;

  static const _profileKey = 'haa_attendee_profile';

  AuthViewModel() {
    loadSaved();
  }

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_profileKey);
    if (data == null) return;
    try {
      final saved = AttendeeProfile.fromJson(jsonDecode(data) as Map<String, dynamic>);
      profile = saved;
      isLoggedIn = saved.isLoggedIn;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> save() async {
    profile.isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    notifyListeners();
  }

  String get displayName {
    final name = '${profile.firstName} ${profile.lastName}'.trim();
    return name.isEmpty ? profile.email : name;
  }

  Future<void> sendLoginCode(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      errorMessage = 'Please enter the registrant email address.';
      notifyListeners();
      return;
    }
    isSendingCode = true;
    errorMessage = null;
    infoMessage = null;
    notifyListeners();
    try {
      infoMessage = await RegistrationAPI.sendLoginCode(trimmed);
    } catch (e) {
      errorMessage = _errorText(e);
    }
    isSendingCode = false;
    notifyListeners();
  }

  Future<void> login(String email, String code) async {
    final trimmedEmail = email.trim();
    final trimmedCode = code.trim();
    if (trimmedEmail.isEmpty) {
      errorMessage = 'Please enter the registrant email address.';
      notifyListeners();
      return;
    }
    if (trimmedCode.length != 5 || !RegExp(r'^\d+$').hasMatch(trimmedCode)) {
      errorMessage = 'Please enter your 5-digit login code.';
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final loaded = await RegistrationAPI.login(trimmedEmail, trimmedCode);
      loaded.isLoggedIn = true;
      profile = loaded;
      await save();
      isLoggedIn = true;
    } catch (e) {
      errorMessage = _errorText(e);
    }
    isLoading = false;
    notifyListeners();
  }

  void clearMessages() {
    errorMessage = null;
    infoMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    profile = AttendeeProfile();
    isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
    notifyListeners();
  }

  Future<bool> refreshRegistrationStatus() async {
    final email = profile.email.trim();
    if (!isLoggedIn || email.isEmpty) return false;
    try {
      final updated = await RegistrationAPI.fetchStatus(email);
      final wasCheckedIn = profile.hasCheckedIn;
      profile.firstName = updated.firstName;
      profile.lastName = updated.lastName;
      profile.registrationId = updated.registrationId;
      if (updated.registrationUuid.isNotEmpty) {
        profile.registrationUuid = updated.registrationUuid;
      }
      profile.hasCheckedIn = updated.hasCheckedIn;
      await save();
      return !wasCheckedIn && updated.hasCheckedIn;
    } catch (_) {
      return false;
    }
  }

  void markCheckedInFromVolunteerScan() {
    infoMessage = "You're checked in. Welcome to the convention!";
    notifyListeners();
  }

  String _errorText(Object e) {
    if (e is RegistrationAPIError) return e.message;
    return 'Something went wrong. Please try again.';
  }
}
