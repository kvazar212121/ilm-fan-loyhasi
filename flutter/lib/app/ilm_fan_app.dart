import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/auth_api.dart';
import 'package:ilm_fan/data/native_google_auth.dart';
import 'package:ilm_fan/features/login/login_flow_screen.dart';
import 'package:ilm_fan/features/shell/main_shell.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/app_theme.dart';

class IlmFanApp extends StatefulWidget {
  const IlmFanApp({super.key, this.authApi, this.googleAuth});

  final AuthApi? authApi;
  final NativeGoogleAuth? googleAuth;

  @override
  State<IlmFanApp> createState() => _IlmFanAppState();
}

class _IlmFanAppState extends State<IlmFanApp> {
  late final AuthApi _authApi;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _authApi = widget.authApi ?? HttpAuthApi();
  }

  void _onLoggedIn(UserProfile profile) {
    setState(() => _profile = profile);
  }

  void _onLogout() {
    final current = _profile;
    if (current != null && current.accessToken != null) {
      _authApi.logout(
        accessToken: current.accessToken,
        refreshToken: current.refreshToken,
      );
    }
    setState(() => _profile = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ilm Fan',
      debugShowCheckedModeBanner: false,
      theme: buildIlmTheme(),
      home: _profile == null
          ? LoginFlowScreen(
              authApi: _authApi,
              googleAuth: widget.googleAuth,
              onLoggedIn: _onLoggedIn,
            )
          : MainShell(profile: _profile!, onLogout: _onLogout),
    );
  }
}
