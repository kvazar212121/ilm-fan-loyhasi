import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.profile,
    this.avatarFile,
    required this.onAvatarChanged,
  });

  final UserProfile profile;
  final XFile? avatarFile;
  final ValueChanged<XFile?> onAvatarChanged;

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 512, imageQuality: 85);
    if (file != null) onAvatarChanged(file);
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galereyadan'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleName = profile.role == null ? null : roleById(profile.role)?.title;
    final fanTitles = profile.allSubjectFanIds
        .map((id) => tayyorlovFanById(id)?.title)
        .whereType<String>()
        .toList(growable: false);
    final initial = profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : '?';

    Widget avatarChild;
    if (avatarFile != null) {
      avatarChild = ClipOval(child: Image.file(File(avatarFile!.path), fit: BoxFit.cover));
    } else {
      avatarChild = Text(initial, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showPicker(context),
          child: Stack(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: IlmColors.paper,
                child: avatarChild,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: IlmColors.accent,
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (roleName != null)
                Text(
                  roleName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    color: IlmColors.accent,
                  ),
                ),
              Text(
                '${profile.firstName} ${profile.lastName}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (fanTitles.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  fanTitles.length == 1
                      ? 'Fan: ${fanTitles.first}'
                      : 'Fanlar: ${fanTitles.join(', ')}',
                  style: const TextStyle(fontSize: 13, color: IlmColors.accent),
                ),
              ],
              const SizedBox(height: 4),
              const Text('Rasmni o‘zgartirish uchun avatarga bosing', style: TextStyle(fontSize: 12, color: IlmColors.inkMuted)),
            ],
          ),
        ),
      ],
    );
  }
}