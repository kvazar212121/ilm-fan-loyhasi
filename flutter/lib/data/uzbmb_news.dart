import 'dart:convert';

import 'package:http/http.dart' as http;

class UzbmbNewsItem {
  const UzbmbNewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.publishedAt,
    required this.category,
    required this.views,
    this.imageUrl,
  });

  final int id;
  final String title;
  final String summary;
  final DateTime publishedAt;
  final String category;
  final int views;
  final String? imageUrl;

  Uri get sourceUri => Uri.https('gov.uz', '/oz/uzbmb/news/view/$id');
}

abstract interface class NewsRepository {
  Future<List<UzbmbNewsItem>> fetchLatest();

  void dispose();
}

/// Reads the news list embedded in the official Bilimni baholash agentligi page.
///
/// The public portal currently renders its article list into Next.js flight data,
/// so the parser extracts those records without relying on a private API.
class UzbmbNewsRepository implements NewsRepository {
  UzbmbNewsRepository({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  static final Uri newsPageUri = Uri.https('gov.uz', '/oz/uzbmb/news/news');

  final http.Client _client;
  final bool _ownsClient;

  @override
  Future<List<UzbmbNewsItem>> fetchLatest() async {
    final response = await _client
        .get(newsPageUri, headers: const {'Accept-Language': 'uz'})
        .timeout(const Duration(seconds: 18));
    if (response.statusCode != 200) {
      throw const FormatException('Rasmiy yangiliklar yuklanmadi.');
    }
    final items = parsePage(response.body);
    if (items.isEmpty) {
      throw const FormatException('Rasmiy yangiliklar topilmadi.');
    }
    return items;
  }

  static List<UzbmbNewsItem> parsePage(String pageHtml) {
    final pageData = StringBuffer();
    final chunks = RegExp(r'self\.__next_f\.push\(\[1,"((?:\\.|[^"\\])*)"\]\)');
    for (final match in chunks.allMatches(pageHtml)) {
      pageData.write(_decodeJsonString(match.group(1)!));
    }

    final decodedPage = pageData.toString();
    final articlePattern = RegExp(
      r'\{"id":(\d+),"category_id":\d+,"date":"((?:\\.|[^"\\])*)","title":"((?:\\.|[^"\\])*)","anons":"((?:\\.|[^"\\])*)","views":(\d+),"anons_image":(?:"((?:\\.|[^"\\])*)"|null),"category_title":"((?:\\.|[^"\\])*)"',
    );
    final items = <UzbmbNewsItem>[];
    for (final match in articlePattern.allMatches(decodedPage)) {
      final dateValue = _decodeJsonString(match.group(2)!);
      final publishedAt = DateTime.tryParse(dateValue.replaceFirst(' ', 'T'));
      if (publishedAt == null) continue;
      final title = _normalizeUzbek(_decodeJsonString(match.group(3)!)).trim();
      if (title.isEmpty) continue;
      final rawImage = match.group(6);
      items.add(
        UzbmbNewsItem(
          id: int.parse(match.group(1)!),
          title: title,
          summary: _cleanText(
            _normalizeUzbek(_decodeJsonString(match.group(4)!)),
          ),
          publishedAt: publishedAt,
          views: int.tryParse(match.group(5)!) ?? 0,
          imageUrl: rawImage == null || rawImage.isEmpty
              ? null
              : _decodeJsonString(rawImage),
          category: _decodeJsonString(match.group(7)!),
        ),
      );
    }
    return items;
  }

  static String _decodeJsonString(String encoded) =>
      jsonDecode('"$encoded"') as String;

  static String _cleanText(String text) => text
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', '’')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static String _normalizeUzbek(String text) => text
      .replaceAll('Ö', 'O‘')
      .replaceAll('ö', 'o‘')
      .replaceAll('Ş', 'Sh')
      .replaceAll('ş', 'sh')
      .replaceAll('Ç', 'Ch')
      .replaceAll('ç', 'ch')
      .replaceAll('Ğ', 'G‘')
      .replaceAll('ğ', 'g‘')
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'I');

  @override
  void dispose() {
    if (_ownsClient) _client.close();
  }
}
