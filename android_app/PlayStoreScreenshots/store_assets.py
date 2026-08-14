#!/usr/bin/env python3
"""Play Console store-assets: 512x512 hi-res icon + 1024x500 feature graphic,
gebouwd uit de bestaande app_icon.png (zelfde diagonale teal->mint gradient)."""
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

SRC = "/Users/kellykeuninckx/Downloads/Wheyt Watcher/android_app/assets/icon/app_icon.png"
OUT_DIR = "/Users/kellykeuninckx/Downloads/Wheyt Watcher/android_app/PlayStoreScreenshots"
FONT_BOLD = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"

TEAL = (0, 140, 153)
MINT = (89, 230, 191)

# ---------- 1. Hi-res icon: 512x512, 32-bit PNG met alphakanaal ----------
icon = Image.open(SRC).convert("RGBA")
icon = icon.resize((512, 512), Image.LANCZOS)
icon.save(os.path.join(OUT_DIR, "icon_512.png"))
print("icon_512.png:", icon.size, icon.mode)

# ---------- 2. Feature graphic: 1024x500, diagonale gradient ----------
W, H = 1024, 500


def diagonal_gradient(w, h, c1, c2):
    base = Image.new("RGB", (w, h))
    px = base.load()
    max_d = (w - 1) + (h - 1)
    for y in range(h):
        for x in range(w):
            t = (x + y) / max_d
            r = round(c1[0] + (c2[0] - c1[0]) * t)
            g = round(c1[1] + (c2[1] - c1[1]) * t)
            b = round(c1[2] + (c2[2] - c1[2]) * t)
            px[x, y] = (r, g, b)
    return base


canvas = diagonal_gradient(W, H, TEAL, MINT)
draw = ImageDraw.Draw(canvas)

# Icoon links, verticaal gecentreerd, als afgeronde tegel met zachte schaduw
# (i.p.v. los plakken -- de eigen gradient-achtergrond van het icoon matcht
# anders niet naadloos met de banner-gradient en geeft een zichtbare naad).
icon_size = 300
radius = 64
icon_small = Image.open(SRC).convert("RGBA").resize((icon_size, icon_size), Image.LANCZOS)
mask = Image.new("L", (icon_size, icon_size), 0)
ImageDraw.Draw(mask).rounded_rectangle([(0, 0), (icon_size - 1, icon_size - 1)], radius=radius, fill=255)
icon_small.putalpha(mask)

icon_x, icon_y = 70, (H - icon_size) // 2

shadow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
shadow_mask = Image.new("L", (icon_size, icon_size), 0)
ImageDraw.Draw(shadow_mask).rounded_rectangle([(0, 0), (icon_size - 1, icon_size - 1)], radius=radius, fill=110)
shadow.paste((0, 30, 30, 255), (icon_x + 10, icon_y + 16), shadow_mask)
shadow = shadow.filter(ImageFilter.GaussianBlur(18))
canvas.paste(shadow, (0, 0), shadow)
canvas.paste(icon_small, (icon_x, icon_y), icon_small)

# Tekst rechts van het icoon
text_x = icon_x + icon_size + 55
right_margin = 50
available_w = W - text_x - right_margin

title = "Whey, mate!"
subtitle = "TRACK YOUR MACROS · GUARD YOUR GAINS"

title_font = ImageFont.truetype(FONT_BOLD, 88)
title_bbox = draw.textbbox((0, 0), title, font=title_font)
while title_bbox[2] - title_bbox[0] > available_w and title_font.size > 40:
    title_font = ImageFont.truetype(FONT_BOLD, title_font.size - 2)
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
title_h = title_bbox[3] - title_bbox[1]

# subtitel: kies letter-spacing + fontgrootte die binnen available_w past
sub_font_size, tracking = 30, 3
sub_font = ImageFont.truetype(FONT_BOLD, sub_font_size)


def tracked_width(text, font, tracking):
    return sum(draw.textlength(ch, font=font) + tracking for ch in text) - tracking


sub_w = tracked_width(subtitle, sub_font, tracking)
while sub_w > available_w and sub_font_size > 16:
    sub_font_size -= 1
    tracking = max(1, tracking - 0.1)
    sub_font = ImageFont.truetype(FONT_BOLD, sub_font_size)
    sub_w = tracked_width(subtitle, sub_font, tracking)

sub_bbox = draw.textbbox((0, 0), subtitle, font=sub_font)
sub_h = sub_bbox[3] - sub_bbox[1]

gap = 22
block_h = title_h + gap + sub_h
title_y = (H - block_h) // 2 - title_bbox[1]
sub_y = title_y + title_h + gap - sub_bbox[1]

# subtiele schaduw voor leesbaarheid
draw.text((text_x + 2, title_y + 2), title, font=title_font, fill=(0, 55, 60))
draw.text((text_x, title_y), title, font=title_font, fill=(255, 255, 255))

sx = text_x
for ch in subtitle:
    draw.text((sx, sub_y), ch, font=sub_font, fill=(255, 255, 255))
    sx += draw.textlength(ch, font=sub_font) + tracking

canvas = canvas.convert("RGB")  # feature graphic: 24-bit, geen alpha
canvas.save(os.path.join(OUT_DIR, "feature_graphic.png"))
print("feature_graphic.png:", canvas.size, canvas.mode)
