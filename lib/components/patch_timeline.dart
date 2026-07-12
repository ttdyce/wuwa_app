import 'package:jaspr/server.dart';

class PatchInfo {
  final String version;
  final String name;
  final DateTime date;

  PatchInfo({required this.version, required this.name, required this.date});
}

class PatchTimeline extends StatelessComponent {
  final PatchInfo current;
  final PatchInfo? next; // nullable — may not be announced yet
  final double progressPercent; // 0.0 – 1.0
  final String nextDateIso; // ISO date for JS countdown target (empty if no next)

  const PatchTimeline({
    super.key,
    required this.current,
    this.next,
    required this.progressPercent,
    this.nextDateIso = '',
  });

  String _formatDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final hasNext = next != null;

    yield div(classes: 'patch-timeline', [
      // --- label row: version left | countdown center | version right ---
      div(classes: 'patch-labels', [
        div(classes: 'patch-label-left', [
          span(classes: 'patch-version', [text(current.version)]),
          span(classes: 'patch-name', [text(current.name)]),
        ]),
        // Center: countdown or "coming soon"
        if (hasNext && nextDateIso.isNotEmpty)
          div(classes: 'patch-countdown', attributes: {
            'data-target': nextDateIso,
            'id': 'patch-countdown',
          }, [
            text('計算中…'),
          ])
        else
          div(classes: 'patch-countdown patch-next-soon', [
            text('下次更新敬請期待'),
          ]),
        // Right: next version or placeholder
        if (hasNext)
          div(classes: 'patch-label-right', [
            span(classes: 'patch-version', [text(next!.version)]),
            span(classes: 'patch-name', [text(next!.name)]),
          ])
        else
          div(classes: 'patch-label-right patch-next-unknown', [
            span(classes: 'patch-version', [text('???')]),
          ]),
      ]),

      // --- full-width track ---
      div(classes: 'patch-track', attributes: {'id': 'patch-track'}, [
        div([], classes: 'patch-bar', attributes: {
          'id': 'patch-bar',
          'style': 'width: 0%',
        }),
        div([], classes: 'patch-marker', attributes: {
          'id': 'patch-marker',
          'style': 'left: 0%',
        }),
      ]),

      // --- date row ---
      div(classes: 'patch-dates', [
        span([text(_formatDate(current.date))]),
        if (hasNext) span([text(_formatDate(next!.date))]),
      ]),

      // --- countdown JS (only when we have a target) ---
      if (hasNext && nextDateIso.isNotEmpty)
        raw('''<script>
(function() {
  var el = document.getElementById('patch-countdown');
  var bar = document.getElementById('patch-bar');
  var marker = document.getElementById('patch-marker');
  if (!el) return;

  var target = new Date(el.getAttribute('data-target')).getTime();
  if (isNaN(target)) return;

  function pad(n) { return n < 10 ? '0' + n : n; }

  function tick() {
    var now = Date.now();
    var diff = target - now;
    if (diff <= 0) {
      el.textContent = '\\u5df2\\u66f4\\u65b0';
      if (bar) bar.style.width = '100%';
      if (marker) marker.style.left = '100%';
      return;
    }
    var d = Math.floor(diff / 86400000);
    var h = Math.floor((diff % 86400000) / 3600000);
    var m = Math.floor((diff % 3600000) / 60000);
    var s = Math.floor((diff % 60000) / 1000);
    el.textContent = d + '\\u5929 ' + pad(h) + '\\u6642 ' + pad(m) + '\\u5206 ' + pad(s) + '\\u79d2';
  }

  tick();
  setInterval(tick, 1000);
})();
</script>'''),
    ]);
  }
}
