import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/theme/ilm_colors.dart';

Future<void> showReelCommentSheet({
  required BuildContext context,
  required List<String> comments,
  required ValueChanged<String> onAdd,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: IlmColors.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ReelCommentSheet(comments: comments, onAdd: onAdd),
  );
}

class _ReelCommentSheet extends StatefulWidget {
  const _ReelCommentSheet({required this.comments, required this.onAdd});

  final List<String> comments;
  final ValueChanged<String> onAdd;

  @override
  State<_ReelCommentSheet> createState() => _ReelCommentSheetState();
}

class _ReelCommentSheetState extends State<_ReelCommentSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _text.text.trim();
    if (value.isEmpty) return;
    widget.onAdd(value);
    _text.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: IlmColors.line,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Izohlar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.comments.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: IlmColors.accent.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: IlmColors.accent, size: 20),
                  ),
                  title: Text(widget.comments[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _text,
                  decoration: const InputDecoration(hintText: 'Izoh yozing...'),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              IconButton(
                onPressed: _submit,
                icon: const Icon(Icons.send, color: IlmColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}