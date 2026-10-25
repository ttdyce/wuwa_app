const NEWS_PAGE_SIZE = 10;
let articleLimit = NEWS_PAGE_SIZE;

function filterArticles(reset = true) {
  if (reset) articleLimit = NEWS_PAGE_SIZE;
  const query = document.getElementById('search').value.trim().toLowerCase();
  const activeButton = document.querySelector('.filter-btn.active');
  const category = activeButton ? activeButton.dataset.filter : 'all';
  let matches = 0;
  let visible = 0;

  document.querySelectorAll('[data-news-card]').forEach(function (card) {
    const match = card.dataset.title.toLowerCase().includes(query)
      && (category === 'all' || card.dataset.category === category);
    if (match) matches++;
    card.hidden = !match || matches > articleLimit;
    if (!card.hidden) visible++;
  });

  document.querySelectorAll('[data-article-group]').forEach(function (group) {
    group.hidden = !Array.from(group.querySelectorAll('[data-news-card]'))
      .some(function (card) { return !card.hidden; });
  });

  document.getElementById('search-count').textContent = matches + ' 則情報';
  document.getElementById('visible-count').textContent = '顯示 ' + visible + ' / ' + matches + ' 則情報';
  document.getElementById('visible-count').hidden = matches === 0;
  document.getElementById('no-results').hidden = matches !== 0;
  document.getElementById('load-more').hidden = visible >= matches;
  document.getElementById('clear-search').hidden = document.getElementById('search').value.length === 0;
}

function setFilter(button) {
  document.querySelectorAll('.filter-btn').forEach(function (candidate) {
    const active = candidate === button;
    candidate.classList.toggle('active', active);
    candidate.setAttribute('aria-pressed', String(active));
  });
  filterArticles();
}

function loadMoreArticles() {
  const cards = Array.from(document.querySelectorAll('[data-news-card]'));
  const alreadyVisible = new Set(cards.filter(function (card) { return !card.hidden; }));
  articleLimit += NEWS_PAGE_SIZE;
  filterArticles(false);
  const firstNew = cards.find(function (card) { return !card.hidden && !alreadyVisible.has(card); });
  if (firstNew) firstNew.focus();
}

function clearSearch() {
  const search = document.getElementById('search');
  search.value = '';
  filterArticles();
  search.focus();
}

function resetFilters() {
  document.getElementById('search').value = '';
  setFilter(document.querySelector('[data-filter="all"]'));
  document.getElementById('search').focus();
}

filterArticles();
