// ModbusボードのPCB穴配置テスト

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/walls.scad>
include <wjek254.scad>

// --- Design Parameters ---

// --- PCB Specifications ---
pcb_width = 100; // PCB width (mm)
pcb_depth = 100; // PCB depth (mm)
pcb_thickness = 1.5; // PCB thickness (mm)
pcb_component_height = 18; // Maximum component height above PCB (mm)
pcb_clearance = 3; // Clearance below PCB (mm)
pcb_hole_x_spacing = 85 + 0.25; // Center-to-center X distance (mm)
pcb_hole_y_spacing = 92 + 0.5; // Center-to-center Y distance (mm)
pcb_hole_diameter = 3; // Mounting hole diameter (mm)

module pcb_mounting_post(show_board = false, anchor = BOTTOM, spin = 0, orient = UP) {
  board_size = [pcb_width, pcb_depth, show_board ? pcb_thickness : 0];

  attachable(anchor, spin, orient, size=board_size) {
    down(board_size.z / 2)
      cuboid(size=board_size, anchor=BOTTOM) {
        if (!show_board) {
          position(TOP)
            grid_copies(spacing=[pcb_hole_x_spacing, pcb_hole_y_spacing], n=[2, 2]) children();
        } else {
          // HX710 x6
          position(TOP + LEFT + FRONT)
            right(3.8) back(8)
                line_copies([0, terminal_block_width(5) + 0.1 + 1], n=6, p1=[0, 0, 0]) wjek254_terminal_block(5, anchor=BOTTOM + BACK + LEFT, spin=90);


          // HX711 x2 + ADS1115 x2
          position(TOP + RIGHT + FRONT)
            left(3.8) back(8)
                wjek254_terminal_block(5, anchor=BOTTOM + FRONT + LEFT, spin=90)
                  position(RIGHT)
                    right(1)
                      wjek254_terminal_block(5, anchor=LEFT)
                        right(2)
                          position(RIGHT) wjek254_terminal_block(8, anchor=LEFT)
                              right(1)
                                position(RIGHT) wjek254_terminal_block(8, anchor=LEFT);


          // GP8403 x4
          position(TOP + BACK + RIGHT)
            fwd(3.8) left(15)
                line_copies(-(terminal_block_width(4) + 0.1 + 1), n=4, p1=[0, 0, 0]) wjek254_terminal_block(4, anchor=BOTTOM + BACK + RIGHT);


          // Raspberry Pi Pico
          position(TOP + FRONT) back(2.5) cuboid([21, 51, 16], anchor=BOTTOM + FRONT);
        }
      }
    if (show_board) {
      children();
    } else {
      union(){} // dummy element
    }
  }
}
