import 'package:jaspr/jaspr.dart';
import 'pages/home.dart';
import 'models/article.dart';
import 'components/patch_timeline.dart';

class WuwaApp extends StatelessComponent {
  final List<Article> articles;
  final DateTime buildTime;
  final List<PatchInfo> patches;

  const WuwaApp({
    super.key,
    required this.articles,
    required this.buildTime,
    required this.patches,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield HomePage(articles: articles, buildTime: buildTime, patches: patches);
  }
}
