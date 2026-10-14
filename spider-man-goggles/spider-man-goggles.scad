// Recreating the angled mount from image_a1eebf.png
$fn = 120; // High resolution for smooth curves

outer_radius = 45.5/2;   // Thickness of the main angled walls
inner_radius = outer_radius - 5;
base_radius = outer_radius + 5;
base_height = 4;       // Thickness of the bottom flat flange
taper_height = 4;      // Height of the 45-degree tapered section
tilt_angle = -28;      // Angle of the main cylindrical body
mount_height = 50;     // Total length of the angled cylinder
cutout_depth = 100;    // How deep the inner pocket goes
hole_radius = 1.25;    // Radius of the octagonal perforations

// --- Base Flange Adjustments ---
base_x_stretch = 1.13;  // Stretches the base along the X-axis to match the tilt footprint
base_x_offset = -0.2;  // Shifts the base along the X-axis to center it under the lean

difference() {
    // 1. MAIN SOLID BODY (What we keep)
    union() {
        // Stacked Base: Flat flange with a tapered top
        translate([base_x_offset, 0, 0])
            scale([base_x_stretch, 1, 1]) {
                // Original flat base
                cylinder(r=base_radius, h=base_height);
                
                // 45-degree chamfer built on top
                translate([0, 0, base_height])
                    cylinder(r1=base_radius, r2=base_radius - taper_height, h=taper_height);
            }
        
        // Main angled cylindrical body
        translate([0, 0, base_height + taper_height])
            rotate([0, tilt_angle, 0])
                translate([0, 0, -20 - (base_height + taper_height)])
                    cylinder(r=outer_radius, h=mount_height);
                
        // FDM-Friendly Chamfered Protrusion
        overlap = 2;   // Pushes the block slightly into the cylinder so they merge perfectly
        box_w = 7;     // Visible width extending outward
        box_l = 15;    // Length of the box (along Y)
        box_h = 29;    // Height of the box (along Z)
        chamfer = 7.5; // The size of the 45-degree bevel (Safe for FDM overhangs)
        
        translate([outer_radius - overlap, -12, 5])
        rotate([0, tilt_angle, 0])
            // Shift the start point and rotate 90 degrees so it extrudes flat along the Y axis
            translate([0, 19.5, 2])
            rotate([90, 0, 0])
                linear_extrude(height=box_l)
                    polygon([
                        [0, 0],                                    // Bottom-left (hidden inside cylinder)
                        [box_w + overlap - chamfer, 0],            // Start of bottom 45-deg bevel
                        [box_w + overlap, chamfer],                // End of bottom 45-deg bevel
                        [box_w + overlap, box_h - chamfer],        // Start of top 45-deg bevel
                        [box_w + overlap - chamfer, box_h],        // End of top 45-deg bevel
                        [0, box_h]                                 // Top-left (hidden inside cylinder)
                    ]);
    }

    // 2. SUBTRACTIONS (What we cut away)
    
    // Octagonal perforations around the base
    translate([base_x_offset, 0, base_height / 2]) {
        for (i = [0 : 45 : 135]) {
            rotate([0, 0, i])
                rotate([0, 90, 0])
                    rotate([0, 0, 22.5]) // Rotates the octagon to have flat top/bottom edges
                        cylinder(r=hole_radius, h=base_radius * 4, center=true, $fn=8);
        }
    }
    
    // The main inner cylindrical cutout
    translate([0, 0, base_height + taper_height])
        rotate([0, tilt_angle, 0])
            // Shift up along the angled Z-axis to leave a solid bottom
            translate([0, 0, mount_height - cutout_depth])
                cylinder(r=inner_radius, h=cutout_depth + 10);
                
    // Clean-up cut: Flatten the bottom to ensure no angled geometry dips below Z=0
    translate([0, 0, -50])
        cube(100, center=true);
}