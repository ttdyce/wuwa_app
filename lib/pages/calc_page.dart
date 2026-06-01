import 'package:jaspr/server.dart';
import '../components/header.dart';
import '../components/particles.dart';

class CalcPage extends StatelessComponent {
  const CalcPage({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'app', [
      const Particles(),
      const Header(),
      main_(classes: 'container calc-container', [
        a(href: '/', classes: 'back-link', [text('← 返回列表 BACK')]),
        div(classes: 'calc-card', [
          raw('<h1 class="calc-title"><img src="/img/astrites.png" alt="Astrites" class="astrites-icon"/> 鳴潮抽數計算機</h1>'),
          p(classes: 'calc-subtitle', [text('Wuthering Waves Draw Calculator')]),
          div(classes: 'calc-divider', []),

          // Currency → Draws
          div(classes: 'calc-section', [
            label(classes: 'calc-label', [text('星聲 → 抽數')]),
            div(classes: 'calc-row', [
              input([], type: InputType.number, classes: 'calc-input', id: 'astrites',
                attributes: {
                  'placeholder': '輸入星聲數量',
                  'oninput': 'calcDraws()',
                  'min': '0',
                }),
              span(classes: 'calc-arrow', [text('→')]),
              div(classes: 'calc-result', [
                span(classes: 'calc-result-num', id: 'draws-from-astrites', [text('0')]),
                span(classes: 'calc-result-label', [text('抽')]),
              ]),
            ]),
            div(classes: 'calc-formula', [text('÷ 160 = 抽數')]),
          ]),

          div(classes: 'calc-divider', []),

          // Draws → Currency
          div(classes: 'calc-section', [
            label(classes: 'calc-label', [text('抽數 → 星聲')]),
            div(classes: 'calc-row', [
              input([], type: InputType.text, classes: 'calc-input', id: 'draws',
                attributes: {
                  'placeholder': '輸入抽數或算式 e.g. 80+160',
                  'oninput': 'calcAstrites()',
                }),
              span(classes: 'calc-arrow', [text('→')]),
              div(classes: 'calc-result', [
                span(classes: 'calc-result-num', id: 'astrites-from-draws', [text('0')]),
                raw('<span class="calc-result-label"><img src="/img/astrites.png" alt="Astrites" class="astrites-icon-sm"/></span>'),
              ]),
            ]),
            div(classes: 'calc-helper-buttons', [
              button(classes: 'calc-helper-btn', [text('角色小保 (+80)')], attributes: {'onclick': 'addDraws(80)'}),
              button(classes: 'calc-helper-btn', [text('角色大保 (+160)')], attributes: {'onclick': 'addDraws(160)'}),
              button(classes: 'calc-helper-btn', [text('武器保底 (+80)')], attributes: {'onclick': 'addDraws(80)'}),
            ]),
            div(classes: 'calc-formula', [text('× 160 = 所需星聲')]),
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
          ]),
        ]),
      ]),
      footer(classes: 'footer', [
        span([text('© 2026 wuwa.app — Not affiliated with Kuro Games')]),
      ]),
    ]);
    yield raw('''<script>
function calcDraws() {
  var v = parseInt(document.getElementById('astrites').value) || 0;
  var draws = Math.floor(v / 160);
  document.getElementById('draws-from-astrites').textContent = draws;
}

function calcAstrites() {
  var input = document.getElementById('draws').value.trim();
  if (!input) {
    document.getElementById('astrites-from-draws').textContent = '0';
    return;
  }
  try {
    var sanitized = input.replace(/[^0-9+\\-*/(). ]/g, '');
    var result = eval(sanitized);
    var v = Math.floor(result) || 0;
    var astrites = v * 160;
    document.getElementById('astrites-from-draws').textContent = astrites.toLocaleString();
  } catch (e) {}
}

function addDraws(n) {
  var el = document.getElementById('draws');
  var val = el.value.trim();
  el.value = val ? val + ' + ' + n : n;
  calcAstrites();
}
</script>''');
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
