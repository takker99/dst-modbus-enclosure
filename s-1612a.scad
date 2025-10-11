include <BOSL2/std.scad>
include <BOSL2/screws.scad>

// --- コネクタの固定寸法 ---
flange_size = 21.0;
connector_outer_width = 30;
connector_outer_depth = 10;
connector_outer_height = 8;
connector_inner_width = 18;
connector_inner_depth = 8;
connector_inner_height = 5.5;
hole_spacing = 24;
flange_thickness = 1.5;
center_hole_dia = 15.3;
mounting_hole_square_size = 16.0;
tolerance = 0.2; // 勘合のきつさを調整する公差

module s_1612a_cutout(thickness, anchor = BOTTOM, spin = 0, orient = UP) {
  inner_thickness = max(thickness, connector_inner_height + tolerance);

  outer_size = [connector_outer_width + tolerance, connector_outer_depth + tolerance, connector_outer_height + tolerance];
  attachable(anchor, spin, orient, size=outer_size) {
    up(outer_size.z / 2)
      // 1. フランジ用の四角い窪み（壁表面から奥へ）
      cuboid(outer_size, rounding=2, edges=["Z"], anchor=TOP)
        position(BOTTOM) {
          cuboid(
            [connector_inner_width + tolerance, connector_inner_depth + tolerance, inner_thickness],
            rounding=0.5,
            edges=["Z"],
            anchor=TOP
          );
          grid_copies(spacing=hole_spacing, n=[2, 1])
            screw_hole("M2.6", thread=true, l=inner_thickness, anchor=TOP);
        }
    children();
  }
}

function s_1612a_cutout_size(thickness) = [connector_outer_width + tolerance, connector_outer_depth + tolerance, connector_outer_height + tolerance + max(thickness, connector_inner_height + tolerance)];
