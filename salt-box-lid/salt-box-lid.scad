// Salt Box Lid Replacement - Octagonal Pins
// All dimensions are in millimeters

$fn = 100; // High resolution for the main curves

// --- Dimensions ---
lid_thickness = 6;
rect_width = 110;
rect_depth = 40;
semi_circle_diameter = 135;
pin_length = 12.5;
pin_face_to_face = 6; // Desired flat-to-flat thickness to match the lid

pin_y_offset = 28; // Updated measurement

// --- Math for Perfect Octagons ---
// OpenSCAD draws polygons by their points. We calculate the slightly larger 
// point-to-point diameter needed to make the flat sides exactly 6mm apart.
pin_outer_diameter = pin_face_to_face / cos(22.5);

// --- Model ---
union() {
    // Semi-circle front part
    intersection() {
        cylinder(h=lid_thickness, d=semi_circle_diameter);
        // Bounding box to slice the cylinder in half
        translate([-semi_circle_diameter/2, 0, 0])
            cube([semi_circle_diameter, semi_circle_diameter/2, lid_thickness]);
    }

    // Rectangular back part
    translate([-rect_width/2, -rect_depth, 0])
        cube([rect_width, rect_depth, lid_thickness]);

    // Right Hinge Pin (Octagon)
    translate([rect_width/2, -pin_y_offset, lid_thickness/2])
        rotate([0, 90, 0])
        rotate([0, 0, 22.5]) // Rotate to put a flat side perfectly facing down
        cylinder(h=pin_length, d=pin_outer_diameter, $fn=8);

    // Left Hinge Pin (Octagon)
    translate([-rect_width/2 - pin_length, -pin_y_offset, lid_thickness/2])
        rotate([0, 90, 0])
        rotate([0, 0, 22.5]) // Rotate to put a flat side perfectly facing down
        cylinder(h=pin_length, d=pin_outer_diameter, $fn=8);
}