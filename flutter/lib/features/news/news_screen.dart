import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:ilm_fan/data/uzbmb_news.dart';
import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, required this.profile, this.repository});

  final UserProfile profile;
  final NewsRepository? repository;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final NewsRepository _repository;
  late final bool _ownsRepository;
  List<UzbmbNewsItem> _items = const [];
  bool _loading = true;
  String? _error;

  String get _subjectName =>
      tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Barcha fanlar';

  List<UzbmbNewsItem> get _visibleItems =>
      _items.where(_isRelevantToSelectedSubject).toList(growable: false);

  bool _isRelevantToSelectedSubject(UzbmbNewsItem item) {
    final text = _normalizeForSearch('${item.title} ${item.summary}');
    final isCertificateNews =
        text.contains('sertifikat') || text.contains('milliy test');
    if (!isCertificateNews) return false;

    final selectedKeywords = _subjectKeywords[widget.profile.subjectFanId];
    if (selectedKeywords == null || selectedKeywords.isEmpty) return true;
    if (selectedKeywords.any(text.contains)) return true;

    final mentionsAnotherSubject = _subjectKeywords.entries
        .where((entry) => entry.key != widget.profile.subjectFanId)
        .any((entry) => entry.value.any(text.contains));
    return !mentionsAnotherSubject;
  }

  static const Map<String, List<String>> _subjectKeywords = {
    'matematika': ['matematika', 'matematikadan'],
    'fizika': ['fizika', 'fizikadan'],
    'kimyo': ['kimyo', 'kimyodan'],
    'biologiya': ['biologiya', 'biologiyadan'],
    'ona-tili': ['ona tili', 'o‘zbek tili', 'adabiyot'],
    'ingliz-tili': ['ingliz tili', 'ingliz', 'chet tili'],
    'tarix': ['tarix', 'tarixdan'],
    'geografiya': ['geografiya', 'geografiyadan'],
  };

  String _normalizeForSearch(String text) =>
      text.toLowerCase().replaceAll('\u02bb', '‘').replaceAll('\u02bc', '‘');

  @override
  void initState() {
    super.initState();
    _ownsRepository = widget.repository == null;
    _repository = widget.repository ?? UzbmbNewsRepository();
    _loadNews();
  }

  @override
  void dispose() {
    if (_ownsRepository) _repository.dispose();
    super.dispose();
  }

  Future<void> _loadNews() async {
    if (!_loading || _error != null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await _repository.fetchLatest();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Rasmiy yangiliklarni hozircha yuklab bo‘lmadi.';
      });
    }
  }

  Future<void> _openUrl(Uri uri) async {
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      if (!opened && mounted) _showMessage('Havolani ochib bo‘lmadi.');
    } catch (_) {
      if (mounted) _showMessage('Havolani ochib bo‘lmadi.');
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _visibleItems;
    return RefreshIndicator(
      color: IlmColors.accent,
      onRefresh: _loadNews,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: IlmColors.paper,
            surfaceTintColor: Colors.transparent,
            title: const Text('Yangiliklar'),
            actions: [
              IconButton(
                key: const ValueKey('refreshNews'),
                onPressed: _loading ? null : _loadNews,
                tooltip: 'Yangilash',
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 112),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _officialSourceCard,
                const SizedBox(height: 18),
                if (_loading)
                  const _LoadingNewsCard()
                else if (_error != null)
                  _errorCard
                else if (visibleItems.isEmpty)
                  _emptyCard
                else ...[
                  _sectionHeader,
                  const SizedBox(height: 11),
                  for (final item in visibleItems) ...[
                    _newsCard(item),
                    const SizedBox(height: 11),
                  ],
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget get _officialSourceCard => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [IlmColors.accent, Color(0xFF084C3D)],
      ),
      borderRadius: BorderRadius.circular(23),
    ),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.verified_outlined,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rasmiy e’lonlar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$_subjectName bo‘yicha milliy sertifikat e’lonlari',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget get _sectionHeader => Row(
    children: [
      Expanded(
        child: Text(
          '$_subjectName bo‘yicha e’lonlar',
          style: const TextStyle(
            color: IlmColors.ink,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (_items.isNotEmpty)
        Text(
          '${_visibleItems.length} ta',
          style: const TextStyle(color: IlmColors.inkMuted, fontSize: 12),
        ),
    ],
  );

  Widget _newsCard(UzbmbNewsItem item) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      key: ValueKey('official-news-${item.id}'),
      borderRadius: BorderRadius.circular(20),
      onTap: () => _openUrl(item.sourceUri),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: IlmColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 8,
                  child: Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _imagePlaceholder,
                  ),
                ),
              ),
              const SizedBox(height: 13),
            ],
            Row(
              children: [
                _sourceBadge(item.category),
                const Spacer(),
                Text(
                  _formatDate(item.publishedAt),
                  style: const TextStyle(
                    color: IlmColors.inkMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                color: IlmColors.ink,
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (item.summary.isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(
                item.summary,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: IlmColors.inkMuted,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
            const SizedBox(height: 11),
            const Row(
              children: [
                Text(
                  'Rasmiy manbada o‘qish',
                  style: TextStyle(
                    color: IlmColors.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 15,
                  color: IlmColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget get _imagePlaceholder => Container(
    color: IlmColors.paper,
    alignment: Alignment.center,
    child: const Icon(
      Icons.campaign_outlined,
      color: IlmColors.accent,
      size: 30,
    ),
  );

  Widget _sourceBadge(String category) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: IlmColors.accent.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      category.isEmpty ? 'UZBMB' : category,
      style: const TextStyle(
        color: IlmColors.accent,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget get _errorCard => _messageCard(
    icon: Icons.wifi_off_rounded,
    title: _error!,
    message: 'Internet aloqasini tekshirib, qayta urinib ko‘ring.',
    actionLabel: 'Qayta urinish',
    onAction: _loadNews,
  );

  Widget get _emptyCard => _messageCard(
    icon: Icons.newspaper_rounded,
    title: '$_subjectName bo‘yicha sertifikat yangiligi yo‘q',
    message: 'Faqat tanlangan fan va umumiy sertifikat e’lonlari ko‘rsatiladi.',
    actionLabel: 'Rasmiy manbani ochish',
    onAction: () => _openUrl(UzbmbNewsRepository.newsPageUri),
  );

  Widget _messageCard({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: IlmColors.line),
    ),
    child: Column(
      children: [
        Icon(icon, color: IlmColors.accent, size: 30),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: IlmColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: IlmColors.inkMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    ),
  );

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

class _LoadingNewsCard extends StatelessWidget {
  const _LoadingNewsCard();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: IlmColors.accent),
          SizedBox(height: 12),
          Text(
            'Rasmiy yangiliklar yuklanmoqda…',
            style: TextStyle(color: IlmColors.inkMuted, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}
