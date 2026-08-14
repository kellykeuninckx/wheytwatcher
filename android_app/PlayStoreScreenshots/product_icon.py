#!/usr/bin/env python3
"""Producticoon voor de premium_unlock in-app product: 1:1, dezelfde
diagonale teal->mint gradient als het app-icoon, met een oranje ster
(zelfde visuele taal als de ster op het Premium-scherm in de app)."""
import math
from PIL import Image, ImageDraw

OUT = "/Users/kellykeuninckx/Downloads/Wheyt Watcher/android_app/PlayStoreScreenshots/product_icon_premium_unlock.png"

TEAL = (0, 140, 153)
MINT = (89, 230, 191)
ORANGE = (245, 166, 80)  # WwColors.orange
SIZE = 1024


def diagonal_gradient(w, h, c1, c2):
    base = Image.new("RGB", (w, h))
    px = base.load()
    max_d = (w - 1) + (h - 1)
    for y in range(h):
        for x in range(w):
            t = (x + y) / max_d
            px[x, y] = tuple(round(c1[i] + (c2[i] - c1[i]) * t) for i in range(3))
    return base


def star_points(cx, cy, r_outer, r_inner, points=5, rotation=-90):
    pts = []
    for i in range(points * 2):
        r = r_outer if i % 2 == 0 else r_inner
        angle = math.radians(rotation + i * (360 / (points * 2)))
        pts.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    return pts


canvas = diagonal_gradient(SIZE, SIZE, TEAL, MINT).convert("RGBA")
draw = ImageDraw.Draw(canvas)

cx, cy = SIZE / 2, SIZE / 2
pts = star_points(cx, cy, r_outer=330, r_inner=130)
draw.polygon(pts, fill=ORANGE)

canvas.convert("RGB").save(OUT)
print("saved:", OUT, canvas.size)
