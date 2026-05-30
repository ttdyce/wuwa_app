import 'package:jaspr/server.dart';
import '../components/header.dart';
import '../components/particles.dart';
import '../models/article.dart';

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
          h1(classes: 'calc-title', [text('💎 鳴潮抽卡計算器')]),
          p(classes: 'calc-subtitle', [text('Wuthering Waves Draw Calculator')]),
          div(classes: 'calc-divider', []),

          // Currency → Draws
          div(classes: 'calc-section', [
            label(classes: 'calc-label', [
              text('星聲 (Astrites) → 抽數'),
            ]),
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
            label(classes: 'calc-label', [
              text('抽數 → 需要星聲 (支援算式)'),
            ]),
            div(classes: 'calc-row', [
              input([], type: InputType.text, classes: 'calc-input', id: 'draws',
                attributes: {
                  'placeholder': '輸入抽數或算式 (e.g. 80+80)',
                  'oninput': 'calcAstrites()',
                }),
              span(classes: 'calc-arrow', [text('→')]),
              div(classes: 'calc-result', [
                span(classes: 'calc-result-num', id: 'astrites-from-draws', [text('0')]),
                span(classes: 'calc-result-label', [text('💎')]),
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

          // Reference info
          div(classes: 'calc-ref', [
            p(classes: 'calc-ref-title', [text('📊 換算參考')]),
            div(classes: 'calc-ref-grid', [
              div(classes: 'calc-ref-item', [
                span(classes: 'calc-ref-val', [text('160')]),
                span(classes: 'calc-ref-desc', [text('💎 = 1 抽')]),
              ]),
              div(classes: 'calc-ref-item', [
                span(classes: 'calc-ref-val', [text('800')]),
                span(classes: 'calc-ref-desc', [text('💎 = 5 抽')]),
              ]),
              div(classes: 'calc-ref-item', [
                span(classes: 'calc-ref-val', [text('3,200')]),
                span(classes: 'calc-ref-desc', [text('💎 = 20 抽')]),
              ]),
              div(classes: 'calc-ref-item', [
                span(classes: 'calc-ref-val', [text('8,000')]),
                span(classes: 'calc-ref-desc', [text('💎 = 50 抽')]),
              ]),
            ]),
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
    // Basic sanitization and evaluation for math
    // Only allow numbers and ()+-*/.
    var sanitized = input.replace(/[^0-9+\\-*/(). ]/g, '');
    var result = eval(sanitized);
    var v = parseInt(result) || 0;
    var astrites = v * 160;
    document.getElementById('astrites-from-draws').textContent = astrites.toLocaleString();
  } catch (e) {
    // If eval fails, just show 0 or keep previous
  }
}

function addDraws(n) {
  var el = document.getElementById('draws');
  var val = el.value.trim();
  if (val) {
    el.value = val + ' + ' + n;
  } else {
    el.value = n;
  }
  calcAstrites();
}
</script>''');
  }
}
