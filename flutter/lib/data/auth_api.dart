import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/models/user_profile.dart';

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.retryAfterSeconds});

  final String message;
  final int? retryAfterSeconds;

  @override
  String toString() => message;
}

class SendSmsResult {
  const SendSmsResult({
    required this.phoneMasked,
    required this.resendAfterSeconds,
  });

  final String phoneMasked;
  final int resendAfterSeconds;
}

class AuthOutcome {
  const AuthOutcome({
    required this.status,
    this.user,
    this.registrationToken,
    this.botOpened = false,
  });

  final String status; // authenticated | registration_required | pending
  final UserProfile? user;
  final String? registrationToken;
  final bool botOpened;
}

class TelegramStartResult {
  const TelegramStartResult({
    required this.attemptId,
    required this.secret,
    required this.botUsername,
    required this.deepLink,
  });

  final String attemptId;
  final String secret;
  final String botUsername;
  final String deepLink;
}

class RegistrationPrefill {
  const RegistrationPrefill({
    this.method,
    this.phone = '',
    this.phoneVerified = false,
    this.firstName = '',
    this.lastName = '',
    this.avatarUrl,
  });

  final String? method;
  final String phone;
  final bool phoneVerified;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
}

abstract class AuthApi {
  Future<SendSmsResult> sendSmsOtp(String phone);
  Future<AuthOutcome> verifySmsOtp({
    required String phone,
    required String code,
  });
  Future<TelegramStartResult> startTelegram();
  Future<AuthOutcome> pollTelegram({
    required String attemptId,
    required String secret,
  });
  Future<String> startGoogle();
  Future<AuthOutcome> loginWithGoogleIdToken(String idToken);
  Future<RegistrationPrefill> inspectRegistration(String registrationToken);
  Future<AuthOutcome> verifyRegistrationPhone({
    required String registrationToken,
    required String phone,
    required String code,
  });
  Future<UserProfile> completeRegistration({
    required String registrationToken,
    required RoleId role,
    required List<String> fanIds,
    required String firstName,
    required String lastName,
    required String phone,
    required String birthDate,
    required String region,
    required String gender,
    String avatarUrl = '',
  });
  Future<void> logout({String? accessToken, String? refreshToken});
}

String defaultBackendBaseUrl() {
  const envUrl = String.fromEnvironment('API_BASE_URL');
  if (envUrl.isNotEmpty) return envUrl;
  return 'https://sat-ilmfan.gvazar.uz';
}

/// Connects to the live Ilm Fan auth API (`https://sat-ilmfan.gvazar.uz/api/auth/*`)
/// maintaining session & flow cookies (`ilm_access`, `ilm_refresh`, `ilm_reg_token`, `ilm_tg_attempt`).
class HttpAuthApi implements AuthApi {
  HttpAuthApi({String? baseUrl, http.Client? client})
    : baseUrl = (baseUrl ?? defaultBackendBaseUrl()).replaceAll(RegExp(r'/$'), ''),
      _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  final Map<String, String> _cookies = {};

  void _storeCookies(http.Response res) {
    final rawHeader = res.headers['set-cookie'];
    if (rawHeader == null || rawHeader.isEmpty) return;
    // Split multiple Set-Cookie headers without breaking `Expires=Tue, 24 Nov...`.
    final parts = rawHeader.split(RegExp(r',(?=\s*[A-Za-z0-9_\-]+=)'));
    for (final part in parts) {
      final firstSegment = part.split(';').first.trim();
      final eq = firstSegment.indexOf('=');
      if (eq <= 0) continue;
      final name = firstSegment.substring(0, eq).trim();
      final value = firstSegment.substring(eq + 1).trim();
      if (value.isEmpty || part.toLowerCase().contains('max-age=0')) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
      }
    }
  }

  Map<String, String> _headers({bool jsonBody = true}) {
    final cookieHeader = _cookies.entries
        .map((e) => '${e.key}=${e.value}')
        .join('; ');
    return <String, String>{
      'Accept': 'application/json',
      if (jsonBody) 'Content-Type': 'application/json',
      if (cookieHeader.isNotEmpty) 'Cookie': cookieHeader,
    };
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth$path');
    http.Response res;
    try {
      if (method == 'GET') {
        res = await _client
            .get(uri, headers: _headers(jsonBody: false))
            .timeout(const Duration(seconds: 15));
      } else {
        res = await _client
            .post(
              uri,
              headers: _headers(),
              body: jsonEncode(body ?? const <String, dynamic>{}),
            )
            .timeout(const Duration(seconds: 15));
      }
    } catch (_) {
      throw const AuthApiException(
        'Server bilan bog‘lanib bo‘lmadi. Internet aloqasini tekshiring.',
      );
    }

    _storeCookies(res);

    Map<String, dynamic> decoded = const {};
    try {
      final raw = jsonDecode(res.body);
      if (raw is Map<String, dynamic>) decoded = raw;
    } catch (_) {}

    if (res.statusCode >= 400) {
      final msg = (decoded['message'] ?? 'So‘rovda xatolik (${res.statusCode})')
          .toString();
      final retry = decoded['retry_after_seconds'] is num
          ? (decoded['retry_after_seconds'] as num).toInt()
          : null;
      throw AuthApiException(msg, retryAfterSeconds: retry);
    }

    return decoded;
  }

  AuthOutcome _parseLoginOutcome(Map<String, dynamic> data) {
    final status = (data['status'] ?? '').toString();
    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : null;
    final regToken = status == 'registration_required'
        ? (_cookies['ilm_reg_token'] ?? 'cookie')
        : null;

    return AuthOutcome(
      status: status,
      user: userJson != null ? UserProfile.fromBackendJson(userJson) : null,
      registrationToken: regToken,
      botOpened: data['bot_opened'] == true,
    );
  }

  @override
  Future<SendSmsResult> sendSmsOtp(String phone) async {
    final data = await _request('POST', '/otp/sms', body: {'phone': phone.trim()});
    return SendSmsResult(
      phoneMasked: (data['phone_masked'] ?? phone.trim()).toString(),
      resendAfterSeconds: data['resend_after_seconds'] is num
          ? (data['resend_after_seconds'] as num).toInt()
          : 60,
    );
  }

  @override
  Future<AuthOutcome> verifySmsOtp({
    required String phone,
    required String code,
  }) async {
    final data = await _request(
      'POST',
      '/otp/verify',
      body: {'phone': phone.trim(), 'code': code.trim()},
    );
    return _parseLoginOutcome(data);
  }

  @override
  Future<TelegramStartResult> startTelegram() async {
    final data = await _request('POST', '/telegram/start');
    return TelegramStartResult(
      attemptId: 'cookie',
      secret: 'cookie',
      botUsername: (data['bot_username'] ?? '').toString(),
      deepLink: (data['deep_link'] ?? '').toString(),
    );
  }

  @override
  Future<AuthOutcome> pollTelegram({
    required String attemptId,
    required String secret,
  }) async {
    final data = await _request('POST', '/telegram/poll');
    return _parseLoginOutcome(data);
  }

  @override
  Future<String> startGoogle() async {
    final data = await _request('POST', '/google/start');
    final url = (data['authorization_url'] ?? '').toString();
    if (url.isEmpty) {
      throw const AuthApiException('Google kirish havolasini olib bo‘lmadi');
    }
    return url;
  }

  @override
  Future<AuthOutcome> loginWithGoogleIdToken(String idToken) async {
    final data = await _request(
      'POST',
      '/google/id-token',
      body: {'id_token': idToken.trim()},
    );
    return _parseLoginOutcome(data);
  }

  @override
  Future<RegistrationPrefill> inspectRegistration(
    String registrationToken,
  ) async {
    final data = await _request('GET', '/registration/inspect');
    return RegistrationPrefill(
      method: data['method']?.toString(),
      phone: (data['phone'] ?? '').toString(),
      phoneVerified: data['phone_verified'] == true,
      firstName: (data['first_name'] ?? '').toString(),
      lastName: (data['last_name'] ?? '').toString(),
      avatarUrl: data['avatar_url']?.toString(),
    );
  }

  @override
  Future<AuthOutcome> verifyRegistrationPhone({
    required String registrationToken,
    required String phone,
    required String code,
  }) async {
    final data = await _request(
      'POST',
      '/registration/verify-phone',
      body: {'phone': phone.trim(), 'code': code.trim()},
    );
    return _parseLoginOutcome(data);
  }

  @override
  Future<UserProfile> completeRegistration({
    required String registrationToken,
    required RoleId role,
    required List<String> fanIds,
    required String firstName,
    required String lastName,
    required String phone,
    required String birthDate,
    required String region,
    required String gender,
    String avatarUrl = '',
  }) async {
    final data = await _request(
      'POST',
      '/register',
      body: {
        'role': UserProfile.roleToBackend(role),
        'fan_ids': fanIds,
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
        'birth_date': birthDate.trim(),
        'region': region.trim(),
        'gender': gender.trim(),
        'avatar_url': avatarUrl.trim(),
      },
    );
    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : null;
    if (userJson == null) {
      throw const AuthApiException('Ro‘yxatdan o‘tish javobi noto‘g‘ri');
    }
    return UserProfile.fromBackendJson(userJson);
  }

  @override
  Future<void> logout({String? accessToken, String? refreshToken}) async {
    try {
      await _request('POST', '/logout');
    } catch (_) {
    } finally {
      _cookies.clear();
    }
  }
}
