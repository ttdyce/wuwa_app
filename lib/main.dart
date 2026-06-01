import 'dart:convert';
import 'dart:io';

import 'package:jaspr/server.dart';

import 'models/article.dart';
import 'pages/home.dart';
import 'pages/article_page.dart';
import 'pages/calc_page.dart';

/// Favicon link tags injected into every HTML <head>
const _faviconTags = '''
    <link rel="icon" type="image/svg+xml" href="/favicon.svg"/>
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32.png"/>
    <link rel="apple-touch-icon" sizes="180x180" href="/favicon-180.png"/>
    <meta name="theme-color" content="#0a0e1a"/>''';

const _faviconTagsIndex = '''
    <link rel="icon" type="image/svg+xml" href="/favicon.svg"/>
    <link rel="icon" type="image/png" sizes="32x32" href="/favicon-32.png"/>
    <link rel="icon" type="image/png" sizes="16x16" href="/favicon-16.png"/>
    <link rel="apple-touch-icon" sizes="180x180" href="/favicon-180.png"/>
    <meta name="theme-color" content="#0a0e1a"/>''';

void main() async {
  Jaspr.initializeApp();

  // Load articles
  final file = File('data/articles.json');
  if (!await file.exists()) {
    print('ERROR: data/articles.json not found. Run: dart run tool/fetch_articles.dart');
    exit(1);
  }

  final jsonStr = await file.readAsString();
  final List<dynamic> jsonList = json.decode(jsonStr);
  final articles = jsonList
      .map((json) => Article.fromJsonStored(json as Map<String, dynamic>))
      .toList();

  print('Loaded ${articles.length} articles for SSG');

  // Create build directory
  final buildDir = Directory('build');
  if (await buildDir.exists()) {
    await buildDir.delete(recursive: true);
  }

  // Render home page
  final homeApp = Document(
    title: 'wuwa.app — Wuthering Waves News',
    styles: [StyleRule.import('style.css')],
    body: HomePage(articles: articles),
  );

  final homeResponse = await renderComponent(homeApp);
  await _writePage('index.html', _injectFavicon(homeResponse.body, index: true));
  print('Generated: index.html');

  // Render individual article pages
  for (final article in articles) {
    final articleApp = Document(
      title: '${article.title} — wuwa.app',
      styles: [StyleRule.import('style.css')],
      body: ArticlePage(article: article),
    );
    final response = await renderComponent(articleApp);
    await _writePage('article/${article.id}.html', _injectFavicon(response.body));
  }
  print('Generated ${articles.length} article pages');

  // Render calculator page
  final calcApp = Document(
    title: '抽卡計算器 — wuwa.app',
    styles: [StyleRule.import('../style.css')],
    body: const CalcPage(),
  );
  final calcResponse = await renderComponent(calcApp);
  await _writePage('calc/index.html', _injectFavicon(calcResponse.body));
  print('Generated: calc/index.html');

  // Copy static assets (CSS, images, favicons)
  await _copyAssets();

  print('SSG build complete!');
}

/// Inject favicon <link> tags into the <head> of rendered HTML
String _injectFavicon(String html, {bool index = false}) {
  final tags = index ? _faviconTagsIndex : _faviconTags;
  return html.replaceFirst(
    '<meta charset="utf-8"/>',
    '<meta charset="utf-8"/>\n$tags',
  );
}

Future<void> _writePage(String path, String html) async {
  final file = File('build/$path');
  await file.parent.create(recursive: true);
  await file.writeAsString(html);
}

Future<void> _copyAssets() async {
  // CSS
  final cssFile = File('web/style.css');
  if (await cssFile.exists()) {
    final dest = File('build/style.css');
    await dest.parent.create(recursive: true);
    await cssFile.copy(dest.path);
  }

  // Astrites image
  final astritesSrc = File('web/img/astrites.png');
  if (await astritesSrc.exists()) {
    final dest = File('build/img/astrites.png');
    await dest.parent.create(recursive: true);
    await astritesSrc.copy(dest.path);
  }

  // Banner image
  final bannerSrc = File('web/img/denia-banner.jpg');
  if (await bannerSrc.exists()) {
    final dest = File('build/img/denia-banner.jpg');
    await dest.parent.create(recursive: true);
    await bannerSrc.copy(dest.path);
  }

  // Favicon files
  final faviconFiles = [
    'web/favicon.svg',
    'web/favicon.ico',
    'web/favicon-16.png',
    'web/favicon-32.png',
    'web/favicon-48.png',
    'web/favicon-64.png',
    'web/favicon-128.png',
    'web/favicon-180.png',
    'web/favicon-192.png',
    'web/favicon-512.png',
  ];
  for (final path in faviconFiles) {
    final src = File(path);
    if (await src.exists()) {
      final dest = File('build/${path.replaceFirst('web/', '')}');
      await dest.parent.create(recursive: true);
      await src.copy(dest.path);
    }
  }
}
