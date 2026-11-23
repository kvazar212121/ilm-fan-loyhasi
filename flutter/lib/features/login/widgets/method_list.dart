import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/login_methods.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class MethodList extends StatelessWidget {
  const MethodList({super.key, required this.onSelect});

  final ValueChanged<LoginMethodId> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: IlmColors.accent,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x241C6B55),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 38,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Kirish',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: IlmColors.ink,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 32),
        ...loginMethods.map((method) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: IlmColors.line, width: 1.2),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onSelect(method.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 15,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: IlmColors.paper,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          method.icon,
                          color: _iconColor(method.id),
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        method.label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: IlmColors.ink,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: IlmColors.inkMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
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
