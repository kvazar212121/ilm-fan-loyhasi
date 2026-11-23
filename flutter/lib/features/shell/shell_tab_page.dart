import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/app_tabs.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class ShellTabPage extends StatelessWidget {
  const ShellTabPage({
    super.key,
    required this.tab,
    this.profile,
  });

  final AppTab tab;
  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          backgroundColor: IlmColors.paper,
          surfaceTintColor: Colors.transparent,
          title: Text(tab.label),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text(
                tab.blurb,
                style: const TextStyle(fontSize: 16, height: 1.5, color: IlmColors.inkMuted),
              ),
              const SizedBox(height: 16),
              const _SoonCard(),
            ]),
          ),
        ),
      ],
    );
  }
}

class _SoonCard extends StatelessWidget {
  const _SoonCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IlmColors.line),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Bu bo‘lim tez orada to‘ldiriladi. Hozircha menyudan bo‘limlarni ko‘rib chiqing.',
          style: TextStyle(fontSize: 14, height: 1.45, color: IlmColors.inkMuted),
        ),
      ),
    );
  }
}