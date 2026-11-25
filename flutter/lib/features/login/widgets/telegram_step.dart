import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ilm_fan/data/auth_api.dart';
import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class TelegramStep extends StatefulWidget {
  const TelegramStep({
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
  State<TelegramStep> createState() => _TelegramStepState();
}

class _TelegramStepState extends State<TelegramStep> {
  TelegramStartResult? _session;
  bool _botOpened = false;
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    _pollTimer?.cancel();
    setState(() {
      _loading = true;
      _error = null;
      _botOpened = false;
      _session = null;
    });
    try {
      final started = await widget.authApi.startTelegram();
      if (!mounted) return;
      setState(() {
        _session = started;
        _loading = false;
      });
      _pollTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => _poll(),
      );
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _poll() async {
    final session = _session;
    if (session == null || !mounted) return;
    try {
      final outcome = await widget.authApi.pollTelegram(
        attemptId: session.attemptId,
        secret: session.secret,
      );
      if (!mounted) return;
      if (outcome.status == 'pending') {
        if (outcome.botOpened != _botOpened) {
          setState(() => _botOpened = outcome.botOpened);
        }
        return;
      }
      _pollTimer?.cancel();
      if (outcome.status == 'authenticated' && outcome.user != null) {
        widget.onAuthenticated(outcome.user!);
      } else if (outcome.status == 'registration_required' &&
          outcome.registrationToken != null) {
        widget.onRegistrationRequired(outcome.registrationToken!);
      }
    } on AuthApiException catch (e) {
      _pollTimer?.cancel();
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _openBot() async {
    final link = _session?.deepLink;
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginStepHeader(
          stepLabel: '1-QADAM',
          title: 'Telegram orqali kirish',
          subtitle:
              'Botni oching, kontaktingizni ulashing va «Tasdiqlash» tugmasini bosing.',
          onBack: widget.onBack,
          backLabel: '← Kirish usullari',
        ),
        const SizedBox(height: 22),
        if (_loading)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: IlmColors.line),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Telegram havolasi tayyorlanmoqda...',
                style: TextStyle(fontSize: 14, color: IlmColors.inkMuted),
              ),
            ),
          )
        else if (session != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: IlmColors.line),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('openTelegramBotButton'),
                    onPressed: _openBot,
                    icon: const Icon(Icons.send_outlined, size: 18),
                    label: Text(
                      session.botUsername.isNotEmpty
                          ? 'Telegram botni ochish (@${session.botUsername})'
                          : 'Telegram botni ochish',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _botOpened
                              ? 'Bot ochildi — Telegram’da «Tasdiqlash» tugmasini bosing...'
                              : 'Tasdiqlash kutilmoqda...',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: IlmColors.inkMuted,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _start,
                        child: const Text('Yangi havola'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _error!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFB91C1C),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: _start,
                  child: const Text('Qayta urinish'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
