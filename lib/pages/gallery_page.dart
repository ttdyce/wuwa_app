import 'package:jaspr/server.dart';
import '../components/header.dart';
import '../components/particles.dart';

/// A single infographic entry in the gallery.
class Infographic {
  final String src;
  final String title;
  final String date;

  const Infographic({
    required this.src,
    required this.title,
    required this.date,
  });
}

/// All infographics shown on the gallery page.
/// Add new images to web/img/infographics/ and register them here.
const _infographics = [
  Infographic(
    src: '/img/infographics/v33-schedule-timeline.jpg',
    title: 'v3.3 活動時間線',
    date: '2026-05',
  ),
];

class GalleryPage extends StatelessComponent {
  const GalleryPage({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div(classes: 'app', [
      const Particles(),
      const Header(),
      main_(classes: 'container', [
        // Page header
        div(classes: 'gallery-header', [
          h1(classes: 'gallery-title', [text('一圖流')]),
          p(classes: 'gallery-subtitle', [
            text('一張圖看懂最新資訊 — Dense info at a glance'),
          ]),
        ]),
        // Image grid
        div(classes: 'gallery-grid', [
          for (final info in _infographics)
            _galleryCard(info),
        ]),
      ]),
      footer(classes: 'footer', [
        span([text('© 2026 wuwa.app — Not affiliated with Kuro Games')]),
      ]),
      // Lightbox overlay (hidden by default)
      div(
        id: 'gallery-lightbox',
        classes: 'lightbox-overlay',
        attributes: {'aria-hidden': 'true'},
        [],
      ),
      // Lightbox script
      raw('''<script>
(function() {
  const overlay = document.getElementById('gallery-lightbox');
  if (!overlay) return;

  // Build lightbox inner HTML once
  overlay.innerHTML =
    '<div class="lightbox-backdrop"></div>' +
    '<div class="lightbox-content">' +
      '<button class="lightbox-close" aria-label="Close">&times;</button>' +
      '<img class="lightbox-img" src="" alt="">' +
      '<div class="lightbox-caption"></div>' +
    '</div>';

  const backdrop = overlay.querySelector('.lightbox-backdrop');
  const img = overlay.querySelector('.lightbox-img');
  const caption = overlay.querySelector('.lightbox-caption');
  const closeBtn = overlay.querySelector('.lightbox-close');

  function openLightbox(src, title, date) {
    img.src = src;
    img.alt = title;
    caption.textContent = title + ' — ' + date;
    overlay.classList.add('active');
    overlay.setAttribute('aria-hidden', 'false');
    document.body.style.overflow = 'hidden';
  }

  function closeLightbox() {
    overlay.classList.remove('active');
    overlay.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';
    // Clear image after transition to free memory
    setTimeout(function() { img.src = ''; }, 300);
  }

  // Click on gallery cards → open lightbox
  document.querySelectorAll('.gallery-card').forEach(function(card) {
    card.style.cursor = 'pointer';
    card.addEventListener('click', function(e) {
      e.preventDefault();
      var imgEl = card.querySelector('.gallery-img');
      if (!imgEl) return;
      var titleEl = card.querySelector('.gallery-card-title');
      var dateEl = card.querySelector('.gallery-card-date');
      openLightbox(
        imgEl.getAttribute('src'),
        titleEl ? titleEl.textContent : '',
        dateEl ? dateEl.textContent : ''
      );
    });
  });

  // Close on backdrop click
  backdrop.addEventListener('click', closeLightbox);

  // Close button
  closeBtn.addEventListener('click', function(e) {
    e.stopPropagation();
    closeLightbox();
  });

  // Close on Escape key
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && overlay.classList.contains('active')) {
      closeLightbox();
    }
  });
})();
</script>'''),
    ]);
  }

  Component _galleryCard(Infographic info) {
    return div(classes: 'gallery-card', [
      // Image (no <a> wrapper — click is handled by JS lightbox)
      div(classes: 'gallery-img-wrapper', [
        img(
          src: info.src,
          alt: info.title,
          classes: 'gallery-img',
          attributes: {
            'loading': 'lazy',
          },
        ),
      ]),
      div(classes: 'gallery-card-info', [
        span(classes: 'gallery-card-title', [text(info.title)]),
        span(classes: 'gallery-card-date', [text(info.date)]),
      ]),
    ]);
  }
}
