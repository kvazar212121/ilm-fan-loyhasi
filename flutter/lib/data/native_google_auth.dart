import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:ilm_fan/data/auth_api.dart';

abstract class NativeGoogleAuth {
  /// Opens the native in-app Google Sign-In sheet and returns the Google ID token,
  /// or `null` if the user cancelled.
  Future<String?> signInForIdToken();
}

class GoogleSignInNativeAuth implements NativeGoogleAuth {
  static bool _initialized = false;

  static const _iosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue:
        '897001754273-8gc9jmfovhebgcjkd2c7mj3nt75j4m3i.apps.googleusercontent.com',
  );
  static const _serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '897001754273-2ag6taddom0jbr8oq6j37vci8qtbsq33.apps.googleusercontent.com',
  );

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: !kIsWeb && Platform.isIOS && _iosClientId.isNotEmpty
          ? _iosClientId
          : null,
      serverClientId: _serverClientId.isNotEmpty ? _serverClientId : null,
    );
    _initialized = true;
  }

  @override
  Future<String?> signInForIdToken() async {
    try {
      await _ensureInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthApiException(
          'Google ID token olinmadi. GOOGLE_SERVER_CLIENT_ID sozlanganini tekshiring.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      throw AuthApiException(
        'Google orqali kirishda xatolik: ${e.description ?? e.code.name}',
      );
    } on AuthApiException {
      rethrow;
    } catch (e) {
      throw AuthApiException(
        'Native Google kirish sozlanmagan (iOS/Android Client ID kerak): $e',
      );
    }
  }
}
