import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/auth_api.dart';
import 'package:ilm_fan/data/profile_options.dart';
import 'package:ilm_fan/features/login/widgets/login_step_header.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class ProfileDraft {
  const ProfileDraft({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.birthDate,
    required this.region,
    required this.gender,
    this.avatarUrl,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String birthDate;
  final String region;
  final String gender;
  final String? avatarUrl;
}

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    super.key,
    required this.onBack,
    required this.onSave,
    this.initialFirstName = '',
    this.initialLastName = '',
    this.initialPhone = '',
    this.phoneVerified = false,
    this.initialAvatarUrl,
    this.registrationToken,
    this.authApi,
    this.onAuthenticated,
    this.error,
  });

  final VoidCallback onBack;
  final ValueChanged<ProfileDraft> onSave;
  final String initialFirstName;
  final String initialLastName;
  final String initialPhone;
  final bool phoneVerified;
  final String? initialAvatarUrl;
  final String? registrationToken;
  final AuthApi? authApi;
  final ValueChanged<UserProfile>? onAuthenticated;
  final String? error;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  final _phoneOtpController = TextEditingController();

  late bool _phoneVerified;
  bool _awaitingPhoneOtp = false;
  bool _phoneBusy = false;
  String? _birthDate;
  String? _region;
  String? _gender;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.initialFirstName);
    _lastName = TextEditingController(text: widget.initialLastName);
    _phone = TextEditingController(
      text: widget.initialPhone.isNotEmpty ? widget.initialPhone : '+998',
    );
    _phoneVerified = widget.phoneVerified;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _phoneOtpController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked == null || !mounted) return;
    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');
    setState(() => _birthDate = '$y-$m-$d');
  }

  Future<void> _sendPhoneOtp() async {
    final api = widget.authApi;
    if (api == null) return;
    setState(() {
      _phoneBusy = true;
      _validationError = null;
    });
    try {
      await api.sendSmsOtp(_phone.text.trim());
      if (!mounted) return;
      setState(() => _awaitingPhoneOtp = true);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _validationError = e.message);
    } finally {
      if (mounted) setState(() => _phoneBusy = false);
    }
  }

  Future<void> _verifyPhoneOtp() async {
    final api = widget.authApi;
    final token = widget.registrationToken;
    if (api == null || token == null) return;
    setState(() {
      _phoneBusy = true;
      _validationError = null;
    });
    try {
      final outcome = await api.verifyRegistrationPhone(
        registrationToken: token,
        phone: _phone.text.trim(),
        code: _phoneOtpController.text.trim(),
      );
      if (!mounted) return;
      if (outcome.status == 'authenticated' && outcome.user != null) {
        widget.onAuthenticated?.call(outcome.user!);
        return;
      }
      setState(() {
        _phoneVerified = true;
        _awaitingPhoneOtp = false;
      });
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _validationError = e.message);
    } finally {
      if (mounted) setState(() => _phoneBusy = false);
    }
  }

  void _submit() {
    final given = _firstName.text.trim();
    final family = _lastName.text.trim();
    if (given.isEmpty || family.isEmpty) {
      setState(() => _validationError = 'Ism va familiyani kiriting.');
      return;
    }
    if (widget.registrationToken != null && !_phoneVerified) {
      setState(
        () => _validationError =
            'Avval telefon raqamingizni SMS kod orqali tasdiqlang.',
      );
      return;
    }
    if (_birthDate == null || _birthDate!.isEmpty) {
      setState(() => _validationError = 'Tug‘ilgan sanani tanlang.');
      return;
    }
    if (_region == null || _region!.isEmpty) {
      setState(() => _validationError = 'Viloyatni tanlang.');
      return;
    }
    if (_gender == null || _gender!.isEmpty) {
      setState(() => _validationError = 'Jinsingizni tanlang.');
      return;
    }
    setState(() => _validationError = null);
    widget.onSave(
      ProfileDraft(
        firstName: given,
        lastName: family,
        phone: _phone.text.trim(),
        birthDate: _birthDate!,
        region: _region!,
        gender: _gender!,
        avatarUrl: widget.initialAvatarUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final needsInlineSmsVerify =
        widget.registrationToken != null && !_phoneVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LoginStepHeader(
          stepLabel: '2-QADAM',
          title: 'Shaxsiy ma’lumotlar',
          subtitle: 'Ro‘yxatdan o‘tish uchun asosiy ma’lumotlaringizni kiriting.',
          onBack: widget.onBack,
          backLabel: '← Kirish usuli',
        ),
        const SizedBox(height: 20),
        TextField(
          key: const ValueKey('profileFirstNameField'),
          controller: _firstName,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Ism', hintText: 'Ismingiz'),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('profileLastNameField'),
          controller: _lastName,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'Familiya',
            hintText: 'Familiyangiz',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const ValueKey('profilePhoneField'),
          controller: _phone,
          readOnly: _phoneVerified,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Telefon raqam',
            hintText: '+998 90 123 45 67',
            suffixIcon: _phoneVerified
                ? const Icon(Icons.verified_rounded, color: IlmColors.accent)
                : null,
          ),
        ),
        if (needsInlineSmsVerify) ...[
          const SizedBox(height: 8),
          if (!_awaitingPhoneOtp)
            OutlinedButton(
              onPressed: _phoneBusy ? null : _sendPhoneOtp,
              child: Text(
                _phoneBusy ? 'Yuborilmoqda...' : 'Raqamni SMS bilan tasdiqlash',
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneOtpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SMS kod',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _phoneBusy ? null : _verifyPhoneOtp,
                  child: const Text('Tasdiqlash'),
                ),
              ],
            ),
        ],
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: IlmColors.line),
          ),
          child: InkWell(
            key: const ValueKey('profileBirthDatePicker'),
            onTap: _pickBirthDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: IlmColors.accent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _birthDate ?? 'Tug‘ilgan sana (YYYY-MM-DD)',
                      style: TextStyle(
                        fontSize: 15,
                        color: _birthDate != null
                            ? IlmColors.ink
                            : IlmColors.inkMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: const ValueKey('profileRegionDropdown'),
          initialValue: _region,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Viloyat'),
          items: [
            for (final item in uzRegions)
              DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) => setState(() => _region = value),
        ),
        const SizedBox(height: 14),
        const Text(
          'Jinsi',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
            color: IlmColors.inkMuted,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final opt in genderOptions) ...[
              Expanded(
                child: Material(
                  color: _gender == opt.id
                      ? IlmColors.accent
                      : IlmColors.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: _gender == opt.id
                          ? IlmColors.accent
                          : IlmColors.line,
                      width: _gender == opt.id ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    key: ValueKey('gender-${opt.id}'),
                    onTap: () => setState(() => _gender = opt.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      child: Text(
                        opt.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: _gender == opt.id
                              ? IlmColors.paper
                              : IlmColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (opt != genderOptions.last) const SizedBox(width: 10),
            ],
          ],
        ),
        if (_validationError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _validationError!,
              style: const TextStyle(fontSize: 13, color: IlmColors.ink),
            ),
          ),
        ],
        if (widget.error != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.error!,
              style: const TextStyle(fontSize: 13, color: Color(0xFFB91C1C)),
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          key: const ValueKey('profileContinueButton'),
          onPressed: _submit,
          child: const Text('Davom etish'),
        ),
      ],
    );
  }
}
