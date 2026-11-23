import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/profile/widgets/add_reel_sheet.dart';
import 'package:ilm_fan/features/profile/widgets/profile_card.dart';
import 'package:ilm_fan/models/saved_reel.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class MyReelsSection extends StatelessWidget {
  const MyReelsSection({
    super.key,
    required this.reels,
    required this.canAdd,
    required this.onAdd,
  });

  final List<SavedReel> reels;
  final bool canAdd;
  final ValueChanged<SavedReel> onAdd;

  Future<void> _openAdd(BuildContext context) async {
    final reel = await showAddReelSheet(context);
    if (reel != null) onAdd(reel);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Mening reelslarim',
      trailing: canAdd
          ? TextButton(onPressed: () => _openAdd(context), child: const Text('Qo‘shish'))
          : null,
      child: reels.isEmpty
          ? const Text('Hozircha reels yo‘q.', style: TextStyle(color: IlmColors.inkMuted))
          : Column(
              children: [
                for (final reel in reels)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.movie_filter_outlined, color: IlmColors.accent),
                    title: Text(reel.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('${reel.durationSec} soniya · mahalliy demo'),
                  ),
              ],
            ),
    );
  }
}