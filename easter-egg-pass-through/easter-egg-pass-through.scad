/*
  Spiral Pass-Through Egg Toy (Parametric Scale + EggOMatic Curve)
  - Flipped upside down (Fat end on bottom)
  - Dynamic curve analysis for any 'egg_c' value
  - Fully proportional scaling
*/

// --- Master Parameters ---

// Master height of the egg in millimeters
toy_height = 40; 

// Absolute clearance (Does not scale, ensuring functional print-in-place tolerances)
clearance = 0.4;
twist_angle = 185;
arms = 6;
offset_size = 2; // Fixed offset for rounding corners

// --- Calculated Proportions ---
// These ratios are derived from the original design to maintain the exact internal mechanics

eq_r     = toy_height * (30 / 66); // Target maximum radius

center_r = toy_height * (7 / 66);
arm_off  = toy_height * (14 / 66);
arm_l    = toy_height * (16 / 66);
arm_w    = toy_height * (3 / 66);

cutter_height = toy_height * 1.5; // Always taller than the egg

// --- EggOMatic Math ---
egg_c = 0.83; // 1.2 produces a teardrop/heavy-bottom shape
base_chop_fraction = 0.04; // Chop 4% off the mathematical bottom to stand upright

// Scale the mathematical egg so the visible portion perfectly matches 'toy_height'
math_egg_length = toy_height / (1 - base_chop_fraction);

// Egg outline formula from EggOMatic by Richard Swika
function egg_outline(c, z) = z >= 1 ? 0 : z <= 0 ? 0 : 
    (sqrt(4 - 4*c - 8*z + sqrt(64*c*z + pow(4 - 4*c, 2))) * sqrt(4*z) / sqrt(2)) / 4;

// Dynamically find the maximum radius of the current curve to scale it perfectly
math_max_r_unit = max([for (i = [0 : 100]) egg_outline(egg_c, i / 100)]);
math_max_r = math_max_r_unit * math_egg_length;
width_scale = eq_r / math_max_r;


// --- Auto-Measurement Calculator ---
max_radius = arm_off + (arm_l / 2) + offset_size + clearance; 
travel_distance = 2 * PI * max_radius * (twist_angle / 360);
overhang_angle = atan2(cutter_height, travel_distance);
max_safe_twist = (cutter_height * 360) / (2 * PI * max_radius);

echo("=======================================");
echo(str("Toy Height: ", toy_height, " mm"));
echo(str("OVERHANG ANGLE: ", overhang_angle, " degrees from horizontal"));
echo("=======================================");

// Rendering Configuration
render_mode = 0; // 0=Both, 1=Inner, 2=Outer, 3=Assembled
core_color = "#33FF33";
shell_color = "#5555FF";

// Resolution
$fn = 100; // Increased for smoother scaling

// --- Modules ---

module egg_profile() {
    intersection() {
        // Generate the mathematically perfect egg profile polygon
        polygon(
            concat(
                [ [0, 0] ], // Center bottom (flat base)
                [ for (i = [0 : $fn]) 
                    let (
                        t_prog = i / $fn,
                        // FLIPPED: Evaluate from (1 - base_chop) down to 0
                        shape_z = (1 - base_chop_fraction) - (t_prog * (1 - base_chop_fraction)),
                        r = egg_outline(egg_c, shape_z) * math_egg_length * width_scale,
                        h = t_prog * toy_height
                    )
                    [r, h]
                ],
                [ [0, toy_height] ] // Center top (tip)
            )
        );
        // Strict Z=0 and X=0 cutoff to keep the right half clean for extrusion
        translate([0, 0]) square([toy_height * 2, toy_height * 2]);
    }
}

module egg() {
    rotate_extrude(convexity = 10) {
        egg_profile();
    }
}

module spiral_profile(gap = 0) {
    offset_radius = offset_size + gap;
    offset(r = offset_radius) {
        union() {
            circle(r = center_r);
            
            theta_step = 360 / arms;
            for(i = [0:arms - 1]) {
                rotate([0, 0, i * theta_step])
                    translate([arm_off, 0])
                        square([arm_l, arm_w], center=true);
            }
        }
    }
}

module spiral_cutter(gap = 0) {
    // Drop below Z=0 proportionally to cleanly cut the base
    translate([0, 0, -toy_height * 0.2])
        linear_extrude(height = cutter_height, twist = twist_angle, slices = 200, convexity = 10) {
            spiral_profile(gap);
        }
}

module inner_core() {
    intersection() {
        egg();
        spiral_cutter(gap = 0);
    }
}

module outer_shell() {
    difference() {
        egg();
        spiral_cutter(gap = clearance);
    }
}

// --- Rendering Logic ---

if (render_mode == 0) {
    color(core_color) translate([-(eq_r + 5), 0, 0]) inner_core();
    color(shell_color) translate([(eq_r + 5), 0, 0]) outer_shell();
} else if (render_mode == 1) {
    color(core_color) inner_core();
} else if (render_mode == 2) {
    color(shell_color) outer_shell();
} else if (render_mode == 3) {
    color(core_color) inner_core();
    color(shell_color, alpha=0.5) outer_shell();
}