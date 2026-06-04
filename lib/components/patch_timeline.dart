import 'package:jaspr/server.dart';

class PatchInfo {
  final String version;
  final String name;
  final DateTime date;

  PatchInfo({required this.version, required this.name, required this.date});
}

class PatchTimeline extends StatelessComponent {
  final PatchInfo current;
  final PatchInfo next;
  final double progressPercent; // 0.0 – 1.0
  final String nextDateIso; // ISO date for JS countdown target

  const PatchTimeline({
    super.key,
    required this.current,
    required this.next,
    required this.progressPercent,
    required this.nextDateIso,
  });

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final pct = (progressPercent * 100).toStringAsFixed(1);

    yield div(classes: 'patch-timeline', [
      // --- label row: version left | countdown center | version right ---
      div(classes: 'patch-labels', [
        div(classes: 'patch-label-left', [
          span(classes: 'patch-version', [text(current.version)]),
          span(classes: 'patch-name', [text(current.name)]),
        ]),
        div(classes: 'patch-countdown', attributes: {
          'data-target': nextDateIso,
          'id': 'patch-countdown',
        }, [
          text('計算中…'),
        ]),
        div(classes: 'patch-label-right', [
          span(classes: 'patch-version', [text(next.version)]),
          span(classes: 'patch-name', [text(next.name)]),
        ]),
      ]),

      // --- full-width track ---
      div(classes: 'patch-track', [
        div([], classes: 'patch-bar', attributes: {
          'style': 'width: $pct%',
        }),
        div([], classes: 'patch-marker', attributes: {
          'style': 'left: $pct%',
        }),
      ]),

      // --- date row ---
      div(classes: 'patch-dates', [
        span([text(_formatDate(current.date))]),
        span([text(_formatDate(next.date))]),
      ]),

      // --- countdown JS ---
      raw('''<script>
(function() {
  var el = document.getElementById('patch-countdown');
  if (!el) return;
  var target = new Date(el.getAttribute('data-target')).getTime();
  if (isNaN(target)) return;

  function pad(n) { return n < 10 ? '0' + n : n; }

  function tick() {
    var now = Date.now();
    var diff = target - now;
    if (diff <= 0) {
      el.textContent = '已更新';
      return;
    }
    var d = Math.floor(diff / 86400000);
    var h = Math.floor((diff % 86400000) / 3600000);
    var m = Math.floor((diff % 3600000) / 60000);
    var s = Math.floor((diff % 60000) / 1000);
    el.textContent = d + '天 ' + pad(h) + '時 ' + pad(m) + '分 ' + pad(s) + '秒';
  }

  tick();
  setInterval(tick, 1000);
})();
</script>'''),
    ]);
  }
}
