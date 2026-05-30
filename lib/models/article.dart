class Article {
  final int id;
  final String title;
  final String content;
  final int articleType;
  final DateTime createTime;
  final DateTime startTime;
  final int sortingMark;
  final bool isPinned;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.articleType,
    required this.createTime,
    required this.startTime,
    required this.sortingMark,
    required this.isPinned,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['articleId'] as int,
      title: json['articleTitle'] as String,
      content: json['articleContent'] as String? ?? '',
      articleType: json['articleType'] as int? ?? 90,
      createTime: DateTime.parse(json['createTime'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      sortingMark: json['sortingMark'] as int? ?? 0,
      isPinned: (json['top'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'articleType': articleType,
        'createTime': createTime.toIso8601String(),
        'startTime': startTime.toIso8601String(),
        'sortingMark': sortingMark,
        'isPinned': isPinned,
      };

  factory Article.fromJsonStored(Map<String, dynamic> json) {
    return Article(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String? ?? '',
      articleType: json['articleType'] as int? ?? 90,
      createTime: DateTime.parse(json['createTime'] as String),
      startTime: DateTime.parse(json['startTime'] as String),
      sortingMark: json['sortingMark'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  String get categoryLabel {
    switch (articleType) {
      case 89:
        return '活動';
      case 90:
        return '公告';
      default:
        return '新聞';
    }
  }

  String get formattedDate {
    final d = startTime;
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }
}
