#!/usr/bin/env python3
"""Draws the city map behind the Kitway landing page.

Writes Theme/images/map-light.svg and map-dark.svg: one 1600 x 2400 city with a river and its bridges,
avenues, quarters of small streets at their own angles, parks and squares. The tile repeats without a
seam: every avenue and the river leave one edge where they enter the opposite one. Colours come from the
app's map scene tokens, lightened so the page's text keeps WCAG AA on every surface of the map.

Usage: scripts/make-map.py [seed]   (the same seed draws the same map)
"""
import math
import random
import sys
from pathlib import Path

W, H = 1600, 2400

THEMES = {
    "light": {
        "land": "#EFE8DD", "casing": "#E9E0D3", "avenue": "#FAF6EF", "street": "#F6F0E7",
        "park": "#E2EADD", "park_path": "#EDF1E8", "water": "#D8E7E9", "bank": "#D6E4E7", "square": "#F3ECE1",
    },
    "dark": {
        "land": "#221E1B", "casing": "#1B1815", "avenue": "#2C2723", "street": "#282320",
        "park": "#202722", "park_path": "#252C27", "water": "#1C272A", "bank": "#1A2326", "square": "#29241F",
    },
}


def smooth(points, closed=False):
    """A Catmull-Rom curve through the points, as an SVG path."""
    pts = points + points[:3] if closed else [points[0]] + points + [points[-1]]
    d = f"M{pts[1][0]:.0f} {pts[1][1]:.0f}"
    last = len(pts) - 2 if not closed else len(points) + 1
    for i in range(1, last):
        p0, p1, p2, p3 = pts[i - 1], pts[i], pts[i + 1], pts[i + 2]
        c1 = (p1[0] + (p2[0] - p0[0]) / 6, p1[1] + (p2[1] - p0[1]) / 6)
        c2 = (p2[0] - (p3[0] - p1[0]) / 6, p2[1] - (p3[1] - p1[1]) / 6)
        d += f" C{c1[0]:.0f} {c1[1]:.0f} {c2[0]:.0f} {c2[1]:.0f} {p2[0]:.0f} {p2[1]:.0f}"
    return d + (" Z" if closed else "")


def wobbly_line(rng, start, end, steps, amplitude):
    """Points from start to end with a gentle sideways wander; the ends stay exact for the seam."""
    (x0, y0), (x1, y1) = start, end
    length = math.hypot(x1 - x0, y1 - y0)
    nx, ny = -(y1 - y0) / length, (x1 - x0) / length
    phase = rng.uniform(0, math.tau)
    points = []
    for i in range(steps + 1):
        t = i / steps
        bend = math.sin(t * math.pi) * math.sin(t * math.pi * 2 + phase) * amplitude
        points.append((x0 + (x1 - x0) * t + nx * bend, y0 + (y1 - y0) * t + ny * bend))
    return points


def blob(rng, cx, cy, r, lumps=9):
    points = []
    for i in range(lumps):
        a = i / lumps * math.tau
        rr = r * rng.uniform(0.75, 1.15)
        points.append((cx + math.cos(a) * rr * 1.25, cy + math.sin(a) * rr))
    return smooth(points, closed=True)


def draw(seed):
    rng = random.Random(seed)
    parts = {"defs": [], "parks": [], "quarters": [], "water": [], "avenues": [], "squares": []}

    # The river enters at the top and leaves at the bottom at the same x, so the tile has no seam.
    river_x = 1060
    river = wobbly_line(rng, (river_x, -40), (river_x, H + 40), 10, 260)
    river_d = smooth(river)

    def near_river(x, y, distance):
        return any(math.hypot(x - rx_, y - ry_) < distance for rx_, ry_ in river_samples)

    river_samples = [(x, y) for x, y in river]
    for i in range(len(river) - 1):
        (x0, y0), (x1, y1) = river[i], river[i + 1]
        river_samples += [(x0 + (x1 - x0) * k / 8, y0 + (y1 - y0) * k / 8) for k in range(8)]

    # Quarters: rounded areas of small streets, each grid at its own angle. They do not overlap each
    # other (two grids over each other read as noise) and stay inside the tile, so nothing is cut at a seam.
    quarters = []
    qi = 0
    for _ in range(400):
        if qi == 14:
            break
        rx, ry = rng.uniform(130, 240), rng.uniform(130, 260)
        cx, cy = rng.uniform(rx + 10, W - rx - 10), rng.uniform(ry + 10, H - ry - 10)
        if any(math.hypot(cx - ox, cy - oy) < (max(rx, ry) + max(orx, ory)) * 0.92
               for ox, oy, orx, ory in quarters):
            continue
        quarters.append((cx, cy, rx, ry))
        qi += 1
        angle = rng.uniform(-35, 35)
        gap = rng.choice([46, 54, 62])
        clip = f"q{qi}"
        parts["defs"].append(
            f'<clipPath id="{clip}"><ellipse cx="{cx:.0f}" cy="{cy:.0f}" rx="{rx:.0f}" ry="{ry:.0f}"/></clipPath>')
        lines = []
        span = int(max(rx, ry) * 1.6)
        for k in range(-span, span + 1, gap):
            lines.append(f"M{cx - span:.0f} {cy + k:.0f}H{cx + span:.0f}")
            lines.append(f"M{cx + k:.0f} {cy - span:.0f}V{cy + span:.0f}")
        parts["quarters"].append(
            f'<g clip-path="url(#{clip})"><path transform="rotate({angle:.0f} {cx:.0f} {cy:.0f})" '
            f'd="{"".join(lines)}" class="street"/></g>')

    # Parks with a path through them.
    for _ in range(6):
        r = rng.uniform(70, 130)
        cx, cy = rng.uniform(r * 1.5, W - r * 1.5), rng.uniform(r * 1.3, H - r * 1.3)
        parts["parks"].append(f'<path d="{blob(rng, cx, cy, r)}" class="park"/>')
        a = rng.uniform(0, math.pi)
        parts["parks"].append(
            f'<path d="M{cx - math.cos(a) * r:.0f} {cy - math.sin(a) * r * 0.8:.0f} '
            f'Q{cx + rng.uniform(-30, 30):.0f} {cy + rng.uniform(-30, 30):.0f} '
            f'{cx + math.cos(a) * r:.0f} {cy + math.sin(a) * r * 0.8:.0f}" class="park-path"/>')

    parts["water"].append(f'<path d="{river_d}" class="bank"/><path d="{river_d}" class="water"/>')

    # Avenues: a few across and a few down, each leaving where it enters on the opposite edge.
    avenues = []
    for y in (180, 720, 1300, 1880):
        y += rng.uniform(-40, 40)
        avenues.append(wobbly_line(rng, (-40, y), (W + 40, y), 8, rng.uniform(60, 140)))
    for x in (260, 620, 1380):
        x += rng.uniform(-30, 30)
        avenues.append(wobbly_line(rng, (x, -40), (x, H + 40), 10, rng.uniform(70, 160)))
    # A diagonal boulevard across the middle.
    avenues.append(wobbly_line(rng, (120, 520), (1500, 2060), 8, 90))
    for line in avenues:
        d = smooth(line)
        parts["avenues"].append(f'<path d="{d}" class="casing"/><path d="{d}" class="avenue"/>')

    # Squares on the avenues, never on the river.
    placed = 0
    for _ in range(200):
        if placed == 7:
            break
        line = rng.choice(avenues)
        x, y = line[rng.randrange(2, len(line) - 2)]
        if near_river(x, y, 110) or not (40 < x < W - 40 and 40 < y < H - 40):
            continue
        placed += 1
        parts["squares"].append(f'<circle cx="{x:.0f}" cy="{y:.0f}" r="{rng.uniform(22, 34):.0f}" class="square"/>')
    return parts


def svg(parts, colours):
    style = (
        f".street{{fill:none;stroke:{colours['street']};stroke-width:5}}"
        f".park{{fill:{colours['park']}}}"
        f".park-path{{fill:none;stroke:{colours['park_path']};stroke-width:4;stroke-linecap:round}}"
        f".bank{{fill:none;stroke:{colours['bank']};stroke-width:132;stroke-linecap:round}}"
        f".water{{fill:none;stroke:{colours['water']};stroke-width:120;stroke-linecap:round}}"
        f".casing{{fill:none;stroke:{colours['casing']};stroke-width:20;stroke-linecap:round}}"
        f".avenue{{fill:none;stroke:{colours['avenue']};stroke-width:15;stroke-linecap:round}}"
        f".square{{fill:{colours['square']};stroke:{colours['casing']};stroke-width:3}}"
    )
    body = "".join(parts["quarters"] + parts["parks"] + parts["water"] + parts["avenues"] + parts["squares"])
    return (
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">'
        f'<defs>{"".join(parts["defs"])}<style>{style}</style></defs>'
        f'<rect width="{W}" height="{H}" fill="{colours["land"]}"/>{body}</svg>\n'
    )


def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 110
    parts = draw(seed)
    out = Path(__file__).resolve().parent.parent / "Theme" / "images"
    out.mkdir(parents=True, exist_ok=True)
    for name, colours in THEMES.items():
        path = out / f"map-{name}.svg"
        path.write_text(svg(parts, colours), encoding="utf-8")
        print(f"make-map: {path} ({path.stat().st_size // 1024} KB)")


if __name__ == "__main__":
    main()
