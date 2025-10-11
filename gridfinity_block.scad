// LibFile: gridfinity_block.scad
//   A Gridfinity-compatible block/bin system for modular storage solutions.
//   This library provides modules for creating customizable Gridfinity blocks
//   with features like square holes, round holes, and stacking lips.
//   .
//   Rewritten to use BOSL2 library features including anchors, positioning,
//   and attachments for cleaner, more maintainable code.
//
// FileSummary: Gridfinity-compatible modular storage block system
// FileGroup: Storage Solutions
//
// Includes:
//   include <BOSL2/std.scad>

// Copyright (c) 2025 The Gridfinity Block Contributors
// Licensed under the Apache License, Version 2.0 (see LICENSE file)
// https://github.com/wromijn/openscad-gridfinity-block

include <BOSL2/std.scad>

// Section: Configuration

// Constant: GF_WALL_THICKNESS
// Description: Standard wall thickness for Gridfinity blocks
GF_WALL_THICKNESS = 0.95;
GF_WALL_MIN_THICKNESS = 0.3;

// Constant: GF_TOLERANCE
// Description: Manufacturing tolerance for Gridfinity block dimensions
GF_TOLERANCE = 0.5;

// Constant: GF_GRID_SIZE
// Description: Standard Gridfinity grid unit size in millimeters
GF_GRID_SIZE = 42;

// Constant: GF_HEIGHT_UNIT
// Description: Standard Gridfinity height unit in millimeters
GF_HEIGHT_UNIT = 7;

GF_OUTER_RADIUS = 3.75;
GF_MIDDLE_RADIUS = 1.6;
GF_INNER_RADIUS = 0.8;

GF_BASE_HEIGHT = GF_HEIGHT_UNIT;

/* [Hidden] */
_EPSILON = 0.01;

// Section: Main Modules

// Module: gridfinity_block()
// Usage:
//   gridfinity_block(size, <stacking_lip=>, <anchor=>, <spin=>, <orient=>);
// Topics: Gridfinity, Storage, Organization
// Description:
//   Creates a Gridfinity-compatible storage block with configurable dimensions.
//   The block includes feet for grid compatibility and an optional stacking lip.
//   Children can be subtracted from the interior to create custom compartments.
//   .
//   ```
//   ┌─────────────────┐
//   │                 │  ← Optional stacking lip
//   │  ╔═══════════╗  │
//   │  ║           ║  │  ← Main body
//   │  ║  (holes)  ║  │
//   │  ╚═══════════╝  │
//   └──┬─┬─────┬─┬──┘
//      │▓│     │▓│      ← Gridfinity feet
//      └─┘     └─┘
//   ```
// Arguments:
//   size = Size as `[x_units, y_units, z_units]`. X and Y are in grid units (42mm each), Z is in height units (7mm each).
//   ---
//   stacking_lip = If true, adds a lip for stacking blocks. Default: false
//   anchor = Translate so anchor point is at origin (0,0,0). See BOSL2 anchor documentation. Default: `BOTTOM`
//   spin = Rotate this many degrees around the Z axis after anchor. See BOSL2 spin documentation. Default: `0`
//   orient = Vector to rotate top towards, after spin. See BOSL2 orient documentation. Default: `UP`
// Example(3D,VPD=300): Basic 2x1x3 Block
//   include <gridfinity_block.scad>
//   gridfinity_block([2, 1, 3]);
// Example(3D,VPD=300): With Stacking Lip
//   include <gridfinity_block.scad>
//   gridfinity_block([2, 1, 3], stacking_lip=true);
module gridfinity_block(size, stacking_lip = false, anchor = BOTTOM, spin = 0, orient = UP, wall_thickness = GF_WALL_THICKNESS) {
  assert(is_list(size) && len(size) == 3, "size must be [x_units, y_units, z_units]");
  assert(wall_thickness >= GF_WALL_MIN_THICKNESS, str("wall_thickness must be at least ", GF_WALL_MIN_THICKNESS));

  foot_height = 4.75;
  floor_thickness = wall_thickness;

  lip_height = stacking_lip ? stacking_lip_height(slice(size, 0, 1), wall_thickness) : 0;
  lip_bottom_height = stacking_lip_bottom_extension_height(slice(size, 0, 1), wall_thickness);

  bin_dim = [
    GF_GRID_SIZE * size.x - GF_TOLERANCE,
    GF_GRID_SIZE * size.y - GF_TOLERANCE,
    GF_HEIGHT_UNIT * size.z + (lip_height - lip_bottom_height),
  ];
  wall_height = bin_dim.z - foot_height - floor_thickness - lip_height;

  inner_size = [
    max(bin_dim.x - 2 * wall_thickness, 0),
    max(bin_dim.y - 2 * wall_thickness, 0),
    max(wall_height, 0),
  ];
  inside_center_z = -bin_dim.z / 2 + foot_height + floor_thickness + inner_size.z / 2;
  has_inside_part = inner_size.x > 0 && inner_size.y > 0 && inner_size.z > 0;
  inside_parts =
    has_inside_part ? [
        define_part(
          "inside",
          attach_geom(size=inner_size),
          inside=true,
          T=move([0, 0, inside_center_z])
        ),
      ]
    : [];

  attachable(anchor, spin, orient, size=bin_dim, parts=inside_parts) {
    down(bin_dim.z / 2)
      // Gridfinity feet at the bottom
      gridfinity_feet(slice(size, 0, 1), anchor=BOTTOM)
        position(TOP)
          // floor
          cuboid([bin_dim.x, bin_dim.y, floor_thickness], anchor=BOTTOM, rounding=GF_OUTER_RADIUS, edges="Z")
            position(TOP)
              // Main walls
              rect_tube(size=[bin_dim.x, bin_dim.y], wall=wall_thickness, rounding=GF_OUTER_RADIUS, height=wall_height, anchor=BOTTOM)

              // Optional stacking lip (kept as before)
              if (stacking_lip) {
                position(TOP)
                  stacking_lip(slice(size, 0, 1), wall_thickness=wall_thickness, anchor=BOTTOM);
              }

    children();
  }
}

// Section: Internal Modules

// Module: gridfinity_feet()
// Usage: Internal
//   gridfinity_feet(x_units, y_units);
// Description:
//   Creates the standard Gridfinity foot pattern with magnet holes.
//   This is an internal module used by gridfinity_block().
//   .
//   ```
//   ┌─────┐     ┌─────┐
//   │ ● ● │     │ ● ● │  ← Magnet holes
//   │     │ ... │     │
//   │ ● ● │     │ ● ● │
//   └─────┘     └─────┘
//     Foot        Foot
//   ```
module gridfinity_feet(units, anchor = BOTTOM, spin = 0, orient = UP) {
  assert(is_list(units) && len(units) == 2, "units must be [x_units, y_units]");

  height = [0.8, 1.8, 2.15];
  size = [GF_GRID_SIZE - GF_TOLERANCE - 2 * (height[0] + height[2]), GF_GRID_SIZE - GF_TOLERANCE - 2 * height[2], GF_GRID_SIZE - GF_TOLERANCE];
  foot_height = sum(height);

  // Make the feet attachable so callers can anchor/rotate/orient them cleanly.
  attachable(anchor, spin, orient, size=[GF_GRID_SIZE * units.x - GF_TOLERANCE, GF_GRID_SIZE * units.y - GF_TOLERANCE, foot_height]) {
    grid_copies(n=units, spacing=GF_GRID_SIZE)
      down(foot_height / 2)
        diff("magnet") {
          prismoid(size[0], size[1], h=height[0], rounding1=GF_INNER_RADIUS, rounding2=GF_MIDDLE_RADIUS, anchor=BOTTOM) {
            position(TOP)
              cuboid([size[1], size[1], height[1]], rounding=GF_MIDDLE_RADIUS, edges="Z", anchor=BOTTOM)
                position(TOP)
                  prismoid(size[1], size[2], h=height[2], rounding1=GF_MIDDLE_RADIUS, rounding2=GF_OUTER_RADIUS, anchor=BOTTOM);
            // Magnet holes
            position(BOTTOM) tag("magnet") grid_copies(n=[2, 2], spacing=GF_GRID_SIZE - GF_TOLERANCE - (height[1] + height[0] + 4.8) * 2)
                  cyl(h=2 + _EPSILON, d=6, anchor=BOTTOM);
          }
        }
    children();
  }
}

// Module: stacking_lip()
// Usage: Internal
//   stacking_lip(size, <anchor=>, <spin=>, <orient=>);
// Description:
//   Creates the stacking lip feature for gridfinity blocks.
//   This allows blocks to securely stack on top of each other.
module stacking_lip(units, anchor = BOTTOM, spin = 0, orient = UP, wall_thickness = GF_WALL_THICKNESS) {
  assert(is_list(units) && len(units) == 2, "units must be [x_units, y_units]");

  height = [0.7, 1.8, 1.9];
  size = [GF_GRID_SIZE * units.x - GF_TOLERANCE, GF_GRID_SIZE * units.y - GF_TOLERANCE];

  top_thickness = min(wall_thickness, GF_WALL_THICKNESS);
  top_height = height[2] - top_thickness;

  bottom_nominal_thickness = height[0] + height[2];
  bottom_extension_slope_height = max(0, bottom_nominal_thickness - wall_thickness);
  has_bottom_extension = bottom_extension_slope_height > 0;

  bottom_extension_height = has_bottom_extension ? bottom_extension_slope_height + 0.6 : 0;

  inner_bottom_nominal = [
    max(size.x - 2 * bottom_nominal_thickness, 0),
    max(size.y - 2 * bottom_nominal_thickness, 0),
  ];
  inner_bottom_target = [
    max(size.x - 2 * wall_thickness, 0),
    max(size.y - 2 * wall_thickness, 0),
  ];
  inner_mid = [
    max(size.x - 2 * height[2], 0),
    max(size.y - 2 * height[2], 0),
  ];
  inner_top = [
    max(size.x - 2 * top_thickness, 0),
    max(size.y - 2 * top_thickness, 0),
  ];

  lip_height = bottom_extension_height + height[0] + height[1] + top_height;

  attachable(anchor, spin, orient, size=[GF_GRID_SIZE * units.x - GF_TOLERANCE, GF_GRID_SIZE * units.y - GF_TOLERANCE, lip_height]) {
    up(lip_height / 2)
      // top slope
      rect_tube(size1=size, size2=size, isize1=inner_mid, isize2=inner_top, h=top_height, rounding=GF_OUTER_RADIUS, irounding1=GF_MIDDLE_RADIUS, irounding2=GF_OUTER_RADIUS-top_thickness, anchor=TOP)
        position(BOTTOM)
          // straight middle wall
          rect_tube(size=size, isize=inner_mid, h=height[1], rounding=GF_OUTER_RADIUS, irounding=GF_MIDDLE_RADIUS, anchor=TOP)
            position(BOTTOM)
              // bottom slope
              rect_tube(size1=size, size2=size, isize1=inner_bottom_nominal, isize2=inner_mid, h=height[0], rounding=GF_OUTER_RADIUS, irounding1=GF_INNER_RADIUS, irounding2=GF_MIDDLE_RADIUS, anchor=TOP) if (has_bottom_extension) {
                position(BOTTOM)
                  rect_tube(size=size, isize=inner_bottom_nominal, h=0.6, rounding=GF_OUTER_RADIUS, irounding=GF_INNER_RADIUS, anchor=TOP)
                    position(BOTTOM)
                      rect_tube(size1=size, size2=size, isize1=inner_bottom_target, isize2=inner_bottom_nominal, h=bottom_extension_slope_height, rounding=GF_OUTER_RADIUS, irounding1=GF_OUTER_RADIUS - wall_thickness, irounding2=GF_INNER_RADIUS, anchor=TOP);
              }
    children();
  }
}

function stacking_lip_bottom_extension_height(units, wall_thickness = GF_WALL_THICKNESS) =
  let (
    height = [0.7, 1.8, 1.9],
    bottom_nominal_thickness = height[0] + height[2],
    bottom_extension_slope_height = max(0, bottom_nominal_thickness - wall_thickness),
    has_bottom_extension = bottom_extension_slope_height > 0,
    bottom_extension_height = has_bottom_extension ? bottom_extension_slope_height + 0.6 : 0
  ) bottom_extension_height;

function stacking_lip_height(units, wall_thickness = GF_WALL_THICKNESS) =
  let (
    height = [0.7, 1.8, 1.9],
    bottom_extension_height = stacking_lip_bottom_extension_height(units, wall_thickness),
    top_thickness = min(wall_thickness, GF_WALL_THICKNESS),
    top_height = height[2] - top_thickness,
    lip_height = bottom_extension_height + height[0] + height[1] + top_height
  ) lip_height;
