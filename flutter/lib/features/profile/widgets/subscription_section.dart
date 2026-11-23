import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/profile/widgets/profile_card.dart';
import 'package:ilm_fan/models/subscription_plan.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class SubscriptionSection extends StatelessWidget {
  const SubscriptionSection({super.key, required this.plan});

  final SubscriptionPlan plan;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Obuna rejasi',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.planName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Daraja: ${plan.levelLabel}', style: const TextStyle(color: IlmColors.inkMuted)),
          const SizedBox(height: 12),
          Text('Umumiy o‘zlashtirish: ${plan.masteryPercent}%', style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: plan.masteryPercent / 100,
              minHeight: 8,
              backgroundColor: IlmColors.line,
              color: IlmColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Fan bo‘yicha', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...plan.fanProgress.map((fan) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(fan.fan, style: const TextStyle(fontSize: 13)),
                        Text('${fan.percent}%', style: const TextStyle(fontSize: 12, color: IlmColors.inkMuted)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fan.percent / 100,
                        minHeight: 6,
                        backgroundColor: IlmColors.paper,
                        color: IlmColors.accent.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}