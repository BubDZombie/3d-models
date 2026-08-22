// Ben & Jerry's Ice Cream Pint Coozy
// Smooth inside, geometric "Twisted Starburst" outside!

/* [Dimensions] */
// Coozy height (B&J pint is ~104mm; 95mm leaves the lip exposed for the lid)
coozy_height = 87.5; 

// Inner bottom radius (Pints are ~76mm diameter; added ~1mm clearance)
inner_bottom_r = 38.0; 

// Inner top radius (Pints are ~98mm diameter; added ~1mm clearance)
inner_top_r = 45; 

// Minimum wall thickness at the thinnest part of the star
min_wall = 2.5;

// Base thickness to catch condensation
base_thickness = 2.5;

/* [Whimsical Geometry Settings] */
// Number of points/ridges on the outside
num_points = 9;

// How many degrees the shape twists from bottom to top
twist_angle = 120;

// The depth of the geometric ridges (higher = more dramatic star shape)
star_depth = 5;

/* [Hidden] */
$fn = 120; // High resolution for a buttery smooth inner wall

// Calculate how much the outer shell needs to scale to match the inner taper
taper_scale = (inner_top_r + min_wall) / (inner_bottom_r + min_wall);

module coozy() {
    difference() {
        // 1. THE OUTER SHELL (Geometric & Whimsical)
        linear_extrude(height = coozy_height, twist = twist_angle, scale = taper_scale, slices = coozy_height) {
            // Generates a 2D softly pointed star using a cosine wave
            polygon(
                [for (i = [0:359]) 
                    let (
                        // Base radius + the oscillating wave for the star points
                        r = (inner_bottom_r + min_wall + star_depth/2) + 
                            (star_depth/2) * cos(i * num_points)
                    )
                    [ r * cos(i), r * sin(i) ]
                ]
            );
        }

        // 2. THE INNER CUTOUT (Smooth Truncated Cone)
        translate([0, 0, base_thickness])
        cylinder(h = coozy_height + 1, r1 = inner_bottom_r, r2 = inner_top_r);
        
        // 3. THE ANTI-SUCTION HOLE
        // A 20mm hole in the bottom prevents a vacuum seal when removing the pint.
        // It's small enough to bridge easily without supports during printing!
        translate([0, 0, -1])
        cylinder(h = base_thickness + 2, r = 10);
    }
}

// Render the coozy
coozy();