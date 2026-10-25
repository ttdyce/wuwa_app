import 'package:jaspr/server.dart';
import '../models/article.dart';

class ArticleList extends StatelessComponent {
  final List<Article> articles;

  const ArticleList({super.key, required this.articles});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final pinned = articles.where((a) => a.isPinned).toList();
    final regular = articles.where((a) => !a.isPinned).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    yield div(classes: 'article-list', [
      if (pinned.isNotEmpty)
        div(classes: 'article-group pinned-section', attributes: {
          'data-article-group': ''
        }, [
          h3(classes: 'section-label', [
            text('置頂情報'),
            span([text('PINNED')])
          ]),
          div(classes: 'pinned-grid', [
            ...pinned.map(_buildCard),
          ]),
        ]),
      ..._buildGrouped(regular),
    ]);
  }

  Iterable<Component> _buildGrouped(List<Article> articles) sync* {
    final groups = <String, List<Article>>{};
    for (final article in articles) {
      final month = '${article.startTime.year}年${article.startTime.month}月';
      (groups[month] ??= []).add(article);
    }
    for (final group in groups.entries) {
      yield div(classes: 'article-group', attributes: {
        'data-article-group': ''
      }, [
        h3(classes: 'month-header', [text(group.key)]),
        ...group.value.map(_buildCard),
      ]);
    }
  }

  Component _buildCard(Article article) {
    if (article.isPinned) {
      return a(
        href: '/article/${article.id}.html',
        classes: 'pinned-card',
        attributes: {
          'data-news-card': '',
          'data-category': article.categoryLabel,
          'data-title': article.title,
        },
        [
          span(
              classes: 'pinned-pin',
              attributes: {'aria-hidden': 'true'},
              [text('↗')]),
          span(classes: 'pinned-title', [text(article.title)]),
          span(classes: 'pinned-date', [text(article.formattedDate)]),
        ],
      );
    }
    return a(
      href: '/article/${article.id}.html',
      classes: 'article-card',
      attributes: {
        'data-news-card': '',
        'data-category': article.categoryLabel,
        'data-title': article.title,
      },
      [
        span(classes: 'card-date', [text(article.formattedDate)]),
        div(classes: 'card-body', [
          span(classes: 'card-category', [text(article.categoryLabel)]),
          h4(classes: 'card-title', [text(article.title)]),
        ]),
        span(
            classes: 'card-arrow',
            attributes: {'aria-hidden': 'true'},
            [text('↗')]),
      ],
    );
  }
}
