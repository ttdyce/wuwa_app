import 'package:jaspr/server.dart';
import '../components/header.dart';
import '../components/particles.dart';
import '../components/category_filter.dart';
import '../components/article_list.dart';
import '../models/article.dart';

class HomePage extends StatelessComponent {
  final List<Article> articles;

  const HomePage({super.key, required this.articles});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'app', [
      const Particles(),
      const Header(),
      main_(classes: 'container', [
        // Hero banner
        div(classes: 'hero-banner', [
          div([], classes: 'hero-bg', attributes: {
            'style': "background-image: url('/img/denia-banner.jpg')",
          }),
          div([], classes: 'hero-overlay'),
          div(classes: 'hero-content', [
            p(classes: 'hero-sub', [text('Denia — 2026.05.24')]),
          ]),
        ]),
        // Search bar
        div(classes: 'search-bar', [
          input([], type: InputType.text, classes: 'search-input', id: 'search',
            attributes: {
              'placeholder': '搜尋新聞...',
              'oninput': 'filterArticles()',
            }),
          span(classes: 'search-icon', [text('🔍')]),
          span(classes: 'search-count', [text('${articles.length} 則新聞')]),
        ]),
        // Category filter
        const CategoryFilter(),
        // Article list
        ArticleList(articles: articles),
      ]),
      footer(classes: 'footer', [
        span([text('© 2026 wuwa.app — Not affiliated with Kuro Games')]),
      ]),
    ]);
    yield raw('''<script>
function filterArticles() {
  var search = (document.getElementById('search') || {}).value || '';
  search = search.toLowerCase();
  var activeBtn = document.querySelector('.filter-btn.active');
  var activeFilter = activeBtn ? (activeBtn.dataset.filter || 'all') : 'all';
  var cards = document.querySelectorAll('.article-card');
  var months = document.querySelectorAll('.month-header');
  var sections = document.querySelectorAll('.section-label');
  var countEl = document.querySelector('.search-count');
  var visible = 0;

  cards.forEach(function(card) {
    var title = (card.querySelector('.card-title') || {}).textContent || '';
    title = title.toLowerCase();
    var category = card.dataset.category || '';
    var matchSearch = !search || title.indexOf(search) !== -1;
    var matchFilter = activeFilter === 'all' || category === activeFilter;
    var show = matchSearch && matchFilter;
    card.style.display = show ? '' : 'none';
    if (show) visible++;
  });

  months.forEach(function(month) {
    var next = month.nextElementSibling;
    var hasVisible = false;
    while (next && !next.classList.contains('month-header') && !next.classList.contains('section-label')) {
      if (next.classList.contains('article-card') && next.style.display !== 'none') {
        hasVisible = true;
      }
      next = next.nextElementSibling;
    }
    month.style.display = hasVisible ? '' : 'none';
  });

  sections.forEach(function(s) {
    if (s.textContent.indexOf('置頂') !== -1) {
      var next = s.nextElementSibling;
      var hasVisible = false;
      while (next && !next.classList.contains('section-label') && !next.classList.contains('month-header')) {
        if (next.classList.contains('article-card') && next.style.display !== 'none') {
          hasVisible = true;
        }
        next = next.nextElementSibling;
      }
      s.style.display = hasVisible ? '' : 'none';
    }
  });

  if (countEl) countEl.textContent = visible + ' 則新聞';
}

function setFilter(btn) {
  var btns = document.querySelectorAll('.filter-btn');
  for (var i = 0; i < btns.length; i++) btns[i].classList.remove('active');
  btn.classList.add('active');
  filterArticles();
}
</script>''');
  }
}
