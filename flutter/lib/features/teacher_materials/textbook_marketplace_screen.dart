import 'package:material_ui/material_ui.dart';

import 'package:ilm_fan/data/tayyorlov_fans.dart';
import 'package:ilm_fan/models/marketplace_textbook.dart';
import 'package:ilm_fan/models/teacher_textbook.dart';
import 'package:ilm_fan/models/user_profile.dart';
import 'package:ilm_fan/theme/ilm_colors.dart';

enum _PriceFilter { all, free, paid }

class TextbookMarketplaceScreen extends StatefulWidget {
  const TextbookMarketplaceScreen({
    super.key,
    required this.profile,
    this.canPublish = false,
    this.teacherTextbooks = const [],
  });

  final UserProfile profile;
  final bool canPublish;
  final List<TeacherTextbook> teacherTextbooks;

  @override
  State<TextbookMarketplaceScreen> createState() =>
      _TextbookMarketplaceScreenState();
}

class _TextbookMarketplaceScreenState extends State<TextbookMarketplaceScreen> {
  late List<MarketplaceTextbook> _catalog;
  final Set<String> _acquiredIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  var _priceFilter = _PriceFilter.all;
  var _onlyMine = false;

  String get _subjectTitle =>
      tayyorlovFanById(widget.profile.subjectFanId)?.title ?? 'Umumiy fan';

  @override
  void initState() {
    super.initState();
    _catalog = buildSampleMarketplaceTextbooks(_subjectTitle);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MarketplaceTextbook> get _filteredCatalog {
    final query = _searchQuery.trim().toLowerCase();
    return _catalog.where((item) {
      if (_onlyMine && !item.isOwnListing) return false;
      final matchesPrice = switch (_priceFilter) {
        _PriceFilter.all => true,
        _PriceFilter.free => item.isFree,
        _PriceFilter.paid => !item.isFree,
      };
      if (!matchesPrice) return false;
      if (query.isEmpty) return true;
      return item.title.toLowerCase().contains(query) ||
          item.authorName.toLowerCase().contains(query) ||
          item.subject.toLowerCase().contains(query) ||
          item.grade.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  Future<void> _openPublishSheet() async {
    final sourceTextbooks = widget.teacherTextbooks.isNotEmpty
        ? widget.teacherTextbooks
        : buildSampleTextbooks(_subjectTitle);
    var selectedTextbook = sourceTextbooks.first;
    var isFree = true;
    final priceController = TextEditingController(text: '49000');
    final descController = TextEditingController();

    final created = await showModalBottomSheet<MarketplaceTextbook>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Darslikni marketplacega joylash',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: IlmColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Yaratgan darsligingizni tanlang va uni o‘quvchilarga bepul yoki pullik taqdim eting.',
                      style: TextStyle(
                        fontSize: 13,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Qaysi darslikni joylaysiz?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: IlmColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final tb in sourceTextbooks) ...[
                      Material(
                        color: Colors.white,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: selectedTextbook.id == tb.id
                                ? IlmColors.accent
                                : IlmColors.line,
                            width: selectedTextbook.id == tb.id ? 1.5 : 1,
                          ),
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            selectedTextbook.id == tb.id
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: IlmColors.accent,
                          ),
                          title: Text(
                            tb.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '${tb.grade} · ${tb.totalTopics} mavzu',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () =>
                              setSheetState(() => selectedTextbook = tb),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 6),
                    const Text(
                      'Tarqatish turi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: IlmColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          key: const ValueKey('publishFreeChip'),
                          label: const Text('Bepul'),
                          selected: isFree,
                          selectedColor:
                              IlmColors.accent.withValues(alpha: 0.16),
                          onSelected: (_) => setSheetState(() => isFree = true),
                        ),
                        ChoiceChip(
                          key: const ValueKey('publishPaidChip'),
                          label: const Text('Pullik'),
                          selected: !isFree,
                          selectedColor:
                              IlmColors.accent.withValues(alpha: 0.16),
                          onSelected: (_) =>
                              setSheetState(() => isFree = false),
                        ),
                      ],
                    ),
                    if (!isFree) ...[
                      const SizedBox(height: 12),
                      TextField(
                        key: const ValueKey('publishPriceField'),
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Narxi (so‘m)',
                          hintText: 'Masalan: 49000',
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Qisqa tavsif (ixtiyoriy)',
                        hintText:
                            'O‘quvchilar bu darslikdan nimalarni o‘rganadi?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      key: const ValueKey('confirmPublishMarketplaceButton'),
                      onPressed: () {
                        final parsedPrice = isFree
                            ? 0
                            : (int.tryParse(
                                    priceController.text.replaceAll(' ', ''),
                                  ) ??
                                  49000);
                        final author =
                            '${widget.profile.firstName} ${widget.profile.lastName}'
                                .trim();
                        Navigator.of(sheetContext).pop(
                          MarketplaceTextbook(
                            id: 'mp-${DateTime.now().microsecondsSinceEpoch}',
                            title: selectedTextbook.title,
                            authorName:
                                author.isEmpty ? 'O‘qituvchi' : author,
                            subject: _subjectTitle,
                            grade: selectedTextbook.grade,
                            topicsCount: selectedTextbook.totalTopics,
                            isFree: isFree,
                            priceUzs: parsedPrice,
                            downloadsCount: 0,
                            rating: 5.0,
                            isOwnListing: true,
                            description: descController.text.trim().isEmpty
                                ? 'Mualliflik darsligi: bo‘limlar, materiallar va oraliq testlar bilan.'
                                : descController.text.trim(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.publish_rounded),
                      label: const Text('Marketplacega joylash'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (created != null && mounted) {
      setState(() => _catalog = [created, ..._catalog]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '«${created.title}» marketplacega joylandi (${created.formattedPrice})',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _acquireItem(MarketplaceTextbook item) {
    setState(() => _acquiredIds.add(item.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          item.isFree
              ? '«${item.title}» bepul qo‘shildi'
              : '«${item.title}» sotib olindi (${item.formattedPrice})',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openItemDetails(MarketplaceTextbook item) {
    final acquired = _acquiredIds.contains(item.id);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: IlmColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: item.isFree
                            ? IlmColors.accent.withValues(alpha: 0.14)
                            : const Color(0xFFB45309).withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: 32,
                        color: item.isFree
                            ? IlmColors.accent
                            : const Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: IlmColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.authorName,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: IlmColors.accent,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.subject} · ${item.grade}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: IlmColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: IlmColors.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailStat(
                          value: '★ ${item.rating.toStringAsFixed(1)}',
                          label: 'Reyting',
                        ),
                        _DetailStat(
                          value: '${item.topicsCount}',
                          label: 'Mavzular',
                        ),
                        _DetailStat(
                          value: '${item.downloadsCount}',
                          label: 'O‘quvchilar',
                        ),
                      ],
                    ),
                  ),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text(
                    'Darslik haqida',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: IlmColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.45,
                      color: IlmColors.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                if (item.isOwnListing)
                  const Center(
                    child: Text(
                      'Bu sizning joylagan darsligingiz',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                  )
                else if (acquired)
                  FilledButton.icon(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Olingan'),
                  )
                else
                  FilledButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _acquireItem(item);
                    },
                    child: Text(
                      item.isFree
                          ? 'Bepul olish'
                          : 'Sotib olish · ${item.formattedPrice}',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredCatalog;

    return Scaffold(
      backgroundColor: IlmColors.paper,
      appBar: AppBar(
        backgroundColor: IlmColors.paper,
        surfaceTintColor: Colors.transparent,
        title: const Text('Darslik marketplace'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          TextField(
            key: const ValueKey('marketplaceSearchField'),
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Darslik, muallif yoki sinf qidirish...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      key: const ValueKey('clearMarketplaceSearch'),
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.canPublish) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: IlmColors.line),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'O‘z darsligingizni o‘quvchilarga taqdim eting',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: IlmColors.ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Yaratgan darsliklaringizni marketplacega bepul yoki pullik joylab, keng auditoriyaga ulashing.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: IlmColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('publishToMarketplaceButton'),
                        onPressed: _openPublishSheet,
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('Darsligimni marketplacega joylash'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Barchasi'),
                selected: _priceFilter == _PriceFilter.all && !_onlyMine,
                selectedColor: IlmColors.accent.withValues(alpha: 0.16),
                onSelected: (_) => setState(() {
                  _priceFilter = _PriceFilter.all;
                  _onlyMine = false;
                }),
              ),
              ChoiceChip(
                label: const Text('Bepul'),
                selected: _priceFilter == _PriceFilter.free,
                selectedColor: IlmColors.accent.withValues(alpha: 0.16),
                onSelected: (_) =>
                    setState(() => _priceFilter = _PriceFilter.free),
              ),
              ChoiceChip(
                label: const Text('Pullik'),
                selected: _priceFilter == _PriceFilter.paid,
                selectedColor: IlmColors.accent.withValues(alpha: 0.16),
                onSelected: (_) =>
                    setState(() => _priceFilter = _PriceFilter.paid),
              ),
              if (widget.canPublish)
                FilterChip(
                  label: const Text('Mening joylaganlarim'),
                  selected: _onlyMine,
                  selectedColor: IlmColors.accent.withValues(alpha: 0.16),
                  onSelected: (v) => setState(() => _onlyMine = v),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: IlmColors.line),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Bu filtr yoki qidiruv bo‘yicha darsliklar topilmadi.',
                  style: TextStyle(fontSize: 13.5, color: IlmColors.inkMuted),
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 680 ? 3 : 2;
                return GridView.builder(
                  key: const ValueKey('marketplaceGrid'),
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 266,
                  ),
                  itemBuilder: (_, index) {
                    final item = items[index];
                    return _MarketplaceCard(
                      item: item,
                      acquired: _acquiredIds.contains(item.id),
                      onTap: () => _openItemDetails(item),
                      onAcquire: () => _acquireItem(item),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: IlmColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: IlmColors.inkMuted),
        ),
      ],
    );
  }
}

class _MarketplaceCard extends StatefulWidget {
  const _MarketplaceCard({
    required this.item,
    required this.acquired,
    required this.onTap,
    required this.onAcquire,
  });

  final MarketplaceTextbook item;
  final bool acquired;
  final VoidCallback onTap;
  final VoidCallback onAcquire;

  @override
  State<_MarketplaceCard> createState() => _MarketplaceCardState();
}

class _MarketplaceCardState extends State<_MarketplaceCard> {
  var _pressed = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final acquired = widget.acquired;
    final badgeColor = item.isFree
        ? IlmColors.accent
        : const Color(0xFFB45309);

    return Semantics(
      label: '${item.title}, ${item.authorName}, ${item.formattedPrice}',
      button: true,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Material(
          color: IlmColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: IlmColors.line),
          ),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Container(
                height: 82,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.auto_stories_rounded,
                        size: 32,
                        color: badgeColor,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.isOwnListing ? 'Mening darsligim' : item.grade,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: IlmColors.ink,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 12,
                              color: Color(0xFFD97706),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: IlmColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: IlmColors.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: IlmColors.inkMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.topicsCount} mavzu · ${item.downloadsCount} ta',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: IlmColors.inkMuted,
                ),
              ),
              const Spacer(),
              if (item.isOwnListing)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: IlmColors.paper,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: IlmColors.line),
                  ),
                  child: Text(
                    item.formattedPrice,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                )
              else if (acquired)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: IlmColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Olingan ✓',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: IlmColors.accent,
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: widget.onAcquire,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 34),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: badgeColor,
                    ),
                    child: Text(
                      item.isFree ? 'Bepul olish' : item.formattedPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }
}
