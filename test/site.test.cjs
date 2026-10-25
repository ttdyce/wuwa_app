const assert = require('node:assert/strict');
const { readFileSync } = require('node:fs');
const path = require('node:path');
const { test } = require('node:test');
const { runInNewContext } = require('node:vm');

function element(value = '') {
  return {
    value, textContent: '', hidden: false, attributes: {}, focused: false,
    validity: { badInput: false },
    setAttribute(name, value) { this.attributes[name] = value; },
    focus() { this.focused = true; },
  };
}

function calculator() {
  const ids = {};
  for (const id of ['astrites', 'draws', 'draws-from-astrites', 'astrites-from-draws', 'astrites-error', 'draws-error']) {
    ids[id] = element();
  }
  const context = { document: { getElementById: id => ids[id] } };
  runInNewContext(readFileSync(path.join(__dirname, '../web/js/calculator.js'), 'utf8'), context);
  return { context, ids };
}

test('calculator preserves arithmetic precedence, parentheses, and unary signs', () => {
  const { context } = calculator();
  for (const [expression, expected] of [
    ['80 + 160', 240], ['80 + 160 * 2', 400], ['(80 + 160) / 2', 120],
    ['-(-80)', 80], ['80--80', 160], ['1.5 + .5', 2], ['0', 0], ['', 0],
  ]) {
    assert.equal(context.evaluateDraws(expression), expected, expression);
  }
});

test('calculator rejects malformed, negative, fractional, infinite, and unsafe results', () => {
  const { context, ids } = calculator();
  for (const expression of ['80+', '(80', '80)', '1/0', '0/0', '-1', '1.5', '2**3', '80abc', 'alert(1)', '80 80', '()', '1(2)', '9007199254740992', '9007199254740993-9007199254740992', '9007199254740991*2/2']) {
    assert.throws(() => context.evaluateDraws(expression), undefined, expression);
  }
  ids.draws.value = String(Number.MAX_SAFE_INTEGER);
  context.calcAstrites();
  assert.equal(ids['astrites-from-draws'].textContent, '—');
  assert.equal(ids.draws.attributes['aria-invalid'], 'true');
});

test('native invalid-number states are errors and signed zero is displayed as zero', () => {
  const { context, ids } = calculator();
  ids.astrites.validity.badInput = true;
  context.calcDraws();
  assert.equal(ids['draws-from-astrites'].textContent, '—');
  assert.equal(ids.astrites.attributes['aria-invalid'], 'true');
  assert.notEqual(ids['astrites-error'].textContent, '');
  ids.astrites.validity.badInput = false;
  ids.astrites.value = '-0';
  context.calcDraws();
  assert.equal(ids['draws-from-astrites'].textContent, '0');
  assert.equal(ids['astrites-error'].textContent, '');
  ids.draws.value = '-0';
  context.calcAstrites();
  assert.equal(ids['astrites-from-draws'].textContent, '0');
});

test('calculator clears stale results, reports errors, and recovers on valid input', () => {
  const { context, ids } = calculator();
  ids.draws.value = '80';
  context.calcAstrites();
  assert.equal(ids['astrites-from-draws'].textContent, '12,800');
  ids.draws.value = '80+';
  context.calcAstrites();
  assert.equal(ids['astrites-from-draws'].textContent, '—');
  assert.notEqual(ids['draws-error'].textContent, '');
  assert.equal(ids.draws.attributes['aria-invalid'], 'true');
  ids.draws.value = '160';
  context.calcAstrites();
  assert.equal(ids['astrites-from-draws'].textContent, '25,600');
  assert.equal(ids['draws-error'].textContent, '');
  assert.equal(ids.draws.attributes['aria-invalid'], 'false');
  context.addDraws(80);
  assert.equal(ids['astrites-from-draws'].textContent, '38,400');
  ids.draws.value = '';
  context.calcAstrites();
  assert.equal(ids['astrites-from-draws'].textContent, '0');
});

test('astrite conversion floors only the draw count and rejects invalid currency', () => {
  const { context, ids } = calculator();
  for (const [value, expected] of [['159', '0'], ['160', '1'], ['319', '1'], ['320', '2'], ['', '0']]) {
    ids.astrites.value = value;
    context.calcDraws();
    assert.equal(ids['draws-from-astrites'].textContent, expected);
  }
  for (const value of ['-160', '1.5', 'Infinity', 'invalid', '9007199254740992']) {
    ids.astrites.value = value;
    context.calcDraws();
    assert.equal(ids['draws-from-astrites'].textContent, '—');
    assert.notEqual(ids['astrites-error'].textContent, '');
    assert.equal(ids.astrites.attributes['aria-invalid'], 'true');
  }
});

function homepage() {
  const ids = {};
  for (const id of ['search', 'search-count', 'visible-count', 'no-results', 'load-more', 'clear-search']) {
    ids[id] = element();
  }
  const cards = Array.from({ length: 27 }, (_, index) => ({
    ...element(),
    dataset: {
      title: index < 2 ? ['Pinned FAQ', 'Pinned Event'][index] : 'Archive ' + index,
      category: index % 3 === 1 ? '活動' : '公告',
    },
  }));
  const groups = [cards.slice(0, 2), cards.slice(2, 15), cards.slice(15)].map(children => ({
    ...element(), querySelectorAll: () => children,
  }));
  const buttons = ['all', '公告', '活動'].map((category, index) => {
    const button = { ...element(), dataset: { filter: category }, active: index === 0 };
    button.classList = { toggle: (_, active) => { button.active = active; } };
    return button;
  });
  const context = {
    document: {
      getElementById: id => ids[id],
      querySelector(selector) {
        if (selector === '.filter-btn.active') return buttons.find(button => button.active);
        if (selector === '[data-filter="all"]') return buttons[0];
        throw new Error('Unexpected selector: ' + selector);
      },
      querySelectorAll(selector) {
        if (selector === '[data-news-card]') return cards;
        if (selector === '[data-article-group]') return groups;
        if (selector === '.filter-btn') return buttons;
        throw new Error('Unexpected selector: ' + selector);
      },
    },
  };
  runInNewContext(readFileSync(path.join(__dirname, '../web/js/home.js'), 'utf8'), context);
  return { context, ids, cards, groups, buttons };
}

test('news pagination counts pinned posts and makes every result reachable', () => {
  const { context, ids, cards } = homepage();
  assert.equal(cards.filter(card => !card.hidden).length, 10);
  assert.equal(ids['search-count'].textContent, '27 則情報');
  assert.equal(cards[0].hidden, false);
  assert.equal(ids['load-more'].hidden, false);
  context.loadMoreArticles();
  assert.equal(cards.filter(card => !card.hidden).length, 20);
  assert.equal(cards[10].focused, true);
  context.loadMoreArticles();
  assert.equal(cards.filter(card => !card.hidden).length, 27);
  assert.equal(ids['load-more'].hidden, true);
});

test('news search includes pinned posts, trims whitespace, and hides empty groups', () => {
  const { context, ids, cards, groups } = homepage();
  ids.search.value = '  PINNED faq  ';
  context.filterArticles();
  assert.equal(cards.filter(card => !card.hidden).length, 1);
  assert.equal(cards[0].hidden, false);
  assert.equal(cards[1].hidden, true);
  assert.equal(ids['search-count'].textContent, '1 則情報');
  assert.deepEqual(groups.map(group => group.hidden), [false, true, true]);
});

test('categories combine with search and reset empty results accessibly', () => {
  const { context, ids, cards, groups, buttons } = homepage();
  ids.search.value = 'Pinned';
  context.setFilter(buttons[2]);
  assert.equal(cards.filter(card => !card.hidden).length, 1);
  assert.equal(cards[1].hidden, false);
  assert.equal(buttons[2].attributes['aria-pressed'], 'true');
  assert.equal(buttons[0].attributes['aria-pressed'], 'false');
  ids.search.value = 'no-matching-news';
  context.filterArticles();
  assert.equal(ids['no-results'].hidden, false);
  assert.equal(ids['load-more'].hidden, true);
  assert.ok(groups.every(group => group.hidden));
  context.resetFilters();
  assert.equal(ids.search.value, '');
  assert.equal(ids['no-results'].hidden, true);
  assert.equal(cards.filter(card => !card.hidden).length, 10);
  assert.equal(buttons[0].attributes['aria-pressed'], 'true');
  assert.equal(ids.search.focused, true);
});
