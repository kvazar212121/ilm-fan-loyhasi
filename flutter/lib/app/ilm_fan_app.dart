import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/login/login_flow_screen.dart';
import 'package:ilm_fan/features/shell/main_shell.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/app_theme.dart';

class IlmFanApp extends StatefulWidget {
  const IlmFanApp({super.key});

  @override
  State<IlmFanApp> createState() => _IlmFanAppState();
}

class _IlmFanAppState extends State<IlmFanApp> {
  UserProfile? _profile;

  void _onLoggedIn(UserProfile profile) {
    setState(() => _profile = profile);
  }

  void _onLogout() {
    setState(() => _profile = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ilm Fan',
      debugShowCheckedModeBanner: false,
      theme: buildIlmTheme(),
      home: _profile == null
          ? LoginFlowScreen(onLoggedIn: _onLoggedIn)
          : MainShell(profile: _profile!, onLogout: _onLogout),
    );
  }
}