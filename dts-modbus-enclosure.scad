include <gridfinity_block.scad>
include <BOSL2/std.scad>
include <prc03-21a10-7f_cutout.scad>
include <pcb.scad>
include <s-1612a.scad>

$fa = 4;
$fs = 0.25;

//Test sample 1

connector_spacing = connector_cutout_size(3).x + 5;
wall_thickness = 0.95;
connector_thickness = 3;

render()
  diff()
    gridfinity_block([3, 3, 5], stacking_lip=true, wall_thickness=wall_thickness) {
      back(connector_spacing)
        attach(RIGHT, TOP, inside=true) tag("remove")
            grid_copies(spacing=connector_spacing, n=[2, 1]) connector_cutout(thickness=connector_thickness);
      attach(LEFT, TOP, inside=true) tag("remove")
          grid_copies(spacing=connector_spacing, n=[4, 1]) connector_cutout(thickness=connector_thickness);
      right(connector_spacing)
        attach(BACK, TOP, inside=true) tag("remove")
            grid_copies(spacing=connector_spacing, n=[2, 1]) connector_cutout(thickness=connector_thickness);
      attach_part("inside") {
        position(BOTTOM + FRONT) {
          back(2) color("red") hide_this() cuboid([100, 100, 0], rounding=2, edges=["Z"], anchor=BOTTOM + FRONT)
                  position(TOP)
                    pcb_mounting_post(5);
        }
        position(BOTTOM + LEFT) cuboid([connector_thickness - wall_thickness, 42 * 3 - 2, 28], anchor=LEFT + BOTTOM);
      }
    }