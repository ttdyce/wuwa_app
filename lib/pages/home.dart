import 'package:jaspr/server.dart';
import '../components/header.dart';
import '../components/footer.dart';
import '../components/category_filter.dart';
import '../components/article_list.dart';
import '../components/patch_timeline.dart';
import '../models/article.dart';

class HomePage extends StatelessComponent {
  final List<Article> articles;
  final DateTime buildTime;
  final List<PatchInfo> patches;

  const HomePage({
    super.key,
    required this.articles,
    required this.buildTime,
    required this.patches,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    PatchInfo? currentPatch;
    PatchInfo? nextPatch;
    for (final patch in patches) {
      if (patch.date.isAfter(buildTime)) {
        nextPatch ??= patch;
      } else {
        currentPatch = patch;
      }
    }

    var progressPercent = 1.0;
    if (currentPatch != null && nextPatch != null) {
      final total = nextPatch.date.difference(currentPatch.date).inMilliseconds;
      final elapsed = buildTime.difference(currentPatch.date).inMilliseconds;
      progressPercent = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 1.0;
    }
    final updated = buildTime.toUtc().add(const Duration(hours: 8));
    final updatedLabel =
        '${updated.year}.${updated.month.toString().padLeft(2, '0')}.${updated.day.toString().padLeft(2, '0')} '
        '${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')}';

    yield div(classes: 'app', [
      const Header(activePage: 'home'),
      main_(id: 'main-content', classes: 'home-main', [
        section(classes: 'hero', attributes: {
          'aria-labelledby': 'hero-title'
        }, [
          div(classes: 'hero-art', attributes: {
            'aria-hidden': 'true'
          }, [
            img(src: '/img/denia-banner.jpg', alt: '', attributes: {
              'width': '1920',
              'height': '1080',
              'fetchpriority': 'high',
            }),
          ]),
          div(classes: 'hero-grid', attributes: {'aria-hidden': 'true'}, []),
          div(classes: 'hero-inner', [
            div(classes: 'hero-copy', [
              p(classes: 'eyebrow hero-eyebrow', [
                span(
                    classes: 'status-dot',
                    attributes: {'aria-hidden': 'true'},
                    []),
                text('鳴潮 · NEWS'),
              ]),
              h1(id: 'hero-title', classes: 'hero-title', [
                text('WUTHERING'),
                span([text('WAVES')]),
              ]),
              p(classes: 'hero-tagline', [text('鳴潮情報，一站掌握。')]),
              p(classes: 'hero-description', [
                text('最新消息、版本更新與活動公告。'),
                br(),
                text('給漂泊者的非官方情報站。'),
              ]),
              div(classes: 'hero-actions', [
                a(href: '#news', classes: 'button-primary', [
                  text('探索最新情報'),
                  span(attributes: {'aria-hidden': 'true'}, [text('↗')]),
                ]),
                a(href: '/calc/', classes: 'button-text', [
                  text('抽卡計算機'),
                  span(attributes: {'aria-hidden': 'true'}, [text('→')]),
                ]),
              ]),
            ]),
            div(classes: 'hero-caption', [
              span(
                  classes: 'eyebrow',
                  [text('RESONATOR ARCHIVE / FEATURED ART')]),
              span(classes: 'hero-character', [
                text('Denia'),
                span(classes: 'hero-date', [text(' — 2026.05.24')]),
              ]),
              span(classes: 'hero-art-credit', [text('ARTWORK © KURO GAMES')]),
            ]),
            div(classes: 'hero-footer', [
              span(classes: 'hero-coordinate', [text('SOLARIS-3 / 歡迎回來，漂泊者')]),
              a(href: '#news', classes: 'scroll-cue', [
                text('向下探索'),
                span(attributes: {'aria-hidden': 'true'}, [text('↓')]),
              ]),
            ]),
          ]),
        ]),
        div(classes: 'container home-content', [
          if (currentPatch != null)
            div(id: 'version-tracker', classes: 'version-strip', [
              div(classes: 'version-strip-label', [
                span(
                    classes: 'status-dot',
                    attributes: {'aria-hidden': 'true'},
                    []),
                span([
                  text('版本追蹤'),
                  small([text('VERSION TRACKER')])
                ]),
              ]),
              PatchTimeline(
                current: currentPatch,
                next: nextPatch,
                progressPercent: progressPercent,
                nextDateIso: nextPatch?.date.toUtc().toIso8601String() ?? '',
              ),
            ]),
          div(classes: 'news-layout', [
            section(id: 'news', classes: 'news-section', attributes: {
              'aria-labelledby': 'news-title'
            }, [
              div(classes: 'section-heading', [
                div([
                  p(classes: 'eyebrow', [text('01 / LATEST TRANSMISSIONS')]),
                  h2(id: 'news-title', [text('最新情報')]),
                ]),
                span(
                    id: 'search-count',
                    classes: 'search-count',
                    attributes: {'aria-live': 'polite', 'aria-atomic': 'true'},
                    [text('${articles.length} 則情報')]),
              ]),
              div(classes: 'news-controls', [
                const CategoryFilter(),
                div(classes: 'search-bar', [
                  raw('<svg class="search-icon" viewBox="0 0 24 24" fill="none" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5" stroke="currentColor" stroke-width="1.5"/><path d="m16 16 4.5 4.5" stroke="currentColor" stroke-width="1.5"/></svg>'),
                  input([],
                      type: InputType.search,
                      classes: 'search-input',
                      id: 'search',
                      attributes: {
                        'placeholder': '搜尋情報...',
                        'aria-label': '搜尋情報標題',
                        'oninput': 'filterArticles()',
                      }),
                  button(
                      id: 'clear-search',
                      classes: 'clear-search',
                      attributes: {
                        'type': 'button',
                        'aria-label': '清除搜尋',
                        'onclick': 'clearSearch()',
                        'hidden': ''
                      },
                      [
                        text('×')
                      ]),
                ]),
              ]),
              ArticleList(articles: articles),
              div(id: 'no-results', classes: 'empty-state', attributes: {
                'hidden': '',
                'role': 'status'
              }, [
                p(classes: 'eyebrow', [text('NO SIGNAL FOUND')]),
                h3([text('暫時沒有收到這個頻率的情報。')]),
                p([text('試試其他關鍵字，或切換情報分類。')]),
                button(
                    classes: 'button-text',
                    attributes: {'type': 'button', 'onclick': 'resetFilters()'},
                    [text('重設搜尋與分類 ↗')]),
              ]),
              div(classes: 'news-pagination', [
                p(
                    id: 'visible-count',
                    attributes: {'aria-live': 'polite', 'hidden': ''},
                    []),
                button(id: 'load-more', classes: 'load-more', attributes: {
                  'type': 'button',
                  'hidden': '',
                  'onclick': 'loadMoreArticles()'
                }, [
                  text('載入更多情報'),
                  span(attributes: {'aria-hidden': 'true'}, [text('+')]),
                ]),
              ]),
              p(classes: 'build-info', [text('資料更新 $updatedLabel · UTC+8')]),
              raw('<noscript><p class="build-info">已顯示完整情報列表。開啟 JavaScript 即可搜尋與篩選。</p></noscript>'),
            ]),
            aside(classes: 'rover-sidebar', attributes: {
              'aria-label': '漂泊者工具與連結'
            }, [
              p(classes: 'eyebrow', [text("02 / ROVER'S KIT")]),
              a(href: '/calc/', classes: 'tool-card', [
                div(classes: 'tool-card-top', [
                  span(classes: 'tool-number', [text('01 / CONVENE PLANNER')]),
                  img(src: '/img/astrites.png', alt: '', attributes: {
                    'width': '64',
                    'height': '64',
                    'loading': 'lazy'
                  }),
                ]),
                h3([text('每一次喚取，'), br(), text('都心中有數。')]),
                p([text('星聲換算 · 抽數計算 · 保底規劃')]),
                span(classes: 'tool-card-link', [
                  text('開啟抽卡計算機'),
                  span(attributes: {'aria-hidden': 'true'}, [text('↗')])
                ]),
              ]),
              div(classes: 'resource-links', [
                _resourceLink('鳴潮官方網站', 'OFFICIAL WEBSITE',
                    'https://wutheringwaves.kurogames.com/zh-tw/main/'),
                _resourceLink('官方儲值中心', 'TOP-UP CENTER',
                    'https://payment.kurogame-service.com/pay/wutheringwaves/cashier'),
              ]),
              div(classes: 'station-note', [
                span(classes: 'eyebrow', [text('// ABOUT THIS STATION')]),
                p([text('A site for wuthering waves news')]),
              ]),
            ]),
          ]),
        ]),
      ]),
      const Footer(),
    ]);
    yield raw('<script src="/js/home.js" defer></script>');
  }

  Component _resourceLink(String title, String subtitle, String href) {
    return a(
        href: href,
        target: Target.blank,
        classes: 'resource-link',
        attributes: {
          'rel': 'noopener noreferrer'
        },
        [
          span([
            text(title),
            small([text(subtitle)])
          ]),
          span(attributes: {'aria-hidden': 'true'}, [text('↗')]),
        ]);
  }
}
