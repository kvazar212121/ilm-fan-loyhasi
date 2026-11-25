import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/auth_api.dart';
import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class PhoneOtpStep extends StatefulWidget {
  const PhoneOtpStep({
    super.key,
    required this.authApi,
    required this.onBack,
    required this.onAuthenticated,
    required this.onRegistrationRequired,
  });

  final AuthApi authApi;
  final VoidCallback onBack;
  final ValueChanged<UserProfile> onAuthenticated;
  final ValueChanged<String> onRegistrationRequired;

  @override
  State<PhoneOtpStep> createState() => _PhoneOtpStepState();
}

class _PhoneOtpStepState extends State<PhoneOtpStep> {
  final _phoneController = TextEditingController(text: '+998');
  final _codeController = TextEditingController();
  String? _sentPhone;
  int _cooldown = 0;
  Timer? _timer;
  bool _loading = false;
  String? _notice;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldown(int seconds) {
    _timer?.cancel();
    setState(() => _cooldown = seconds);
    if (seconds <= 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown -= 1);
      }
    });
  }

  Future<void> _sendCode({bool isResend = false}) async {
    final phone = _phoneController.text.trim();
    if (phone.length < 9) {
      setState(() => _error = 'Telefon raqamingizni to‘liq kiriting.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _notice = null;
    });
    try {
      final result = await widget.authApi.sendSmsOtp(phone);
      if (!mounted) return;
      setState(() {
        _sentPhone = result.phoneMasked;
        _codeController.clear();
        if (isResend) _notice = 'Yangi tasdiqlash kodi yuborildi.';
      });
      _startCooldown(result.resendAfterSeconds);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      if (e.retryAfterSeconds != null) _startCooldown(e.retryAfterSeconds!);
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'SMS orqali kelgan kodni kiriting.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _notice = null;
    });
    try {
      final outcome = await widget.authApi.verifySmsOtp(
        phone: _phoneController.text.trim(),
        code: code,
      );
      if (!mounted) return;
      if (outcome.status == 'authenticated' && outcome.user != null) {
        widget.onAuthenticated(outcome.user!);
      } else if (outcome.status == 'registration_required' &&
          outcome.registrationToken != null) {
        widget.onRegistrationRequired(outcome.registrationToken!);
      } else {
        setState(() => _error = 'Tasdiqlash javobini o‘qib bo‘lmadi.');
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final waitingCode = _sentPhone != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginStepHeader(
          stepLabel: '1-QADAM',
          title: waitingCode ? 'SMS kodni kiriting' : 'Telefon raqam bilan kirish',
          subtitle: waitingCode
              ? '$_sentPhone raqamiga yuborilgan tasdiqlash kodini kiriting.'
              : 'Tasdiqlash kodi olish uchun telefon raqamingizni kiriting.',
          onBack: waitingCode
              ? () => setState(() {
                  _sentPhone = null;
                  _codeController.clear();
                  _error = null;
                  _notice = null;
                })
              : widget.onBack,
          backLabel: waitingCode
              ? '← Raqamni o‘zgartirish'
              : '← Kirish usullari',
        ),
        const SizedBox(height: 22),
        if (!waitingCode)
          TextField(
            key: const ValueKey('phoneOtpInput'),
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _sendCode(),
            decoration: const InputDecoration(
              labelText: 'Telefon raqam',
              hintText: '+998 90 123 45 67',
            ),
          )
        else ...[
          TextField(
            key: const ValueKey('otpCodeInput'),
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 8,
            ),
            onSubmitted: (_) => _verifyCode(),
            decoration: const InputDecoration(
              labelText: 'Tasdiqlash kodi',
              hintText: '• • • • •',
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: (_cooldown > 0 || _loading)
                  ? null
                  : () => _sendCode(isResend: true),
              child: Text(
                _cooldown > 0
                    ? 'Kodni qayta yuborish (${_cooldown}s)'
                    : 'Kodni qayta yuborish',
              ),
            ),
          ),
        ],
        if (_notice != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: IlmColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _notice!,
              style: const TextStyle(fontSize: 13, color: IlmColors.accent),
            ),
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
            ),
          ),
        ],
        const SizedBox(height: 18),
        FilledButton(
          key: ValueKey(waitingCode ? 'verifyOtpButton' : 'sendOtpButton'),
          onPressed: _loading
              ? null
              : (waitingCode ? _verifyCode : () => _sendCode()),
          child: Text(
            _loading
                ? 'Kutilmoqda...'
                : (waitingCode ? 'Tasdiqlash' : 'SMS kod yuborish'),
          ),
        ),
      ],
    );
  }
}
