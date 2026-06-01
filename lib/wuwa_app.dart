import 'package:jaspr/jaspr.dart';
import 'pages/home.dart';
import 'models/article.dart';

class WuwaApp extends StatelessComponent {
  const WuwaApp({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final articles = <Article>[];
    yield HomePage(articles: articles);
  }
}
