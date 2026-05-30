import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const listApiUrl =
    'https://hw-media-cdn-mingchao.kurogame.com/akiwebsite/website2.0/json/G152/zh-tw/ArticleMenu.json';

String articleApiUrl(int id) =>
    'https://hw-media-cdn-mingchao.kurogame.com/akiwebsite/website2.0/json/G152/zh-tw/article/$id.json';

Future<void> main() async {
  print('Fetching article list from official API...');
  final response = await http.get(Uri.parse(listApiUrl));

  if (response.statusCode != 200) {
    print('ERROR: Failed to fetch articles (HTTP ${response.statusCode})');
    exit(1);
  }

  final List<dynamic> raw = json.decode(response.body);
  print('Received ${raw.length} articles from list API');

  // First pass: build article list from the list API
  final articles = <Map<String, dynamic>>[];
  for (final json in raw) {
    articles.add({
      'id': json['articleId'],
      'title': json['articleTitle'],
      'content': '', // Will be filled from detail API
      'articleType': json['articleType'] ?? 90,
      'createTime': json['createTime'],
      'startTime': json['startTime'],
      'sortingMark': json['sortingMark'] ?? 0,
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

  // Second pass: fetch full content for each article
  print('Fetching full content for ${articles.length} articles...');
  int fetched = 0;
  int failed = 0;

  for (final article in articles) {
    final id = article['id'] as int;
    try {
      final detailResponse = await http.get(
        Uri.parse(articleApiUrl(id)),
        headers: {'Accept': 'application/json'},
      );

      if (detailResponse.statusCode == 200) {
        final detail = json.decode(detailResponse.body);
        article['content'] = detail['articleContent'] ?? '';
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
    if ((fetched + failed) % 50 == 0) {
      print('  Progress: ${fetched + failed}/${articles.length} (${fetched} ok, ${failed} failed)');
    }

    // Small delay to be polite to the server
    await Future.delayed(Duration(milliseconds: 50));
  }

  print('Content fetch complete: $fetched ok, $failed failed');

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
