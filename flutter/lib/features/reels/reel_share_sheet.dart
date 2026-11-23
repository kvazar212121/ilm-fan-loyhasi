import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/demo_share_friends.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

Future<void> showReelShareSheet({
  required BuildContext context,
  required String reelAuthor,
  required void Function(DemoFriend friend) onSent,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: IlmColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: IlmColors.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Do‘stga yuborish · @$reelAuthor',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...demoShareFriends.map((friend) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: IlmColors.accent.withValues(alpha: 0.15),
                child: Text(friend.name[0], style: const TextStyle(color: IlmColors.accent)),
              ),
              title: Text(friend.name),
              trailing: const Icon(Icons.send_outlined, color: IlmColors.accent),
              onTap: () {
                Navigator.pop(context);
                onSent(friend);
              },
            );
          }),
        ],
      ),
    ),
  );
}