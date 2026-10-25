import 'package:jaspr/server.dart';
import '../components/header.dart';
import '../components/footer.dart';

class CalcPage extends StatelessComponent {
  const CalcPage({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'app', [
      const Header(activePage: 'calc'),
      main_(id: 'main-content', classes: 'container calc-container page-main', [
        a(href: '/', classes: 'back-link', [text('← 返回情報站 / FIELD STATION')]),
        div(classes: 'calc-card', [
          p(classes: 'eyebrow', [text("ROVER'S KIT / CONVENE PLANNER")]),
          raw('<h1 class="calc-title"><img src="/img/astrites.png" alt="Astrites" class="astrites-icon"/> 鳴潮抽數計算機</h1>'),
          p(
              classes: 'calc-subtitle',
              [text('Wuthering Waves Draw Calculator')]),
          div(classes: 'calc-divider', []),

          // Currency → Draws
          div(classes: 'calc-section', [
            label(
                classes: 'calc-label',
                attributes: {'for': 'astrites'},
                [text('星聲 → 抽數')]),
            div(classes: 'calc-row', [
              input([],
                  type: InputType.number,
                  classes: 'calc-input',
                  id: 'astrites',
                  attributes: {
                    'placeholder': '輸入星聲數量',
                    'oninput': 'calcDraws()',
                    'min': '0',
                    'step': '1',
                    'inputmode': 'numeric',
                    'aria-describedby': 'astrites-help astrites-error',
                    'aria-invalid': 'false',
                  }),
              span(classes: 'calc-arrow', [text('→')]),
              div(classes: 'calc-result', attributes: {
                'aria-live': 'polite',
                'aria-atomic': 'true'
              }, [
                span(
                    classes: 'calc-result-num',
                    id: 'draws-from-astrites',
                    [text('0')]),
                span(classes: 'calc-result-label', [text('抽')]),
              ]),
            ]),
            p(
                id: 'astrites-error',
                classes: 'calc-error',
                attributes: {'aria-live': 'polite'},
                []),
            div(
                id: 'astrites-help',
                classes: 'calc-formula',
                [text('每 160 星聲可喚取 1 次，不足一抽的部分不計入。')]),
          ]),

          div(classes: 'calc-divider', []),

          // Draws → Currency
          div(classes: 'calc-section', [
            label(
                classes: 'calc-label',
                attributes: {'for': 'draws'},
                [text('抽數 → 星聲')]),
            div(classes: 'calc-row', [
              input([],
                  type: InputType.text,
                  classes: 'calc-input',
                  id: 'draws',
                  attributes: {
                    'placeholder': '輸入抽數或算式 e.g. 80+160',
                    'oninput': 'calcAstrites()',
                    'aria-describedby': 'draws-help draws-error',
                    'aria-invalid': 'false',
                  }),
              span(classes: 'calc-arrow', [text('→')]),
              div(classes: 'calc-result', attributes: {
                'aria-live': 'polite',
                'aria-atomic': 'true'
              }, [
                span(
                    classes: 'calc-result-num',
                    id: 'astrites-from-draws',
                    [text('0')]),
                raw('<span class="calc-result-label"><img src="/img/astrites.png" alt="Astrites" class="astrites-icon-sm"/></span>'),
              ]),
            ]),
            p(
                id: 'draws-error',
                classes: 'calc-error',
                attributes: {'aria-live': 'polite'},
                []),
            div(classes: 'calc-helper-buttons', [
              button(
                  classes: 'calc-helper-btn',
                  [text('角色小保 (+80)')],
                  attributes: {'onclick': 'addDraws(80)'}),
              button(
                  classes: 'calc-helper-btn',
                  [text('角色大保 (+160)')],
                  attributes: {'onclick': 'addDraws(160)'}),
              button(
                  classes: 'calc-helper-btn',
                  [text('武器保底 (+80)')],
                  attributes: {'onclick': 'addDraws(80)'}),
            ]),
            div(
                id: 'draws-help',
                classes: 'calc-formula',
                [text('× 160 = 所需星聲；支援 + - * / 與括號，結果須為非負整數。')]),
          ]),

          div(classes: 'calc-divider', []),

          // Reference: Astrites → Draws
          div(classes: 'calc-ref', [
            raw('<p class="calc-ref-title"><img src="/img/astrites.png" alt="" class="astrites-icon-xs"/> 換算參考</p>'),
            div(classes: 'calc-ref-grid calc-ref-draws', [
              _refItem('12,800', '80 抽'),
              _refItem('25,600', '160 抽'),
              _refItem('38,400', '(160+80) 抽'),
            ]),
          ]),

          div(classes: 'calc-divider', []),

          // Reference: Money → Astrites
          div(classes: 'calc-ref', [
            p(classes: 'calc-ref-title', [text('💰 儲值參考 (HKD)')]),
            div(classes: 'calc-ref-grid', [
              _moneyItem('HK\$8', '60'),
              _moneyItem('HK\$38', '300'),
              _moneyItem('HK\$118', '980'),
              _moneyItem('HK\$228', '1,980'),
              _moneyItem('HK\$388', '3,280'),
              _moneyItem('HK\$788', '6,480'),
              _moneyItem('HK\$3,940', '32,400'),
              _moneyItem('HK\$7,880', '64,800'),
            ]),
          ]),
          p(classes: 'calc-note', [
            raw('儲值價格來源：<a href="https://payment.kurogame-service.com/pay/wutheringwaves/cashier" target="_blank" rel="noopener">Kuro Games 官方儲值頁</a>'),
            br(),
            text('僅列基礎數量，不含首儲加倍及贈送；月相可 1:1 兌換星聲，實際價格以官方為準。'),
          ]),

          div(classes: 'calc-divider', []),

          // Cost per draw reference
          div(classes: 'calc-cost-per-draw', [
            p(classes: 'calc-ref-title', [text('💸 每抽成本')]),
            div(classes: 'calc-cost-grid', [
              div(classes: 'calc-cost-item calc-cost-worst', [
                span(classes: 'calc-cost-label', [text('最貴（小額儲值）')]),
                span(classes: 'calc-cost-val', [text(r'≈ HK$21.33 / 抽')]),
              ]),
              div(classes: 'calc-cost-item calc-cost-best', [
                span(classes: 'calc-cost-label', [text('小月卡')]),
                span(classes: 'calc-cost-val', [text(r'≈ HK$2 / 抽')]),
              ]),
            ]),
          ]),
        ]),
      ]),
      const Footer(),
    ]);
    yield raw('<script src="/js/calculator.js" defer></script>');
  }

  Component _refItem(String val, String desc) {
    return div(classes: 'calc-ref-item', [
      span(classes: 'calc-ref-val', [text(val)]),
      raw('<span class="calc-ref-desc"><img src="/img/astrites.png" alt="" class="astrites-icon-xs"/> = $desc</span>'),
    ]);
  }

  Component _moneyItem(String price, String astrites) {
    return div(classes: 'calc-ref-item', [
      span(classes: 'calc-ref-val', [text(price)]),
      raw('<span class="calc-ref-desc">= $astrites <img src="/img/astrites.png" alt="" class="astrites-icon-xs"/></span>'),
    ]);
  }
}
