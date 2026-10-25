import 'package:jaspr/server.dart';

class Footer extends StatelessComponent {
  const Footer({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield footer(classes: 'footer', [
      div(classes: 'footer-inner', [
        div(classes: 'footer-brand', [
          a(href: '/', classes: 'logo-text', [
            text('WUWA'),
            span(classes: 'logo-ext', [text('.app')])
          ]),
          p([text('鳴潮新消息，這裡見。')]),
        ]),
        div(classes: 'footer-credits', [
          p([text('非官方玩家情報站 · UNOFFICIAL FAN PROJECT')]),
          p([text('遊戲內容與美術版權歸 KURO GAMES 所有。本站與官方無隸屬關係。')]),
          span(
              classes: 'footer-copyright',
              [text('© ${DateTime.now().year} wuwa.app')]),
        ]),
        a(href: '#main-content', classes: 'back-to-top', [
          text('返回頂部'),
          span(attributes: {'aria-hidden': 'true'}, [text('↑')]),
        ]),
      ]),
    ]);
  }
}
