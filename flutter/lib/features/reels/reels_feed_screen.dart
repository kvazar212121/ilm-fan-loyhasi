import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/demo_reels.dart';
import 'package:ilm_fan/features/reels/reel_slide.dart';

class ReelsFeedScreen extends StatefulWidget {
  const ReelsFeedScreen({super.key});

  @override
  State<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends State<ReelsFeedScreen> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: PageView.builder(
        controller: _controller,
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        itemCount: demoReels.length,
        itemBuilder: (context, index) {
          return ReelSlide(
            key: PageStorageKey('reel-$index'),
            reel: demoReels[index],
            index: index,
            total: demoReels.length,
          );
        },
      ),
    );
  }
}