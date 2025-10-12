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

render()
  diff()
    gridfinity_block([3, 3, 5], stacking_lip=true, wall_thickness=wall_thickness) {
      back(connector_spacing)
        position(RIGHT + BOTTOM) tag("remove")
            grid_copies(spacing=connector_spacing, n=[2, 1], axes="yz")
              up(connector_flange_offset)
                zrot(90) xrot(90)
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
      position(LEFT + BOTTOM) tag("remove")
          grid_copies(spacing=connector_spacing, n=[4, 1], axes="yz")
            up(connector_flange_offset)
              zrot(-90) xrot(90)
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
      left(connector_spacing)
        position(BACK + BOTTOM) tag("remove")
            grid_copies(spacing=connector_spacing, n=[2, 1])
              up(connector_flange_offset)
                zrot(180) xrot(90)
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

      right(connector_spacing)
        fwd(wall_thickness) attach(BACK, BOTTOM) tag("remove") s_1612a_cutout(thickness=connector_thickness - wall_thickness)
                tag("") attach(BOTTOM, BOTTOM) {
                    size = s_1612a_cutout_size(thickness=4);
                    prismoid(size2=[size.x, size.y], xang=45, yang=45, h=3 - wall_thickness, rounding=2);
                  }

      attach_part("inside") {
        position(BOTTOM + FRONT) {
          back(1) color("red") pcb_mounting_post(anchor=BOTTOM + FRONT) cyl(h=3, d=6) position(TOP) cyl(h=5, d=2.8, anchor=BOTTOM);
          tag("remove") up(1.5 + 3) cuboid([20, wall_thickness, 17], rounding=2, edges=["Y"], anchor=BOTTOM + BACK);

          if (debug) {
            back(1) up(3) pcb_mounting_post(show_board=true, anchor=BOTTOM + FRONT);
          }
        }
      }
    }
