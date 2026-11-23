import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/models/saved_reel.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

Future<SavedReel?> showAddReelSheet(BuildContext context) {
  return showModalBottomSheet<SavedReel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: IlmColors.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => const _AddReelSheet(),
  );
}

class _AddReelSheet extends StatefulWidget {
  const _AddReelSheet();

  @override
  State<_AddReelSheet> createState() => _AddReelSheetState();
}

class _AddReelSheetState extends State<_AddReelSheet> {
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    Navigator.pop(
      context,
      SavedReel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        durationSec: 90,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Reel joylash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text(
            'Demo: sarlavha saqlanadi. Keyin video yuklash va 2 daqiqa chek qo‘shiladi.',
            style: TextStyle(fontSize: 13, color: IlmColors.inkMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(hintText: 'Reel nomi'),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _save, child: const Text('Saqlash')),
        ],
      ),
    );
  }
}