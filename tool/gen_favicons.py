#!/usr/bin/env python3
"""Generate favicon PNGs and ICO from the site's SVG waveform mark."""
from pathlib import Path
from xml.etree import ElementTree

from PIL import Image, ImageDraw


def create_favicon(size):
    svg = ElementTree.parse('web/favicon.svg').getroot()
    namespace = '{http://www.w3.org/2000/svg}'
    background = svg.find(f'{namespace}rect')
    lines = svg.findall(f'{namespace}polyline')
    assert background is not None and lines, 'Expected a background and waveform polylines'
    assert all(node.tag in (f'{namespace}rect', f'{namespace}polyline') for node in svg), \
        'The favicon renderer supports only rectangles and polylines'
    scale = size * 4 / float(svg.attrib['viewBox'].split()[2])
    image = Image.new('RGBA', (size * 4, size * 4), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(
        [0, 0, image.width - 1, image.height - 1],
        radius=float(background.attrib['rx']) * scale,
        fill=background.attrib['fill'],
    )
    for line in lines:
        points = [tuple(float(value) * scale for value in point.split(','))
                  for point in line.attrib['points'].split()]
        draw.line(points, fill=line.attrib['stroke'],
                  width=round(float(line.attrib['stroke-width']) * scale))
    return image.resize((size, size), Image.Resampling.LANCZOS)


out = Path('web')
for size in [16, 32, 48, 64, 128, 180, 192, 512]:
    create_favicon(size).save(out / f'favicon-{size}.png')

create_favicon(512).save(
    out / 'favicon.ico', format='ICO', sizes=[(16, 16), (32, 32), (48, 48)],
)
with Image.open(out / 'favicon.ico') as icon:
    assert icon.ico.sizes() == {(16, 16), (32, 32), (48, 48)}, 'Missing ICO sizes'

print(f'Generated waveform favicon PNGs and ICO in {out}/')
