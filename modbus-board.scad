include <BOSL2/std.scad>
include <pcb.scad>

render()
  diff() {
    pcb_mounting_post(show_board=true)
      position(TOP) tag("remove") pcb_mounting_post() cyl(h=1.5, d=3, anchor=TOP);
  }
