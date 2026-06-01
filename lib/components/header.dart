import 'package:jaspr/server.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield header(classes: 'site-header', [
      div(classes: 'header-inner', [
        a(href: '/', classes: 'logo-link', [
           span(classes: 'logo-icon', [text('🫧')]),
          span(classes: 'logo-text', [text('WUWA')]),
          span(classes: 'logo-dot', [text('.')]),
          span(classes: 'logo-ext', [text('app')]),
        ]),
        nav(classes: 'header-nav', [
          a(href: '/', classes: 'header-nav-link', [text('新聞')]),
          a(href: '/calc/', classes: 'header-nav-link', [text('計算機')]),
        ]),
        span(classes: 'header-subtitle', []),
      ]),
    ]);
  }
}
