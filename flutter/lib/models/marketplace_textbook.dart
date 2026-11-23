class MarketplaceTextbook {
  const MarketplaceTextbook({
    required this.id,
    required this.title,
    required this.authorName,
    required this.subject,
    required this.grade,
    required this.topicsCount,
    required this.isFree,
    required this.priceUzs,
    required this.downloadsCount,
    required this.rating,
    this.isOwnListing = false,
    this.description = '',
  });

  final String id;
  final String title;
  final String authorName;
  final String subject;
  final String grade;
  final int topicsCount;
  final bool isFree;
  final int priceUzs;
  final int downloadsCount;
  final double rating;
  final bool isOwnListing;
  final String description;

  String get formattedPrice {
    if (isFree || priceUzs <= 0) return 'Bepul';
    final raw = priceUzs.toString();
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromRight = raw.length - i;
      if (i > 0 && fromRight % 3 == 0) buf.write(' ');
      buf.write(raw[i]);
    }
    return '${buf.toString()} so‘m';
  }
}

List<MarketplaceTextbook> buildSampleMarketplaceTextbooks(String subjectTitle) {
  return [
    MarketplaceTextbook(
      id: 'mp-1',
      title: '$subjectTitle: 0 dan DTMgacha to‘liq darslik',
      authorName: 'Ustoz Akmal Karimov',
      subject: subjectTitle,
      grade: 'Abituriyentlar',
      topicsCount: 24,
      isFree: false,
      priceUzs: 49000,
      downloadsCount: 186,
      rating: 4.9,
      description: 'Video darslar, PDF konspektlar va har mavzu yakunida qulfli test.',
    ),
    MarketplaceTextbook(
      id: 'mp-2',
      title: '$subjectTitle: tezkor formulalar va sxemalar',
      authorName: 'Ustoz Dilnoza Rustamova',
      subject: subjectTitle,
      grade: '9–11-sinf',
      topicsCount: 10,
      isFree: true,
      priceUzs: 0,
      downloadsCount: 412,
      rating: 4.8,
      description: 'Ovozli tushuntirish va rasmli chizmalar bilan bepul qo‘llanma.',
    ),
    MarketplaceTextbook(
      id: 'mp-3',
      title: '$subjectTitle: murakkab masalalar tahlili',
      authorName: 'Ustoz Sardorbek Aliyev',
      subject: subjectTitle,
      grade: '11-sinf',
      topicsCount: 16,
      isFree: false,
      priceUzs: 35000,
      downloadsCount: 94,
      rating: 4.7,
      description: 'Olimpiada va milliy sertifikat darajasidagi masalalar.',
    ),
  ];
}
