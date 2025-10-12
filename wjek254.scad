include <BOSL2/std.scad>

// WJ EK254シリーズ端子台モデルを模したもの
// cf. https://www.china-wj.com/En/product_detail/id/141.html
// パーツの干渉防止確認用
module wjek254_terminal_block(pin_count, anchor = BOTTOM, spin = 0, orient = UP) {

  width = terminal_block_width(pin_count);
  depth = 6.2;
  height = 8.5;
  tolerance = 0.1;

  attachable(anchor, spin, orient, size=[width + tolerance, depth + tolerance, height + tolerance]) {
    down((height + tolerance) / 2)
      // 1. フランジ用の四角い窪み（壁表面から奥へ）
      cuboid([width + tolerance, depth + tolerance, 5.1], anchor=BOTTOM)
        position(TOP) prismoid(size1=[width + tolerance, depth + tolerance], size2=[width + tolerance, 2.8 + tolerance], h=height - 5.1 + tolerance);
    children();
  }
}

function terminal_block_width(pin_count) = 2.54 * (pin_count - 1) + 3;
