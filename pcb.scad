// ModbusボードのPCB穴配置テスト

include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <BOSL2/walls.scad>

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

// --- PCB Mounting Post Module ---
module post(height) {
  cyl(h=max(height, pcb_clearance + pcb_thickness), d=pcb_hole_diameter - 0.2 /* tolerance */,chamfer1=-2);
}

module pcb_mounting_post(height, anchor = BOTTOM, spin = 0, orient = UP) {
  attachable(anchor, spin, orient) {
    grid_copies(spacing=[pcb_hole_x_spacing, pcb_hole_y_spacing], n=[2, 2]) post(height);
    children();
  }
}
