include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// --- コネクタの固定寸法 ---
flange_size = 21.0;
flange_thickness = 1.5;
center_hole_dia = 15.3;
mounting_hole_square_size = 16.0;
tolerance = 0.2; // 勘合のきつさを調整する公差

// PRC03-21A10-7F用の切り欠き形状を生成するモジュール
// ここでは Z=0 を「壁の裏面」とみなし、-Z 方向に食い込む切り欠きを作る
// thickness は切り欠きを作る壁の厚み
module connector_cutout(thickness, anchor = BOTTOM, spin = 0, orient = UP) {
  assert(thickness > flange_thickness + tolerance, str("thickness must be greater than ", flange_thickness + tolerance));

  attachable(anchor, spin, orient, size=connector_cutout_size(thickness)) {
    up(thickness / 2)
      // 1. フランジ用の四角い窪み（壁表面から奥へ）
      cuboid(
        [flange_size + tolerance, flange_size + tolerance, flange_thickness + tolerance],
        rounding=2,
        edges=["Z"],
        anchor=TOP
      )
        position(BOTTOM) {
          // 2. コネクタ本体が通る中央の丸穴（余裕をみて十分な長さ）
          cylinder(d=center_hole_dia + tolerance, h=thickness - flange_thickness - tolerance, anchor=TOP);
          grid_copies(spacing=mounting_hole_square_size, n=[2, 2])
            screw_hole("M2.6", thread=true, l=thickness - flange_thickness - tolerance, anchor=TOP);
        }
    children();
  }
}

function connector_cutout_size(thickness) = [flange_size + tolerance, flange_size + tolerance, thickness];
