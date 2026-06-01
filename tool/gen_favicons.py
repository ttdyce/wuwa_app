#!/usr/bin/env python3
"""Generate favicon PNGs and ICO for wuwa_app."""
from PIL import Image, ImageDraw

def create_favicon(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    r = int(size * 0.22)
    draw.rounded_rectangle([0, 0, size-1, size-1], radius=r, fill=(10, 14, 26))
    gold_top = (232, 200, 90)
    gold_bot = (138, 112, 48)
    pad = size * 0.16
    w_top = size * 0.34
    w_bot = size * 0.72
    mid_y = size * 0.52
    pts = [
        (pad, w_bot), (size*0.30, w_top), (size*0.42, mid_y),
        (size*0.58, mid_y), (size*0.70, w_top), (size-pad, w_bot)
    ]
    lw = max(2, int(size * 0.07))
    for i in range(len(pts)-1):
        x1, y1 = pts[i]
        x2, y2 = pts[i+1]
        t = (y1 + y2) / (2 * size)
        c = tuple(int(gold_top[j]*(1-t) + gold_bot[j]*t) for j in range(3))
        draw.line([x1, y1, x2, y2], fill=c + (255,), width=lw)
    draw.ellipse([int(size*0.78), int(size*0.16), int(size*0.88), int(size*0.26)], fill=(232, 200, 90, 180))
    draw.ellipse([int(size*0.70), int(size*0.10), int(size*0.77), int(size*0.17)], fill=(201, 168, 76, 100))
    return img

import os
out = 'web'
os.makedirs(out, exist_ok=True)

for s in [16, 32, 48, 64, 128, 180, 192, 512]:
    create_favicon(s).save(f'{out}/favicon-{s}.png')

imgs = [create_favicon(s) for s in [16, 32, 48]]
imgs[0].save(f'{out}/favicon.ico', format='ICO',
             sizes=[(16,16), (32,32), (48,48)], append_images=imgs[1:])

print(f'Generated favicon-*.png and favicon.ico in {out}/')
