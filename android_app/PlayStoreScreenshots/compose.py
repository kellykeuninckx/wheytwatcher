#!/usr/bin/env python3
"""Composeer Android Play Store screenshots: teal->mint gradient + bold witte
tagline + afgeronde 'phone frame', zelfde stijl als de iOS marketing shots."""
from PIL import Image, ImageDraw, ImageFont
import os

SP = "/private/tmp/claude-501/-Users-kellykeuninckx/763d9775-f135-4409-ab0c-a33442ab47c1/scratchpad"

TEAL = (0, 140, 153)
MINT = (89, 230, 191)
FONT_PATH = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"

SHOTS = [
    ("shot_today_final.png", None, "In een oogopslag zie je hoe de vork aan de steel zit", "01_vandaag.png"),
    ("shot_progress_v3.png", None, "Houd in de gaten of je op het juiste spoor zit. Vergeet je kwarkteller niet te checken ;-)", "02_progressie.png"),
    ("shot_logboek_final.png", None, "Per dag inzicht in wat je hebt gelogd. Wel zo makkelijk.", "03_logboek.png"),
    ("shot_copy_product.png", None, "Eet jij vaak hetzelfde? Dan is dit the place to be.", "04_kopieer.png"),
    ("shot_premium.png", 1180, "Voor de prijs van een eiwitreep, voor altijd gratis toegang tot alles!", "05_premium.png"),
    ("shot_progress_v2.png", None, "Verdien badges met kwark eten. Wie wil dat nou niet?", "06_badges.png"),
]

SIDE_MARGIN = 70
TOP_MARGIN = 90
GAP = 55
BEZEL = 18
BOTTOM_MARGIN = 70
CORNER_RADIUS = 48
MAX_FONT = 62
MIN_FONT = 38
MAX_LINES = 3


def vertical_gradient(w, h, top_color, bottom_color):
    base = Image.new("RGB", (1, h), 0)
    for y in range(h):
        t = y / max(h - 1, 1)
        r = round(top_color[0] + (bottom_color[0] - top_color[0]) * t)
        g = round(top_color[1] + (bottom_color[1] - top_color[1]) * t)
        b = round(top_color[2] + (bottom_color[2] - top_color[2]) * t)
        base.putpixel((0, y), (r, g, b))
    return base.resize((w, h))


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([(0, 0), (size[0] - 1, size[1] - 1)], radius=radius, fill=255)
    return mask


def wrap_text(draw, text, font, max_width):
    words = text.split()
    lines, cur = [], ""
    for w in words:
        trial = (cur + " " + w).strip()
        if draw.textlength(trial, font=font) <= max_width:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


EDGE_TRIM = 5  # verwijdert het dunne lime debug-randje in de ruwe emulator-screenshots


def compose(shot_file, crop_h, tagline, out_file):
    img = Image.open(os.path.join(SP, shot_file)).convert("RGB")
    img = img.crop((EDGE_TRIM, EDGE_TRIM, img.width - EDGE_TRIM, img.height - EDGE_TRIM))
    if crop_h:
        img = img.crop((0, 0, img.width, crop_h - EDGE_TRIM))
    w, h = img.size

    canvas_w = w + 2 * SIDE_MARGIN

    # Tagline (bold white, wraps to fit, shrinks font until it fits MAX_LINES)
    probe = ImageDraw.Draw(Image.new("RGB", (1, 1)))
    max_text_w = canvas_w - 2 * SIDE_MARGIN
    font_size = MAX_FONT
    font = ImageFont.truetype(FONT_PATH, font_size)
    lines = wrap_text(probe, tagline, font, max_text_w)
    while len(lines) > MAX_LINES and font_size > MIN_FONT:
        font_size -= 2
        font = ImageFont.truetype(FONT_PATH, font_size)
        lines = wrap_text(probe, tagline, font, max_text_w)

    line_h = font.getbbox("Ag")[3] - font.getbbox("Ag")[1] + 16
    total_text_h = line_h * len(lines)

    canvas_h = TOP_MARGIN + total_text_h + GAP + h + 2 * BEZEL + BOTTOM_MARGIN
    canvas = vertical_gradient(canvas_w, canvas_h, TEAL, MINT)
    draw = ImageDraw.Draw(canvas)

    text_y = TOP_MARGIN
    for line in lines:
        tw = draw.textlength(line, font=font)
        tx = (canvas_w - tw) / 2
        # subtle shadow for legibility
        draw.text((tx + 2, text_y + 2), line, font=font, fill=(0, 60, 65))
        draw.text((tx, text_y), line, font=font, fill=(255, 255, 255))
        text_y += line_h

    # Phone frame: black rounded rect (bezel) behind the screenshot
    frame_top = TOP_MARGIN + total_text_h + GAP
    frame_box = (SIDE_MARGIN, frame_top, SIDE_MARGIN + w + 2 * BEZEL, frame_top + h + 2 * BEZEL)
    draw.rounded_rectangle(frame_box, radius=CORNER_RADIUS + BEZEL, fill=(10, 14, 18))

    # Rounded screenshot pasted on top
    mask = rounded_mask((w, h), CORNER_RADIUS)
    canvas.paste(img, (SIDE_MARGIN + BEZEL, frame_top + BEZEL), mask)

    canvas.save(os.path.join(SP, out_file))
    print(f"{out_file}: {canvas_w}x{canvas_h}")


for shot_file, crop_h, tagline, out_file in SHOTS:
    compose(shot_file, crop_h, tagline, out_file)
