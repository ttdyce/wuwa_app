import 'package:jaspr/jaspr.dart';
import 'components/header.dart';
import 'components/category_filter.dart';
import 'components/article_list.dart';
import 'pages/article_page.dart';
import 'models/article.dart';
import 'dart:convert';

// This will be replaced at build time with the actual articles
List<Article> _loadArticles() {
  // In SSG mode, we read from the data file at build time
  return [];
}

@override
class WuwaApp extends StatelessComponent {
  const WuwaApp({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(
      classes: 'app',
      [
        const Header(),
        div(classes: 'container', [
          const CategoryFilter(),
          const ArticleList(),
        ]),
        footer(classes: 'footer', [
          text('© 2026 wuwa.app — Not affiliated with Kuro Games'),
        ]),
      ],
    );
  }
}
