#!/usr/bin/env python3
"""すごろく用：動物盤面画像から20匹の個別画像を切り出す。"""

from __future__ import annotations

from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / 'assets/images/盤面/動物盤面.png'
OUT = ROOT / 'assets/images/動物'
TARGET = 280

ANIMALS = [
    'ぶた', 'たぬき', 'こあら', 'やぎ', 'からす',
    'かば', 'うま', 'こうもり', 'ぱんだ', 'さる',
    'らいおん', 'うさぎ', 'ぞう', 'ごりら', 'うし',
    'ひつじ', 'しまうま', 'いのしし', 'ねこ', 'なまけもの',
]

# 自動検出が難しい個体は盤面上の座標を直接指定
MANUAL_BBOX: dict[str, tuple[int, int, int, int]] = {
    'こあら': (408, 0, 640, 130),
    'やぎ': (608, 0, 714, 130),
    'ぶた': (10, 50, 158, 158),
}
COLS, ROWS = 5, 4
# 列・行の境界（1024x570 盤面に合わせて調整）
COL_SPLITS = [0, 205, 408, 612, 816, 1024]
ROW_SPLITS = [0, 143, 286, 429, 570]


def content_mask(rgb: np.ndarray) -> np.ndarray:
    arr = rgb.astype(np.int16)
    mask = (np.min(arr, axis=2) < 253) | (np.std(arr, axis=2) > 3.5)
    # 薄い色の動物（やぎ・ひつじ・ぶた）
    mask |= (
        (arr[:, :, 0] > 200)
        & (arr[:, :, 1] > 140)
        & (arr[:, :, 2] > 140)
        & (np.min(arr, axis=2) < 254)
    )
    return mask


def tight_bbox(sub: np.ndarray, *, skip_top: int = 0, max_brightness: float | None = None) -> tuple[int, int, int, int] | None:
    mask = content_mask(sub)
    if skip_top:
        mask[:skip_top, :] = False
    if max_brightness is not None:
        bright = sub.astype(np.float32).mean(axis=2) > max_brightness
        mask &= ~bright
    ys, xs = np.where(mask)
    if len(xs) == 0:
        return None
    return xs.min(), ys.min(), xs.max(), ys.max()


def crop_cell(img: Image.Image, col: int, row: int, *, name: str) -> Image.Image:
    if name in MANUAL_BBOX:
        x0, y0, x1, y1 = MANUAL_BBOX[name]
        sub = np.array(img.crop((x0, y0, x1 + 1, y1 + 1)))
        mask = content_mask(sub)
        if name == 'こあら':
            mask[:, max(0, sub.shape[1] - 48) :] = False
        ys, xs = np.where(mask)
        if len(xs) == 0:
            return img.crop((x0, y0, x1 + 1, y1 + 1))
        tx0, ty0, tx1, ty1 = xs.min(), ys.min(), xs.max(), ys.max()
        pad = max(8, int(0.06 * max(tx1 - tx0, ty1 - ty0)))
        return img.crop((
            max(0, x0 + tx0 - pad),
            max(0, y0 + ty0 - pad),
            min(img.width, x0 + tx1 + pad + 1),
            min(img.height, y0 + ty1 + pad + 1),
        ))

    x0, x1 = COL_SPLITS[col] + 4, COL_SPLITS[col + 1] - 4
    y0, y1 = ROW_SPLITS[row], ROW_SPLITS[row + 1] - 2
    sub = np.array(img.crop((x0, y0, x1, y1)))
    mask = content_mask(sub)
    labeled, n = ndimage.label(mask)
    comps: list[tuple[int, int, int, int, int]] = []
    for lab in range(1, n + 1):
        ys, xs = np.where(labeled == lab)
        if len(xs) < 100:
            continue
        # 上の行の足など小さな欠片を除外
        if row > 0 and ys.max() < 28 and len(xs) < 2500:
            continue
        comps.append((len(xs), xs.min(), ys.min(), xs.max(), ys.max()))
    comps.sort(reverse=True)
    if not comps:
        return img.crop((x0, y0, x1, y1))

    pick = comps[:1]
    tx0 = min(c[1] for c in pick)
    ty0 = min(c[2] for c in pick)
    tx1 = max(c[3] for c in pick)
    ty1 = max(c[4] for c in pick)
    pad = max(8, int(0.06 * max(tx1 - tx0, ty1 - ty0)))
    tx0 = max(0, tx0 - pad)
    ty0 = max(0, ty0 - pad)
    tx1 = min(sub.shape[1] - 1, tx1 + pad)
    ty1 = min(sub.shape[0] - 1, ty1 + pad)
    crop = Image.fromarray(sub[ty0 : ty1 + 1, tx0 : tx1 + 1])
    # 絶対座標へ戻して再切り出し（精度向上）
    ax0, ay0 = x0 + tx0, y0 + ty0
    ax1, ay1 = x0 + tx1, y0 + ty1
    return img.crop((ax0, ay0, ax1 + 1, ay1 + 1))


def to_square_jpeg(crop: Image.Image, path: Path) -> None:
    cw, ch = crop.size
    side = max(cw, ch)
    canvas = Image.new('RGB', (side, side), (255, 255, 255))
    canvas.paste(crop, ((side - cw) // 2, (side - ch) // 2))
    canvas.resize((TARGET, TARGET), Image.Resampling.LANCZOS).save(
        path, 'JPEG', quality=92,
    )


def main() -> None:
    img = Image.open(SRC).convert('RGB')
    OUT.mkdir(parents=True, exist_ok=True)
    for idx, name in enumerate(ANIMALS):
        col, row = idx % COLS, idx // COLS
        crop = crop_cell(img, col, row, name=name)
        to_square_jpeg(crop, OUT / f'{name}.jpg')
        print(f'{name}: {crop.size}')


if __name__ == '__main__':
    main()
