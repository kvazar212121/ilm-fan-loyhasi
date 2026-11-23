import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/profile/widgets/profile_card.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class SubscriptionsListSection extends StatelessWidget {
  const SubscriptionsListSection({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Obunalarim',
      child: items.isEmpty
          ? const Text('Hali obuna yo‘q.', style: TextStyle(color: IlmColors.inkMuted))
          : Column(
              children: [
                for (final item in items)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.notifications_active_outlined, color: IlmColors.accent),
                    title: Text(item),
                    trailing: TextButton(onPressed: () {}, child: const Text('Bekor')),
                  ),
              ],
            ),
    );
  }
}