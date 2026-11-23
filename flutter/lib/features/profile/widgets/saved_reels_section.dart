import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/profile/widgets/profile_card.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

/// Boshqalar reelslarini saqlash (bookmark demo).
class SavedReelsSection extends StatelessWidget {
  const SavedReelsSection({super.key, required this.savedTitles});

  final List<String> savedTitles;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Saqlangan reelslar',
      child: savedTitles.isEmpty
          ? const Text('Saqlangan reel yo‘q.', style: TextStyle(color: IlmColors.inkMuted))
          : Column(
              children: [
                for (final title in savedTitles)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bookmark_outline, color: IlmColors.accent),
                    title: Text(title),
                  ),
              ],
            ),
    );
  }
}