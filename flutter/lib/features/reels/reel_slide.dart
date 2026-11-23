import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/demo_reels.dart';
import 'package:ilm_fan/features/reels/reel_comment_sheet.dart';
import 'package:ilm_fan/features/reels/reel_share_sheet.dart';

class ReelSlide extends StatefulWidget {
  const ReelSlide({
    super.key,
    required this.reel,
    required this.index,
    required this.total,
  });

  final DemoReel reel;
  final int index;
  final int total;

  @override
  State<ReelSlide> createState() => _ReelSlideState();
}

class _ReelSlideState extends State<ReelSlide> {
  var _liked = false;
  late int _likeCount;
  late final List<String> _comments;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.reel.initialLikes;
    _comments = List<String>.from(widget.reel.initialComments);
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
  }

  void _openComments() {
    showReelCommentSheet(
      context: context,
      comments: _comments,
      onAdd: (text) {
        setState(() => _comments.add(text));
      },
    );
  }

  void _openShare() {
    showReelShareSheet(
      context: context,
      reelAuthor: widget.reel.author,
      onSent: (friend) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${friend.name}ga yuborildi'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [reel.topColor, reel.bottomColor],
            ),
          ),
        ),
        const Center(
          child: Icon(Icons.play_circle_outline, size: 72, color: Colors.white70),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 12,
          left: 16,
          right: 16,
          child: Text(
            'Reels · ${widget.index + 1}/${widget.total}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 72,
          bottom: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                reel.author,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reel.caption,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.35),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: 40,
          child: Column(
            children: [
              _SideAction(
                icon: _liked ? Icons.favorite : Icons.favorite_border,
                iconColor: _liked ? Colors.redAccent : Colors.white,
                label: '$_likeCount',
                onTap: _toggleLike,
              ),
              const SizedBox(height: 16),
              _SideAction(
                icon: Icons.chat_bubble_outline,
                label: '${_comments.length}',
                onTap: _openComments,
              ),
              const SizedBox(height: 16),
              _SideAction(icon: Icons.send_outlined, label: '', onTap: _openShare),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: Center(
            child: Text(
              widget.index < widget.total - 1 ? 'Pastga torting ↓' : 'Tepaga qayting ↑',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 28),
            if (label.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }
}