import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/features/profile/widgets/profile_card.dart';
import 'package:ilm_fan/models/profile_course.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class MyCoursesSection extends StatelessWidget {
  const MyCoursesSection({super.key, required this.courses});

  final List<ProfileCourse> courses;

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      title: 'Mening kurslarim',
      child: courses.isEmpty
          ? const Text('Hozircha kursingiz yo‘q.', style: TextStyle(color: IlmColors.inkMuted))
          : Column(
              children: [
                for (final course in courses)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.play_lesson_outlined, color: IlmColors.accent),
                    title: Text(course.title),
                    subtitle: Text('${course.lessons} dars'),
                  ),
              ],
            ),
    );
  }
}