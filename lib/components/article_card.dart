import 'package:jaspr/jaspr.dart';

class ArticleCard extends StatelessComponent {
  final int id;
  final String title;
  final String date;
  final String category;
  final bool isPinned;

  const ArticleCard({
    super.key,
    required this.id,
    required this.title,
    required this.date,
    required this.category,
    this.isPinned = false,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(
      href: '/article/$id',
      classes: 'article-card${isPinned ? ' pinned' : ''}',
      [
        div(classes: 'card-header', [
          span(classes: 'card-category', [text(category)]),
          if (isPinned) span(classes: 'card-pin', [text('📌')]),
        ]),
        h3(classes: 'card-title', [text(title)]),
        span(classes: 'card-date', [text(date)]),
      ],
    );
  }
}
