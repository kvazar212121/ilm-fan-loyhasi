import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/roles.dart';
import 'package:ilm_fan/features/profile/widgets/my_courses_section.dart';
import 'package:ilm_fan/features/profile/widgets/my_reels_section.dart';
import 'package:ilm_fan/features/profile/widgets/profile_header.dart';
import 'package:ilm_fan/features/profile/widgets/profile_tools_section.dart';
import 'package:ilm_fan/features/profile/widgets/saved_reels_section.dart';
import 'package:ilm_fan/features/profile/widgets/subscription_section.dart';
import 'package:ilm_fan/features/profile/widgets/subscriptions_list_section.dart';
import 'package:ilm_fan/models/profile_course.dart';
import 'package:ilm_fan/models/saved_reel.dart';
import 'package:ilm_fan/models/subscription_plan.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({
    super.key,
    required this.profile,
    this.onLogout,
    this.onOpenPreparation,
    this.onOpenMarketplace,
    this.onOpenNews,
  });

  final UserProfile profile;
  final VoidCallback? onLogout;
  final VoidCallback? onOpenPreparation;
  final VoidCallback? onOpenMarketplace;
  final VoidCallback? onOpenNews;

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen> {
  XFile? _avatar;
  late List<SavedReel> _myReels;
  late List<ProfileCourse> _courses;
  final List<String> _savedReels = const [
    'Matematika: kvadrat tenglamalar',
    'Fizika formulasini 60 soniyada',
  ];

  bool get _isTeacher =>
      widget.profile.role == RoleId.teacher ||
      widget.profile.role == RoleId.teacherMaterials;

  @override
  void initState() {
    super.initState();
    _myReels = _isTeacher
        ? [
            const SavedReel(
              id: 'demo-1',
              title: 'Birinchi dars reels',
              durationSec: 58,
            ),
          ]
        : [];
    _courses = _isTeacher
        ? [const ProfileCourse(title: 'Matematika tayyorlov', lessons: 12)]
        : [const ProfileCourse(title: 'Boshlang‘ich fizika', lessons: 8)];
  }

  void _addReel(SavedReel reel) {
    setState(() => _myReels = [..._myReels, reel]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reel ro‘yxatga qo‘shildi'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: IlmColors.paper,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: IlmColors.paper,
            surfaceTintColor: Colors.transparent,
            title: const Text('Profil'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ProfileHeader(
                  profile: widget.profile,
                  avatarFile: _avatar,
                  onAvatarChanged: (file) => setState(() => _avatar = file),
                ),
                if (widget.profile.role == RoleId.teacherMaterials &&
                    widget.onOpenPreparation != null) ...[
                  const SizedBox(height: 16),
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: IlmColors.line),
                    ),
                    child: ListTile(
                      key: const ValueKey('openCertificatePreparation'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: IlmColors.accent.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.workspace_premium_outlined,
                          color: IlmColors.accent,
                        ),
                      ),
                      title: const Text(
                        'Sertifikatga tayyorlanish',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: IlmColors.ink,
                        ),
                      ),
                      subtitle: const Text(
                        'Milliy sertifikat darslari va mashqlariga o‘tish',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: IlmColors.inkMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: IlmColors.inkMuted,
                      ),
                      onTap: widget.onOpenPreparation,
                    ),
                  ),
                ],
                if ((widget.profile.role == RoleId.teacherMaterials ||
                        widget.profile.role == RoleId.student) &&
                    widget.onOpenMarketplace != null) ...[
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: IlmColors.line),
                    ),
                    child: ListTile(
                      key: const ValueKey('openTextbookMarketplace'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: IlmColors.accent.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: IlmColors.accent,
                        ),
                      ),
                      title: const Text(
                        'Darslik marketplace',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: IlmColors.ink,
                        ),
                      ),
                      subtitle: Text(
                        widget.profile.role == RoleId.teacherMaterials
                            ? 'Darsliklaringizni bepul yoki pullik joylash va ko‘rish'
                            : 'Ustozlarning bepul va pullik darsliklarini olish',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: IlmColors.inkMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: IlmColors.inkMuted,
                      ),
                      onTap: widget.onOpenMarketplace,
                    ),
                  ),
                ],
                if (widget.profile.role == RoleId.universityStudent &&
                    widget.onOpenNews != null) ...[
                  const SizedBox(height: 12),
                  Material(
                    color: Colors.white,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: const BorderSide(color: IlmColors.line),
                    ),
                    child: ListTile(
                      key: const ValueKey('openUniversityNews'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: IlmColors.accent.withValues(alpha: 0.12),
                        child: const Icon(
                          Icons.campaign_outlined,
                          color: IlmColors.accent,
                        ),
                      ),
                      title: const Text(
                        'Rasmiy xabarlar',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: IlmColors.ink,
                        ),
                      ),
                      subtitle: const Text(
                        'Magistratura, grant va sertifikat e’lonlari',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: IlmColors.inkMuted,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: IlmColors.inkMuted,
                      ),
                      onTap: widget.onOpenNews,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const SubscriptionSection(plan: demoSubscription),
                const SizedBox(height: 12),
                SubscriptionsListSection(items: demoSubscriptions),
                const SizedBox(height: 12),
                MyCoursesSection(courses: _courses),
                const SizedBox(height: 12),
                MyReelsSection(
                  reels: _myReels,
                  canAdd: _isTeacher,
                  onAdd: _addReel,
                ),
                const SizedBox(height: 12),
                SavedReelsSection(savedTitles: _savedReels),
                if (_isTeacher) ...[
                  const SizedBox(height: 12),
                  const ProfileToolsSection(),
                ],
                const SizedBox(height: 20),
                if (widget.onLogout != null)
                  OutlinedButton(
                    onPressed: widget.onLogout,
                    child: const Text('Chiqish'),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
