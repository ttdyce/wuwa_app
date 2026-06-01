import 'package:jaspr/server.dart';
import '../models/article.dart';

class ArticleList extends StatelessComponent {
  final List<Article> articles;

  const ArticleList({super.key, required this.articles});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final pinned = articles.where((a) => a.isPinned).toList();
    final regular = articles.where((a) => !a.isPinned).toList();

    yield div(classes: 'article-list', [
      // Pinned section
      if (pinned.isNotEmpty) ...[
        div(classes: 'section-label', [text('📌 置頂 PINNED')]),
        div(classes: 'pinned-grid', [
          ...pinned.map((a) => _buildCard(a)),
        ]),
      ],
      // Regular articles grouped by month
      ..._buildGrouped(regular),
    ]);
  }

  Iterable<Component> _buildGrouped(List<Article> articles) sync* {
    String currentMonth = '';
    for (final article in articles) {
      final month = '${article.startTime.year}年${article.startTime.month}月';
      if (month != currentMonth) {
        currentMonth = month;
        yield div(classes: 'month-header', [text(currentMonth)]);
      }
      yield _buildCard(article);
    }
  }

  Component _buildCard(Article article) {
    if (article.isPinned) {
      return a(
        href: '/article/${article.id}.html',
        classes: 'pinned-card',
        attributes: {'data-category': article.categoryLabel},
        [
          span(classes: 'pinned-pin', [text('📌')]),
          span(classes: 'pinned-title', [text(article.title)]),
          span(classes: 'pinned-date', [text(article.formattedDate)]),
        ],
      );
    }
    return a(
      href: '/article/${article.id}.html',
      classes: 'article-card',
      attributes: {'data-category': article.categoryLabel},
      [
        div(classes: 'card-header', [
          span(classes: 'card-category', [text(article.categoryLabel)]),
        ]),
        h3(classes: 'card-title', [text(article.title)]),
        span(classes: 'card-date', [text(article.formattedDate)]),
      ],
    );
  }
}
