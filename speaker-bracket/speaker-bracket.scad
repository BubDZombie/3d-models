/* Parametric Speaker Stand Keyhole Mount v4 (Double Octagon)
   All measurements are in millimeters.
*/

$fn = 100; // High resolution for smooth cylinders

// --- PARAMETERS ---

// Pole Dimensions
pipe_diameter = 12.0;
pipe_clearance = 0.6; // 12.6mm total inner diameter
collar_wall_thickness = 6;
collar_height = 35;

// Speaker Mount Dimensions
hole_spacing = 57.0;
screw_hole_diameter = 4.5; // Clearance hole for an M4 bolt
plate_margin = 15; // Extra material above/below holes
plate_height = hole_spacing + (plate_margin * 2);

// Derived Values (Do not change)
collar_d = pipe_diameter + pipe_clearance + (collar_wall_thickness * 2);
collar_r = collar_d / 2;

// --- OCTAGON MATH ---
// To get exact flat-to-flat distances, we calculate the circumscribed diameters
inner_hole_size = pipe_diameter + pipe_clearance;
inner_octagon_d = inner_hole_size / cos(22.5); 
outer_octagon_d = collar_d / cos(22.5);

// Bracket Dimensions
bracket_width = collar_d;
bracket_thickness = 6; // CF-PLA is stiff, 6mm with gussets is very strong

// Gusset Dimensions
gusset_thickness = 4;
gusset_length = collar_d - bracket_thickness;
gusset_height = plate_height; // Full height for maximum rigidity

// --- MODULE ---

module speaker_mount() {
    difference() {
        union() {
            // 1. The Collar (Outer Octagon for support-free flat printing)
            rotate([0, 0, 22.5])
                cylinder(h = collar_height, d = outer_octagon_d, $fn = 8);
            
            // 2. The Cap / Base Plate 
            translate([0, 0, collar_height])
                rotate([0, 0, 22.5])
                cylinder(h = bracket_thickness, d = outer_octagon_d, $fn = 8);
            
            // Squares off the front of the cap so the bracket sits flush across its width
            translate([-collar_r, -collar_r, collar_height])
                cube([collar_d, collar_d, bracket_thickness]);

            // 3. The Vertical Arm 
            // Positioned perfectly flush with the outside front edge of the collar
            translate([collar_r - bracket_thickness, -bracket_width/2, collar_height + bracket_thickness])
                cube([bracket_thickness, bracket_width, plate_height]);

            // 4. Left Support Gusset (Inside the L)
            translate([collar_r - bracket_thickness, -bracket_width/2 + gusset_thickness, collar_height + bracket_thickness])
                rotate([90, 0, 0])
                linear_extrude(height = gusset_thickness)
                polygon([[0,0], [-gusset_length, 0], [0, gusset_height]]);

            // 5. Right Support Gusset (Inside the L)
            translate([collar_r - bracket_thickness, bracket_width/2, collar_height + bracket_thickness])
                rotate([90, 0, 0])
                linear_extrude(height = gusset_thickness)
                polygon([[0,0], [-gusset_length, 0], [0, gusset_height]]);
        }

        // --- SUBTRACTIONS (Holes) ---

        // A. Main Pipe Hole (Inner Octagon)
        translate([0, 0, -1])
            rotate([0, 0, 22.5]) 
            cylinder(h = collar_height + 1, d = inner_octagon_d, $fn = 8);

        // B. Set Screw Hole (On the back of the collar, opposite the speaker)
        translate([-collar_d, 0, collar_height / 2])
            rotate([0, 90, 0])
            cylinder(h = collar_d, d = 2.8);

        // C. Bottom Speaker Mount Hole
        translate([collar_r - bracket_thickness - 1, 0, collar_height + bracket_thickness + plate_margin])
            rotate([0, 90, 0])
            cylinder(h = bracket_thickness + 2, d = screw_hole_diameter);

        // D. Top Speaker Mount Hole
        translate([collar_r - bracket_thickness - 1, 0, collar_height + bracket_thickness + plate_margin + hole_spacing])
            rotate([0, 90, 0])
            cylinder(h = bracket_thickness + 2, d = screw_hole_diameter);
    }
}

// Render the part
speaker_mount();