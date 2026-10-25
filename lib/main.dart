import 'dart:convert';
import 'dart:io';

import 'package:jaspr/server.dart';

import 'models/article.dart';
import 'pages/home.dart';
import 'pages/article_page.dart';
import 'pages/calc_page.dart';
import 'components/patch_timeline.dart';

/// Favicon link tags injected into every HTML `<head>`.
const _faviconTags = '''
    <link rel="icon" type="image/svg+xml" href="/favicon.svg?v=wave"/>
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32.png?v=wave"/>
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16.png?v=wave"/>
    <link rel="apple-touch-icon" sizes="180x180" href="/favicon-180.png?v=wave"/>
    <meta name="theme-color" content="#111411"/>''';

void main() async {
  Jaspr.initializeApp();

  // Load articles
  final file = File('data/articles.json');
  if (!await file.exists()) {
    print(
        'ERROR: data/articles.json not found. Run: dart run tool/fetch_articles.dart');
    exit(1);
  }

  final jsonStr = await file.readAsString();
  final List<dynamic> jsonList = json.decode(jsonStr);
  final articles = jsonList
      .map((json) => Article.fromJsonStored(json as Map<String, dynamic>))
      .toList();

  print('Loaded ${articles.length} articles for SSG');

  final buildTime = DateTime.now().toUtc();

  // Extract patch schedule from version info articles
  final patches = extractPatches(articles);
  final patchLabels = patches.map((patch) {
    final date = patch.date.toUtc().add(const Duration(hours: 8));
    return '${patch.version} (${date.month}/${date.day})';
  }).join(', ');
  print('Detected ${patches.length} patches: $patchLabels');

  // Create build directory
  final buildDir = Directory('build');
  if (await buildDir.exists()) {
    await buildDir.delete(recursive: true);
  }

  // Render home page
  final homeApp = Document(
    title: 'WUWA.app — 鳴潮漂泊者情報站',
    lang: 'zh-Hant',
    meta: const {
      'description':
          '非官方鳴潮玩家情報站。追蹤 Wuthering Waves 最新消息、活動與版本動態，使用星聲抽卡計算機規劃下一次喚取。'
    },
    styles: [StyleRule.import('/style.css')],
    body: HomePage(articles: articles, buildTime: buildTime, patches: patches),
  );

  final homeResponse = await renderComponent(homeApp);
  await _writePage('index.html', _injectFavicon(homeResponse.body));
  print('Generated: index.html');

  // Render individual article pages
  for (final article in articles) {
    final articleApp = Document(
      title: '${article.title} — wuwa.app',
      lang: 'zh-Hant',
      meta: {'description': '${article.title} — 鳴潮官方情報，收錄於 wuwa.app 非官方玩家情報站。'},
      styles: [StyleRule.import('/style.css')],
      body: ArticlePage(article: article),
    );
    final response = await renderComponent(articleApp);
    await _writePage(
        'article/${article.id}.html', _injectFavicon(response.body));
  }
  print('Generated ${articles.length} article pages');

  // Render calculator page
  final calcApp = Document(
    title: '抽卡計算器 — wuwa.app',
    lang: 'zh-Hant',
    meta: const {'description': '鳴潮星聲與抽數換算計算機，支援算式與角色、武器保底抽數規劃。'},
    styles: [StyleRule.import('/style.css')],
    body: const CalcPage(),
  );
  final calcResponse = await renderComponent(calcApp);
  await _writePage('calc/index.html', _injectFavicon(calcResponse.body));
  print('Generated: calc/index.html');

  // Copy static assets (CSS, images, favicons)
  await _copyAssets();

  print('SSG build complete!');
}

/// Inject favicon `<link>` tags into the `<head>` of rendered HTML.
String _injectFavicon(String html) {
  return html.replaceFirst(
    '<meta charset="utf-8"/>',
    '<meta charset="utf-8"/>\n$_faviconTags',
  );
}

Future<void> _writePage(String path, String html) async {
  final file = File('build/$path');
  await file.parent.create(recursive: true);
  await file.writeAsString(html);
}

Future<void> _copyAssets() async {
  await for (final entity
      in Directory('web').list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    final relativePath = entity.path.substring('web/'.length);
    final dest = File('build/$relativePath');
    await dest.parent.create(recursive: true);
    await entity.copy(dest.path);
  }
}

/// Extract patch schedule from version info articles.
/// Looks for articles with "版本資訊" in title that contain "X月X日即將更新".
List<PatchInfo> extractPatches(List<Article> articles) {
  final result = <PatchInfo>[];
  final seen = <String>{};

  for (final a in articles) {
    if (!a.title.contains('版本資訊') && !a.title.contains('版本前瞻')) continue;

    // Extract version number: "3.3版本" → "v3.3"
    final vMatch = RegExp(r'(\d+\.\d+)\s*版本').firstMatch(a.title);
    if (vMatch == null) continue;
    final version = 'v${vMatch.group(1)}';
    if (seen.contains(version)) continue;

    // Extract name: between「…」
    final nameMatch = RegExp(r'「([^」]+)」').firstMatch(a.title);
    final name = nameMatch?.group(1) ?? '';

    // Extract date: "X月X日"
    final dMatch = RegExp(r'(\d+)月(\d+)日').firstMatch(a.title);
    if (dMatch == null) continue;
    seen.add(version);

    // Use article year (start of the article) to resolve the date.
    // The month/day comes from the title; year from article start time.
    final month = int.parse(dMatch.group(1)!);
    final day = int.parse(dMatch.group(2)!);
    // If title month < article month, the patch is next year (edge case).
    var year = a.startTime.year;
    if (month < a.startTime.month) year++;

    result.add(PatchInfo(
      version: version,
      name: name,
      // Official patch dates are midnight UTC+8, regardless of the build host.
      date: DateTime.utc(year, month, day).subtract(const Duration(hours: 8)),
    ));
  }

  // Sort ascending by date
  result.sort((a, b) => a.date.compareTo(b.date));
  return result;
}
