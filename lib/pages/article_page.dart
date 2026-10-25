import 'package:jaspr/server.dart';
import 'package:html/parser.dart' show parseFragment;
import '../components/header.dart';
import '../components/footer.dart';
import '../models/article.dart';

class ArticlePage extends StatelessComponent {
  final Article article;

  const ArticlePage({super.key, required this.article});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final content = parseFragment(article.content);
    final emailAddress = RegExp(r'^[^\s@:/]+@[^\s@/]+\.[^\s@/]+$');
    for (final link in content.querySelectorAll('a[href]')) {
      final href = link.attributes['href'];
      if (href != null && emailAddress.hasMatch(href.trim())) {
        link.attributes['href'] = 'mailto:${href.trim()}';
      }
    }
    final unavailableImages = content
        .querySelectorAll('img')
        .where(
          (image) => image.attributes['src']?.startsWith(r'\\') == true,
        )
        .toList();
    for (final image in unavailableImages) {
      image.remove();
    }

    yield div(classes: 'app', [
      const Header(activePage: 'news'),
      main_(
          id: 'main-content',
          classes: 'container article-container page-main',
          [
            a(
                href: '/#news',
                classes: 'back-link',
                [text('← 返回情報站 / ALL TRANSMISSIONS')]),
            div(classes: 'article-header', [
              p(
                  classes: 'eyebrow',
                  [text('THE SOLARIS DISPATCH / OFFICIAL NEWS')]),
              span(classes: 'article-category', [text(article.categoryLabel)]),
              h1(classes: 'article-title', [text(article.title)]),
              span(
                  classes: 'article-date',
                  [text('${article.formattedDate} · 官方情報轉載')]),
            ]),
            div(classes: 'article-content', [
              if (unavailableImages.isNotEmpty)
                p(classes: 'article-source-note', attributes: {
                  'role': 'status'
                }, [
                  text('原始資料包含無法使用的圖片連結，已略過。其餘圖片已保留，完整資訊請以官方網站為準。'),
                ]),
              if (article.content.trim().isNotEmpty)
                raw(content.outerHtml)
              else
                p(
                    attributes: {'role': 'status'},
                    [text('此則情報暫無內文，請前往鳴潮官方網站查看。')]),
            ]),
            div(classes: 'article-end', [
              a(href: '/#news', classes: 'button-text', [text('繼續探索更多情報 ↗')]),
              a(
                  href: 'https://wutheringwaves.kurogames.com/zh-tw/main/',
                  target: Target.blank,
                  attributes: {'rel': 'noopener noreferrer'},
                  [text('鳴潮官方網站 ↗')]),
            ]),
          ]),
      const Footer(),
    ]);
  }
}
