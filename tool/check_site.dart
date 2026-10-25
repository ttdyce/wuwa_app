import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:html/parser.dart' show parseFragment;
import 'package:jaspr/server.dart';

import 'package:wuwa_app/components/patch_timeline.dart';
import 'package:wuwa_app/main.dart' as site;
import 'package:wuwa_app/models/article.dart';
import 'package:wuwa_app/pages/article_page.dart';
import 'package:wuwa_app/pages/calc_page.dart';
import 'package:wuwa_app/pages/home.dart';
import 'fetch_articles.dart' as fetch;

void check(bool condition, String message) {
  if (!condition) throw StateError(message);
}

Article article(int id, String title, DateTime date) => Article(
      id: id,
      title: title,
      content: '<p>Cached content</p>',
      articleType: 90,
      createTime: date,
      startTime: date,
      sortingMark: 0,
      isPinned: false,
    );

Future<void> main() async {
  Jaspr.initializeApp();
  final articles = [
    article(1, '版本前瞻 | 2.0版本「新旅途」', DateTime(2024, 12, 21)),
    article(2, '版本資訊 | 2.0 版本「新旅途」1月2日即將更新', DateTime(2024, 12, 31)),
    article(3, '版本資訊 | 3.7版本「新的共鳴」9月30日即將更新', DateTime(2026, 9, 28)),
  ];
  final patches = site.extractPatches(articles);
  check(patches.length == 2,
      'Version parsing must accept spaces and skip undated previews.');
  check(
      patches[0].version == 'v2.0', 'Versions must be sorted chronologically.');
  check(patches[0].date == DateTime.utc(2025, 1, 1, 16),
      'January patches must roll into the next year at UTC+8.');
  check(patches[1].date == DateTime.utc(2026, 9, 29, 16),
      'Patch dates must not depend on the build host timezone.');

  final timeline = await renderComponent(Document(
      body: PatchTimeline(
    current: patches[0],
    next: patches[1],
    progressPercent: 0.5,
    nextDateIso: patches[1].date.toIso8601String(),
  )));
  check(timeline.body.contains('width: 50.0%'),
      'The initial timeline bar must use the supplied progress.');
  check(timeline.body.contains('2025.01.02'),
      'Patch labels must use UTC+8 dates.');

  final home = await renderComponent(Document(
      body: HomePage(
    articles: articles,
    buildTime: DateTime.utc(2026, 10, 24, 20),
    patches: patches,
  )));
  check(home.body.contains('2026.10.25 04:00'),
      'Build timestamps must display in UTC+8.');
  check(
      RegExp(r'\bdata-news-card\b').allMatches(home.body).length ==
          articles.length,
      'All articles must be server-rendered for browsing without JavaScript.');
  check(home.body.contains('src="/js/home.js"'),
      'The news interaction script must be included.');
  final homeDocument = parseFragment(home.body);
  check(homeDocument.querySelector('.hero-tagline')?.text == '鳴潮情報，一站掌握。',
      'The hero tagline must use the selected news-first copy.');
  check(
      homeDocument.querySelector('.hero-description')?.text ==
          '最新消息、版本更新與活動公告。給漂泊者的非官方情報站。',
      'The hero description must use the selected news-first copy.');
  check(
      homeDocument.querySelector('.hero-character')?.text ==
          'Denia — 2026.05.24',
      'The featured artwork must retain the original Denia name and date.');
  check(
      homeDocument.querySelector('.station-note p')?.text ==
          'A site for wuthering waves news',
      'The station description must use the requested wording.');
  check(homeDocument.querySelector('.station-signature') == null,
      'The station description must not include an extra tagline.');

  final importedArticle = Article.fromJsonStored({
    ...articles.first.toJson(),
    'content':
        r'<a href="support@example.com">Contact</a><img src="\\private-server\missing.jpg"><img src="https://example.com/art.jpg">',
  });
  final detail = await renderComponent(
      Document(body: ArticlePage(article: importedArticle)));
  check(detail.body.contains('href="mailto:support@example.com"'),
      'Imported email addresses must open a mail client, not a missing local route.');
  check(
      !detail.body.contains('private-server') &&
          detail.body.contains('article-source-note'),
      'Unavailable private-drive images must be removed with an explicit source notice.');
  check(detail.body.contains('src="https://example.com/art.jpg"'),
      'Valid official artwork must remain unchanged.');

  final calculator = await renderComponent(Document(body: const CalcPage()));
  check(
      parseFragment(calculator.body)
          .querySelectorAll('.calc-row .calc-error')
          .isEmpty,
      'Error messages must sit below input rows without squeezing the controls.');

  for (final page in [home, detail, calculator]) {
    check(
        parseFragment(page.body).querySelector('.footer-brand p')?.text ==
            '鳴潮新消息，這裡見。',
        'The shared footer must use the selected wording on every page type.');
  }

  await checkFetchRecovery();
  print('Dart rendering, version dates, and cache recovery checks passed.');
}

Future<void> checkFetchRecovery() async {
  final originalDirectory = Directory.current;
  final fixture = await Directory.systemTemp.createTemp('wuwa-fetch-check-');
  try {
    Directory.current = fixture;
    final cached =
        article(10, 'Cached headline', DateTime(2026, 10, 1)).toJson();
    final cacheFile = File('data/articles.json');
    await cacheFile.parent.create(recursive: true);
    await cacheFile.writeAsString(jsonEncode([cached]));
    final metadata = {
      'articleId': 10,
      'articleTitle': 'Updated headline',
      'articleType': 90,
      'createTime': cached['createTime'],
      'startTime': cached['startTime'],
      'sortingMark': 0,
      'top': 0,
    };

    await http.runWithClient(
        fetch.main,
        () => MockClient((request) async {
              if (request.url.toString() == fetch.listApiUrl) {
                return http.Response(jsonEncode([metadata]), 200);
              }
              return http.Response('temporarily unavailable', 503);
            }));
    var stored = jsonDecode(await cacheFile.readAsString()) as List<dynamic>;
    check(stored.single['title'] == cached['title'],
        'Failed updates must preserve old metadata so they can be retried.');
    check(stored.single['content'] == cached['content'],
        'Failed updates must not erase cached content.');

    var retried = false;
    await http.runWithClient(
        fetch.main,
        () => MockClient((request) async {
              if (request.url.toString() == fetch.listApiUrl) {
                return http.Response(jsonEncode([metadata]), 200);
              }
              retried = true;
              return http.Response(
                  jsonEncode({'articleContent': '<p>Updated content</p>'}),
                  200);
            }));
    stored = jsonDecode(await cacheFile.readAsString()) as List<dynamic>;
    check(retried && stored.single['title'] == 'Updated headline',
        'The next fetch must retry and publish the successful update.');

    final beforeFailure = await cacheFile.readAsString();
    var refusedIncompleteData = false;
    try {
      await http.runWithClient(
          fetch.main,
          () => MockClient((request) async {
                if (request.url.toString() == fetch.listApiUrl) {
                  return http.Response(
                      jsonEncode([
                        {...metadata, 'articleId': 11}
                      ]),
                      200);
                }
                return http.Response(jsonEncode({'articleContent': ''}), 200);
              }));
    } on StateError {
      refusedIncompleteData = true;
    }
    check(refusedIncompleteData,
        'New articles without content must fail explicitly.');
    check(await cacheFile.readAsString() == beforeFailure,
        'Incomplete fetches must leave the existing cache untouched.');
  } finally {
    Directory.current = originalDirectory;
    await fixture.delete(recursive: true);
  }
}
