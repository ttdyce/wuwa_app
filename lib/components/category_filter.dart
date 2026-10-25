import 'package:jaspr/server.dart';

class CategoryFilter extends StatelessComponent {
  const CategoryFilter({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'category-filter', attributes: {
      'role': 'group',
      'aria-label': '情報分類'
    }, [
      button(
        classes: 'filter-btn active',
        attributes: {
          'type': 'button',
          'data-filter': 'all',
          'onclick': 'setFilter(this)',
          'aria-pressed': 'true'
        },
        [
          span([text('全部')])
        ],
      ),
      button(
        classes: 'filter-btn',
        attributes: {
          'type': 'button',
          'data-filter': '公告',
          'onclick': 'setFilter(this)',
          'aria-pressed': 'false'
        },
        [
          span([text('公告')])
        ],
      ),
      button(
        classes: 'filter-btn',
        attributes: {
          'type': 'button',
          'data-filter': '活動',
          'onclick': 'setFilter(this)',
          'aria-pressed': 'false'
        },
        [
          span([text('活動')])
        ],
      ),
    ]);
  }
}
