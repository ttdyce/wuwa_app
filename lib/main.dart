import 'dart:convert';
import 'dart:io';

import 'package:jaspr/server.dart';

import 'models/article.dart';
import 'pages/home.dart';
import 'pages/article_page.dart';
import 'pages/calc_page.dart';

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
  await _writePage('index.html', homeResponse.body);
  print('Generated: index.html');

  // Render individual article pages
  for (final article in articles) {
    final articleApp = Document(
      title: '${article.title} — wuwa.app',
      styles: [StyleRule.import('style.css')],
      body: ArticlePage(article: article),
    );
    final response = await renderComponent(articleApp);
    await _writePage('article/${article.id}.html', response.body);
  }
  print('Generated ${articles.length} article pages');

  // Render calculator page
  final calcApp = Document(
    title: '抽卡計算器 — wuwa.app',
    styles: [StyleRule.import('../style.css')],
    body: const CalcPage(),
  );
  final calcResponse = await renderComponent(calcApp);
  await _writePage('calc/index.html', calcResponse.body);
  print('Generated: calc/index.html');

  // Copy static assets
  await _copyAssets();

  print('SSG build complete!');
}

Future<void> _writePage(String path, String html) async {
  final file = File('build/$path');
  await file.parent.create(recursive: true);
  await file.writeAsString(html);
}

Future<void> _copyAssets() async {
  final cssFile = File('web/style.css');
  if (await cssFile.exists()) {
    final dest = File('build/style.css');
    await dest.parent.create(recursive: true);
    await cssFile.copy(dest.path);
  }
}
