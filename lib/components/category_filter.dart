import 'package:jaspr/server.dart';

class CategoryFilter extends StatelessComponent {
  const CategoryFilter({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'category-filter', [
      button(
        classes: 'filter-btn active',
        attributes: {'data-filter': 'all', 'onclick': 'setFilter(this)'},
        [span([text('全部')])],
      ),
      button(
        classes: 'filter-btn',
        attributes: {'data-filter': '公告', 'onclick': 'setFilter(this)'},
        [span([text('公告')])],
      ),
      button(
        classes: 'filter-btn',
        attributes: {'data-filter': '活動', 'onclick': 'setFilter(this)'},
        [span([text('活動')])],
      ),
    ]);
  }
}
