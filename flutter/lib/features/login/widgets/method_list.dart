import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/login_methods.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class MethodList extends StatelessWidget {
  const MethodList({
    super.key,
    required this.onSelect,
    this.onDemoLogin,
    this.error,
  });

  final ValueChanged<LoginMethodId> onSelect;
  final VoidCallback? onDemoLogin;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Editorial brand header aligned with frontend/components/login/LoginShell.tsx
        DecoratedBox(
          decoration: BoxDecoration(
            color: IlmColors.accent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: IlmColors.paper.withValues(alpha: 0.28),
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_stories_outlined,
                        color: IlmColors.paper,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ILM FAN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: IlmColors.paper,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ilm yo‘lida tartibli tayyorlov.',
                  style: TextStyle(
                    fontSize: 24,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    color: IlmColors.paper,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Darsliklar, oraliq testlar va video saboqlar bitta hisobda.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: IlmColors.paper.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        DecoratedBox(
          decoration: BoxDecoration(
            color: IlmColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: IlmColors.line),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Hisobga kirish',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: IlmColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'O‘zingizga qulay usulni tanlang.',
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.45,
                    color: IlmColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 16),
                if (error != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      error!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFB91C1C),
                      ),
                    ),
                  ),
                ],
                ...loginMethods.map((method) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _EditorialMethodButton(
                      method: method,
                      iconColor: _iconColor(method.id),
                      onTap: () => onSelect(method.id),
                    ),
                  );
                }),
                if (onDemoLogin != null) ...[
                  const Divider(height: 20, color: IlmColors.line),
                  TextButton.icon(
                    key: const ValueKey('demoLoginButton'),
                    onPressed: onDemoLogin,
                    icon: const Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: IlmColors.accent,
                    ),
                    label: const Text(
                      'Serversiz demo rejimda sinab ko‘rish',
                      style: TextStyle(
                        color: IlmColors.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _iconColor(LoginMethodId method) {
    return switch (method) {
      LoginMethodId.google => const Color(0xFF4285F4),
      LoginMethodId.telegram => const Color(0xFF229ED9),
      LoginMethodId.phone => IlmColors.accent,
    };
  }
}

class _EditorialMethodButton extends StatefulWidget {
  const _EditorialMethodButton({
    required this.method,
    required this.iconColor,
    required this.onTap,
  });

  final LoginMethod method;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  State<_EditorialMethodButton> createState() => _EditorialMethodButtonState();
}

class _EditorialMethodButtonState extends State<_EditorialMethodButton> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: Material(
        color: IlmColors.paper.withValues(alpha: 0.72),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: IlmColors.line),
        ),
        child: InkWell(
          key: ValueKey('login-method-${widget.method.id.name}'),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: IlmColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: IlmColors.line),
                  ),
                  child: Icon(
                    widget.method.icon,
                    color: widget.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.method.label,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: IlmColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.method.note,
                        style: const TextStyle(
                          fontSize: 12,
                          color: IlmColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: IlmColors.inkMuted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
