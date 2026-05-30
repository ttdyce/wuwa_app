import 'package:jaspr/server.dart';
import '../components/header.dart';
import '../components/particles.dart';
import '../models/article.dart';

class ArticlePage extends StatelessComponent {
  final Article article;

  const ArticlePage({super.key, required this.article});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'app', [
      const Particles(),
      const Header(),
      main_(classes: 'container article-container', [
        a(href: '/', classes: 'back-link', [text('← 返回列表 BACK')]),
        div(classes: 'article-header', [
          span(classes: 'article-category', [text(article.categoryLabel)]),
          h1(classes: 'article-title', [text(article.title)]),
          span(classes: 'article-date', [text(article.formattedDate)]),
        ]),
        div(classes: 'article-content', [
          raw(article.content),
        ]),
      ]),
      footer(classes: 'footer', [
        span([text('© 2026 wuwa.app — Not affiliated with Kuro Games')]),
      ]),
    ]);
  }
}
