// Recreating the angled mount from image_a1eebf.png
$fn = 120; // High resolution for smooth curves

// --- Known Dimensions ---
inner_radius = 22.635; // From cyan measurement[cite: 1]

// --- Estimated Dimensions (Adjust as needed) ---
outer_radius = 27.5;     // Thickness of the main angled walls
base_radius = 31;      // Flange at the bottom
base_height = 4;       // Thickness of the bottom flange
tilt_angle = -28;      // Angle of the main cylindrical body
mount_height = 45;     // Total length of the angled cylinder
cutout_depth = 100;    // How deep the inner pocket goes

// --- Base Flange Adjustments ---
base_x_stretch = 1.2;  // Stretches the base along the X-axis to match the tilt footprint
base_x_offset = -0.5;  // Shifts the base along the X-axis to center it under the lean

difference() {
    // 1. MAIN SOLID BODY (What we keep)
    union() {
        // Flat base flange (Stretched and shifted to fit the angled cylinder)
        translate([base_x_offset, 0, 0])
            scale([base_x_stretch, 1, 1])
                cylinder(r=base_radius, h=base_height);
        
        // Main angled cylindrical body
        translate([0, 0, base_height])
            rotate([0, tilt_angle, 0])
                translate([0,0,-20-base_height])
                    cylinder(r=outer_radius, h=mount_height);
                
        // Tapered and rounded protrusion
        translate([outer_radius - 2, 0, 5]) 
        rotate([0, tilt_angle, 0])
            // Extrude with a scale > 1 so it starts small at the bottom and widens at the top
            linear_extrude(height=25, scale=1.3)
                // Offset rounds the corners of the 2D square before it gets extruded
                offset(r=2.5)
                    square([5, 16], center=true);
    }

    // 2. SUBTRACTIONS (What we cut away)
    
    // The main inner cylindrical cutout (cyan highlight)
    translate([0, 0, base_height])
        rotate([0, tilt_angle, 0])
            // Shift up along the angled Z-axis to leave a solid bottom
            translate([0, 0, mount_height - cutout_depth])
                cylinder(r=inner_radius, h=cutout_depth + 10); // +10 ensures a clean cut through the top
                
    // Clean-up cut: Flatten the bottom to ensure no angled geometry dips below Z=0
    translate([0, 0, -50])
        cube(100, center=true);
}