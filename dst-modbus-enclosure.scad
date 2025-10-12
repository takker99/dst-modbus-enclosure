include <gridfinity_block.scad>
include <BOSL2/std.scad>
include <prc03-21a10-7f_cutout.scad>
include <pcb.scad>
include <s-1612a.scad>

$fa = 4;
$fs = 0.25;

//Test sample 1

connector_thickness = 10;
connector_spacing = connector_cutout_size(connector_thickness).x + 5;
wall_thickness = 0.95;
support_wall_width = 42 * 3 - 4;
support_wall_height = 27.5;

support_triangle_angle = 15;

debug = false;
connector_flange_height_from_floor = 3 // clearance below pcb
+ 1.5 // pcb thickness
+ 1; // clearance above pcb

connector_flange_offset = 4.75 // gridfinity base height
+ wall_thickness // floor thickness
+ connector_flange_height_from_floor;

support_vertical_length = connector_flange_height_from_floor + connector_cutout_size(connector_thickness).x - 0.6;

// コネクタのつけはずしで壊れにくいように、コネクタのねじ穴に沿って格子状の補強を入れる
module connector_with_support(n) {
  xrot(90) grid_copies(spacing=connector_spacing, n=n)
      connector_cutout(thickness=connector_thickness, anchor=TOP + FRONT)
        tag("") down(wall_thickness) {
            length2 = connector_spacing + 2;
            width1 = 4;
            depth = 3 - wall_thickness;
            width2 = width1 + depth * 2;
            length1 = length2 - depth * 2;
            position(TOP) cuboid([16, 16, depth], anchor=TOP);
            ycopies(16) position(TOP) prismoid(size1=[length1 * 1.1, width1], size2=[length2 * 1.1, width2], h=depth, anchor=TOP);
            xcopies(16) fwd(0.6) position(TOP + BACK) prismoid(size1=[width1, support_vertical_length], size2=[width2, support_vertical_length], h=depth, anchor=TOP + BACK)
                    attach(BOTTOM, BOTTOM) prismoid(size1=[width1, support_vertical_length], size2=[width1, 0], yang=[90, support_triangle_angle]);
          }
}

render()
  diff()
    gridfinity_block([3, 3, 5], stacking_lip=true, wall_thickness=wall_thickness) {
      // コネクタの切り欠き
      tag("remove") {
        up(connector_flange_offset) {
          position(RIGHT + BOTTOM)
            back(connector_spacing)
              zrot(90) connector_with_support(n=[2, 1]);
          position(LEFT + BOTTOM)
            zrot(-90) connector_with_support(n=[4, 1]);
          position(BACK + BOTTOM)
            left(connector_spacing)
              zrot(180) connector_with_support(n=[2, 1]);
        }
        right(connector_spacing) attach(BACK, TOP, inside=true)
            s_1612a_cutout(thickness=4) {
              size = s_1612a_cutout_size(thickness=4);
              attach(TOP, BOTTOM, inside=true) {
                tag("") prismoid(size2=[size.x, size.y] + [1, 1], xang=45, yang=45, h=3, rounding=2);
                tag("") cuboid([size.x, size.y, 8 + 1.7] + [1, 1, 0], rounding=2, edges=["Z"])
                    xcopies(1 + 10, n=3)
                      attach(FRONT, BOTTOM)
                        cuboid([1, 8 + 1.7, 9.5]) up(2) {
                            attach(BOTTOM + LEFT, FRONT + RIGHT) fillet(l=8 + 1.7, r=2);
                            attach(BOTTOM + RIGHT, FRONT + RIGHT) fillet(l=8 + 1.7, r=2);
                          }
              }
            }
      }

      attach_part("inside") {
        position(BOTTOM + FRONT) {
          // PCBの取り付け穴
          back(1) color("red") pcb_mounting_post(anchor=BOTTOM + FRONT)
                cyl(h=3, d=6) position(TOP) cyl(h=5, d=2.8, anchor=BOTTOM);
          // USBケーブル用の切り欠き
          tag("remove") up(1.5 + 3) cuboid([20, wall_thickness, 17], rounding=2, edges=["Y"], anchor=BOTTOM + BACK);

          if (debug) {
            back(1) up(3) pcb_mounting_post(show_board=true, anchor=BOTTOM + FRONT);
          }
        }
      }
    }
