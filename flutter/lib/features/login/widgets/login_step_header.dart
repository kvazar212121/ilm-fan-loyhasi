import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/theme/ilm_colors.dart';

class LoginStepHeader extends StatelessWidget {
  const LoginStepHeader({
    super.key,
    this.stepLabel,
    required this.title,
    required this.subtitle,
    this.onBack,
    this.backLabel,
  });

  final String? stepLabel;
  final String title;
  final String subtitle;
  final VoidCallback? onBack;
  final String? backLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null)
          TextButton(
            onPressed: onBack,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: IlmColors.inkMuted,
            ),
            child: Text(backLabel ?? '← Orqaga'),
          ),
        if (onBack != null) const SizedBox(height: 8),
        if (stepLabel != null) ...[
          Text(
            stepLabel!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: IlmColors.accent,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: IlmColors.ink,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, height: 1.5, color: IlmColors.inkMuted),
        ),
      ],
    );
  }
}