import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/profile/widgets/profile_card.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class ProfileToolsSection extends StatelessWidget {
  const ProfileToolsSection({super.key});

  static const _tools = [
    (Icons.add_box_outlined, 'Kurs yaratish', 'Tayyorlov kursi ochish.'),
    (Icons.quiz_outlined, 'Test yaratish', 'Mashq testi tuzish.'),
    (Icons.videocam_outlined, 'Reel joylash', '2 daqiqagacha video.'),
  ];

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Asboblar',
      child: Column(
        children: [
          for (final tool in _tools)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(tool.$1, color: IlmColors.accent),
              title: Text(tool.$2, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(tool.$3, style: const TextStyle(fontSize: 12, color: IlmColors.inkMuted)),
              trailing: const Icon(Icons.chevron_right, color: IlmColors.inkMuted),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${tool.$2} — tez orada'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}