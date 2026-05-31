import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const listApiUrl =
    'https://hw-media-cdn-mingchao.kurogame.com/akiwebsite/website2.0/json/G152/zh-tw/ArticleMenu.json';

String articleApiUrl(int id) =>
    'https://hw-media-cdn-mingchao.kurogame.com/akiwebsite/website2.0/json/G152/zh-tw/article/$id.json';

Future<Map<int, Map<String, dynamic>>> loadExistingArticles() async {
  final file = File('data/articles.json');
  if (!file.existsSync()) return {};

  try {
    final raw = json.decode(await file.readAsString()) as List<dynamic>;
    final map = <int, Map<String, dynamic>>{};
    for (final item in raw) {
      final m = item as Map<String, dynamic>;
      map[m['id'] as int] = m;
    }
    print('Loaded ${map.length} existing articles from cache');
    return map;
  } catch (e) {
    print('WARN: Could not parse existing articles.json, starting fresh: $e');
    return {};
  }
}

Future<void> main() async {
  print('Fetching article list from official API...');
  final response = await http.get(Uri.parse(listApiUrl));

  if (response.statusCode != 200) {
    print('ERROR: Failed to fetch articles (HTTP ${response.statusCode})');
    exit(1);
  }

  final List<dynamic> raw = json.decode(response.body);
  print('Received ${raw.length} articles from list API');

  // Load cached content so we only fetch new/changed articles
  final existing = await loadExistingArticles();

  // First pass: build article list from the list API
  final articles = <Map<String, dynamic>>[];
  final idsToFetch = <int>[];

  for (final json in raw) {
    final id = json['articleId'] as int;
    final title = json['articleTitle'] as String;
    final startTime = json['startTime'] as String;
    final sortingMark = json['sortingMark'] ?? 0;

    final cached = existing[id];
    // Reuse cached content if article exists and metadata unchanged
    final isUnchanged = cached != null &&
        cached['title'] == title &&
        cached['startTime'] == startTime &&
        cached['sortingMark'] == sortingMark &&
        (cached['content'] as String).isNotEmpty;

    if (!isUnchanged) {
      idsToFetch.add(id);
    }

    articles.add({
      'id': id,
      'title': title,
      'content': isUnchanged ? cached!['content'] : '', // filled later
      'articleType': json['articleType'] ?? 90,
      'createTime': json['createTime'],
      'startTime': startTime,
      'sortingMark': sortingMark,
      'isPinned': (json['top'] ?? 0) == 1,
    });
  }

  // Sort: pinned first, then by startTime descending
  articles.sort((a, b) {
    if (a['isPinned'] && !b['isPinned']) return -1;
    if (!a['isPinned'] && b['isPinned']) return 1;
    final dateA = DateTime.parse(a['startTime'] as String);
    final dateB = DateTime.parse(b['startTime'] as String);
    return dateB.compareTo(dateA);
  });

  // Second pass: fetch full content only for new/changed articles
  final cachedCount = articles.length - idsToFetch.length;
  print(
      'Fetching content for ${idsToFetch.length} new/changed articles ($cachedCount cached)...');

  int fetched = 0;
  int failed = 0;

  // Build a lookup for quick content assignment
  final contentMap = <int, String>{};

  for (final id in idsToFetch) {
    try {
      final detailResponse = await http.get(
        Uri.parse(articleApiUrl(id)),
        headers: {'Accept': 'application/json'},
      );

      if (detailResponse.statusCode == 200) {
        final detail = json.decode(detailResponse.body);
        contentMap[id] = detail['articleContent'] ?? '';
        fetched++;
      } else {
        print('  WARN: Failed to fetch article $id (HTTP ${detailResponse.statusCode})');
        failed++;
      }
    } catch (e) {
      print('  WARN: Error fetching article $id: $e');
      failed++;
    }

    // Progress indicator every 50 articles
    if ((fetched + failed) % 50 == 0 && (fetched + failed) > 0) {
      print('  Progress: ${fetched + failed}/${idsToFetch.length} (${fetched} ok, ${failed} failed)');
    }

    // Small delay to be polite to the server
    await Future.delayed(Duration(milliseconds: 50));
  }

  // Apply fetched content back to articles
  for (final article in articles) {
    final id = article['id'] as int;
    if (contentMap.containsKey(id)) {
      article['content'] = contentMap[id];
    }
  }

  print('Content fetch complete: $fetched ok, $failed failed, $cachedCount cached');

  final outputFile = File('data/articles.json');
  await outputFile.parent.create(recursive: true);
  await outputFile.writeAsString(json.encode(articles));

  print('Saved ${articles.length} articles to data/articles.json');
  print('  Pinned: ${articles.where((a) => a['isPinned']).length}');
  print(
      '  Type 90 (公告): ${articles.where((a) => a['articleType'] == 90).length}');
  print(
      '  Type 89 (活動): ${articles.where((a) => a['articleType'] == 89).length}');
}
