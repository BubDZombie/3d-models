/*
 * Slow Cooker Replacement Knob - Support-Free "Feet-Up" Print
 * Features a 45° tapered counterbore for zero overhangs.
 */

// ============================
// USER CONFIGURABLE PARAMETERS
// ============================

knob_diameter = 75;           // Outer diameter (must be > 50mm to cover the 25mm offset hole)
knob_height = 22;             // Total height of the knob (flat top to base)
waist_ratio = 0.90;           // Thickness of the middle waist (1.0 = cylinder, 0.5 = very skinny)

bolt_hole_diameter = 6.75;     // Diameter of the main center bolt hole
bolt_hole_distance = 25;      // Distance from center to the second (indexing) hole

pin_diameter = 6;           // Diameter of the indexing pin 
pin_length = 7;               // Length of the pin extending up

counterbore_diameter = 12;    // Recess diameter on the flat top
counterbore_depth = 1;        // Total depth of the flat top recess

foot_height = 3;              // Height of the 3 support feet
foot_thickness = 6;
foot_gap = 12;

$fn = 64;                     // Smoothness of the curves

// ============================
// CALCULATIONS
// ============================

knob_radius = knob_diameter / 2;
hole_radius = bolt_hole_diameter / 2;
pin_radius = pin_diameter / 2;
foot_radius = foot_thickness / 2;
waist_radius = knob_radius * waist_ratio;
counterbore_radius = counterbore_diameter / 2;
chamfer_height = 3.5;

// Position the 3 feet far enough out to prevent wobble, 
// and offset them by 30° so they don't overlap the indexing pin.
foot_pos_radius = knob_radius * 0.75;

// ============================
// POSITIVE GEOMETRY
// ============================

module main_body() {
    steps = 30;
    outer_curve = [
        for (i = [0 : steps]) 
            let(t = i / steps, 
                z = t * knob_height, 
                r = knob_radius - (knob_radius - waist_radius) * sin(180 * t))
            [r, z]
    ];
    // Close the 2D profile into a solid block
    closed_profile = concat(
        [[0, 0]],           // Center flat top (Z=0)
        outer_curve,        // Right-side contour
        [[0, knob_height]]  // Center bottom (Z=knob_height)
    );
    rotate_extrude($fn = $fn)
        polygon(points = closed_profile);
}

module support_feet() {
    // No chamfers here! Just straight cylinders pointing up for a true support-free print.
    for (i = [0 : 1 : 2]) {
        rotate([0, 0, 60 + i * 120]) // Offset 30° to avoid the pin
            translate([foot_pos_radius, 0, knob_height]) 
                cylinder(r = foot_radius, h = foot_height);
    }
}

module support_curves() {
    translate([0, 0, knob_height])
        difference() {
            cylinder(h = foot_height, r1 = knob_radius, r2 = knob_radius, center = false);
            cylinder(h = foot_height, r1 = knob_radius - foot_thickness, r2 = knob_radius - foot_thickness, center = false);
            for (i = [0 : 1 : 2]) {
                    rotate([0, 0, 60 + i * 120])
                        translate([knob_radius,0,0])
                            cube([knob_radius, foot_gap, foot_thickness], center = true);
            }
        }
}

module indexing_pin() {
    // Straight pillar pointing up
    translate([bolt_hole_distance, 0, knob_height])
        cylinder(r = pin_radius, h = pin_length);
}

// ============================
// NEGATIVE SPACES (HOLES & 45° TAPER)
// ============================

module negative_spaces() {
    // 1. The main straight bolt hole (goes entirely through)
    //translate([0, 0, -1]) // Starts slightly below the flat top
        cylinder(r = hole_radius, h = knob_height);
        
    // 2. The 45° tapered flare (replaces the flat 90° step)
    // OpenSCAD's cylinder(r1, r2, h) creates a perfect straight cone
    translate([0, 0, counterbore_depth])
        cylinder(r1 = counterbore_radius, r2 = hole_radius, h = chamfer_height);
        
    // 3. The flat counterbore at the very top
    //translate([0, 0, -counterbore_depth])
        cylinder(r = counterbore_radius, h = counterbore_depth);
}

// ============================
// FINAL ASSEMBLY
// ============================

module final_knob() {
    difference() {
        union() {
            main_body();
            support_curves();
            indexing_pin();
        }
        negative_spaces();
    }
}

// Render the knob
final_knob();
//negative_spaces();
//main_body();
//support_curves();