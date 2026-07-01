import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/convention_models.dart';

class RegistrationAPIError implements Exception {
  RegistrationAPIError(this.message);
  final String message;
  @override
  String toString() => message;
}

class RegistrationAPI {
  static const baseURL = 'https://havyak.org/api/auth.php';
  static const apiKey = '';

  static Future<String> sendLoginCode(String email) async {
    final raw = await _postRaw({'action': 'sendcode', 'email': email});
    final decoded = _decodeJson(raw);
    if (raw.statusCode == 200 && decoded['success'] == true) {
      return decoded['message'] as String? ?? 'Login code sent to your email.';
    }
    throw RegistrationAPIError(
      decoded['error'] as String? ??
          decoded['message'] as String? ??
          'Could not send login code.',
    );
  }

  static Future<AttendeeProfile> login(String email, String code) async {
    final raw = await _postRaw({'action': 'login', 'email': email, 'code': code});
    final decoded = _decodeJson(raw);
    if (raw.statusCode == 200 &&
        decoded['success'] == true &&
        decoded['profile'] != null) {
      return _profileFromApi(decoded['profile'] as Map<String, dynamic>);
    }
    throw RegistrationAPIError(decoded['error'] as String? ?? 'Login failed.');
  }

  static Future<AttendeeProfile> fetchStatus(String email) async {
    final raw = await _postRaw({'action': 'status', 'email': email});
    final decoded = _decodeJson(raw);
    if (raw.statusCode == 200 &&
        decoded['success'] == true &&
        decoded['profile'] != null) {
      return _profileFromApi(decoded['profile'] as Map<String, dynamic>);
    }
    throw RegistrationAPIError(
      decoded['error'] as String? ?? 'Could not refresh registration status.',
    );
  }

  static AttendeeProfile _profileFromApi(Map<String, dynamic> p) {
    return AttendeeProfile(
      firstName: p['firstName'] as String? ?? '',
      lastName: p['lastName'] as String? ?? '',
      email: p['email'] as String? ?? '',
      role: AttendeeRole.values.firstWhere(
        (r) => r.name == (p['role'] as String? ?? 'registrant'),
        orElse: () => AttendeeRole.registrant,
      ),
      registrationId: p['registrationId'] as String? ?? '',
      registrationUuid: p['uuid'] as String? ?? '',
      hasCheckedIn: p['hasCheckedIn'] as bool? ?? false,
      isLoggedIn: true,
    );
  }

  static Future<_RawResponse> _postRaw(Map<String, String> body) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (apiKey.isNotEmpty) headers['X-API-Key'] = apiKey;
      final response = await http.post(
        Uri.parse(baseURL),
        headers: headers,
        body: jsonEncode(body),
      );
      return _RawResponse(response.statusCode, response.body);
    } catch (e) {
      return _RawResponse(0, e.toString());
    }
  }

  static Map<String, dynamic> _decodeJson(_RawResponse raw) {
    if (raw.statusCode == 0) {
      throw RegistrationAPIError(
        'No internet connection. Sign in requires an active network connection.',
      );
    }
    try {
      return jsonDecode(raw.body) as Map<String, dynamic>;
    } catch (_) {
      throw RegistrationAPIError(
        'Could not read server response. Please try again.',
      );
    }
  }
}

class _RawResponse {
  _RawResponse(this.statusCode, this.body);
  final int statusCode;
  final String body;
}
