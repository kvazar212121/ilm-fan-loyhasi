import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/auth_api.dart';
import 'package:ilm_fan/data/login_methods.dart';
import 'package:ilm_fan/data/native_google_auth.dart';
import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/features/login/widgets/fan_picker.dart';
import 'package:ilm_fan/features/login/widgets/method_list.dart';
import 'package:ilm_fan/features/login/widgets/phone_otp_step.dart';
import 'package:ilm_fan/features/login/widgets/profile_form.dart';
import 'package:ilm_fan/features/login/widgets/role_picker.dart';
import 'package:ilm_fan/features/login/widgets/telegram_step.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

enum _LoginMode { method, phone, telegram, register }

class LoginFlowScreen extends StatefulWidget {
  const LoginFlowScreen({
    super.key,
    this.onLoggedIn,
    this.authApi,
    this.googleAuth,
  });

  final ValueChanged<UserProfile>? onLoggedIn;
  final AuthApi? authApi;
  final NativeGoogleAuth? googleAuth;

  @override
  State<LoginFlowScreen> createState() => _LoginFlowScreenState();
}

class _LoginFlowScreenState extends State<LoginFlowScreen> {
  late final AuthApi _authApi;
  late final NativeGoogleAuth _googleAuth;
  _LoginMode _mode = _LoginMode.method;
  String? _registrationToken;
  RegistrationPrefill _prefill = const RegistrationPrefill();
  ProfileDraft? _draft;
  RoleId? _roleId;
  bool _busy = false;
  String? _error;

  RoleOption? get _role => roleById(_roleId);

  @override
  void initState() {
    super.initState();
    _authApi = widget.authApi ?? HttpAuthApi();
    _googleAuth = widget.googleAuth ?? GoogleSignInNativeAuth();
  }

  Future<void> _onSelectMethod(LoginMethodId id) async {
    setState(() => _error = null);
    if (id == LoginMethodId.phone) {
      setState(() => _mode = _LoginMode.phone);
      return;
    }
    if (id == LoginMethodId.telegram) {
      setState(() => _mode = _LoginMode.telegram);
      return;
    }
    // Native in-app Google Sign-In (never leaves the app to Safari/Chrome)
    setState(() => _busy = true);
    try {
      final idToken = await _googleAuth.signInForIdToken();
      if (idToken == null || !mounted) return;
      final outcome = await _authApi.loginWithGoogleIdToken(idToken);
      if (!mounted) return;
      if (outcome.status == 'authenticated' && outcome.user != null) {
        _finishLogin(outcome.user!);
      } else if (outcome.status == 'registration_required' &&
          outcome.registrationToken != null) {
        await _onRegistrationRequired(outcome.registrationToken!);
      } else {
        setState(() => _error = 'Google javobini o‘qib bo‘lmadi.');
      }
    } on AuthApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _startDemoRegistration() {
    setState(() {
      _error = null;
      _registrationToken = null;
      _prefill = const RegistrationPrefill(
        phone: '+998 90 123 45 67',
        phoneVerified: true,
      );
      _draft = null;
      _roleId = null;
      _mode = _LoginMode.register;
    });
  }

  Future<void> _onRegistrationRequired(String token) async {
    setState(() {
      _busy = true;
      _error = null;
      _registrationToken = token;
    });
    RegistrationPrefill prefill = const RegistrationPrefill();
    try {
      prefill = await _authApi.inspectRegistration(token);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _prefill = prefill;
      _draft = null;
      _roleId = null;
      _mode = _LoginMode.register;
      _busy = false;
    });
  }

  void _finishLogin(UserProfile user) {
    widget.onLoggedIn?.call(user);
  }

  Future<void> _submitRegistration(List<String> fanIds) async {
    final draft = _draft;
    final roleId = _roleId;
    if (draft == null || roleId == null) return;

    // Demo mode (without backend registration token)
    if (_registrationToken == null) {
      _finishLogin(
        UserProfile(
          firstName: draft.firstName,
          lastName: draft.lastName,
          role: roleId,
          subjectFanId: fanIds.isNotEmpty ? fanIds.first : null,
          subjectFanIds: fanIds,
          phone: draft.phone,
          birthDate: draft.birthDate,
          region: draft.region,
          gender: draft.gender,
          avatarUrl: draft.avatarUrl,
        ),
      );
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = await _authApi.completeRegistration(
        registrationToken: _registrationToken!,
        role: roleId,
        fanIds: fanIds,
        firstName: draft.firstName,
        lastName: draft.lastName,
        phone: draft.phone,
        birthDate: draft.birthDate,
        region: draft.region,
        gender: draft.gender,
        avatarUrl: draft.avatarUrl ?? '',
      );
      if (!mounted) return;
      _finishLogin(user);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  int get _activeStep {
    if (_mode != _LoginMode.register) return 1;
    if (_draft == null) return 2;
    if (_role == null) return 3;
    return 4;
  }

  String get _stepKey {
    if (_mode != _LoginMode.register) return 'mode-${_mode.name}';
    if (_draft == null) return 'reg-profile';
    if (_role == null) return 'reg-role';
    return 'reg-fan-${_role!.id.name}';
  }

  @override
  Widget build(BuildContext context) {
    final showProgress = _mode == _LoginMode.register;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AbsorbPointer(
                absorbing: _busy,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _busy ? 0.65 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showProgress) ...[
                        _LoginProgressBar(activeStep: _activeStep),
                        const SizedBox(height: 20),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0, 0.04),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(_stepKey),
                          child: _buildStep(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    if (_mode == _LoginMode.method) {
      return MethodList(
        onSelect: _onSelectMethod,
        onDemoLogin: _startDemoRegistration,
        error: _error,
      );
    }

    if (_mode == _LoginMode.phone) {
      return PhoneOtpStep(
        authApi: _authApi,
        onBack: () => setState(() => _mode = _LoginMode.method),
        onAuthenticated: _finishLogin,
        onRegistrationRequired: _onRegistrationRequired,
      );
    }

    if (_mode == _LoginMode.telegram) {
      return TelegramStep(
        authApi: _authApi,
        onBack: () => setState(() => _mode = _LoginMode.method),
        onAuthenticated: _finishLogin,
        onRegistrationRequired: _onRegistrationRequired,
      );
    }

    // Registration steps aligned with frontend/components/login/LoginFlow.tsx:
    // Step 2: ProfileForm -> Step 3: RolePicker -> Step 4: FanPicker
    if (_draft == null) {
      return ProfileForm(
        initialFirstName: _prefill.firstName,
        initialLastName: _prefill.lastName,
        initialPhone: _prefill.phone,
        phoneVerified: _prefill.phoneVerified,
        initialAvatarUrl: _prefill.avatarUrl,
        registrationToken: _registrationToken,
        authApi: _authApi,
        error: _error,
        onBack: () => setState(() {
          _mode = _LoginMode.method;
          _error = null;
        }),
        onAuthenticated: _finishLogin,
        onSave: (draft) => setState(() {
          _error = null;
          _draft = draft;
        }),
      );
    }

    if (_role == null) {
      return RolePicker(
        onBack: () => setState(() => _draft = null),
        onSelect: (id) => setState(() => _roleId = id),
      );
    }

    return FanPicker(
      role: _role!,
      onBack: () => setState(() => _roleId = null),
      onSelect: _submitRegistration,
    );
  }
}

class _LoginProgressBar extends StatelessWidget {
  const _LoginProgressBar({required this.activeStep});

  final int activeStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var step = 1; step <= 4; step++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 4,
              decoration: BoxDecoration(
                color: step <= activeStep ? IlmColors.accent : IlmColors.line,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          if (step < 4) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
