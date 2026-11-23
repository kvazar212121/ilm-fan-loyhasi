class SavedReel {
  const SavedReel({
    required this.id,
    required this.title,
    this.durationSec = 60,
  });

  final String id;
  final String title;
  final int durationSec;
}