//------------------------------------------
// D20 Vertex Down - 108 Degree Fix
//------------------------------------------

icoheight   = 30; 
cut_corners = true; 
font        = "UbuntuBold";

// ORIENTATION CALIBRATION
// 105.525 was "just outside". 
// The geometric symmetry aligns at intervals of 36 degrees.
// 3 * 36 = 108 degrees is the likely "perfect" alignment.
z_spin_correction = 100; 

// Quality: 1=Fast, 10=High Quality
text_steps = 10; 

//------------------------------------------
// Main Render Logic
//------------------------------------------

// Lift factor = 1.258406 (Distance from center to tip relative to face distance)
lift_amount = (icoheight * 0.5) * 1.258406;

translate([0, 0, lift_amount])    // 3. Lift
rotate([37.377, 0, 0])            // 2. Tip
rotate([0, 0, z_spin_correction]) // 1. Spin
drawicosa_centered();

//------------------------------------------
// Modules
//------------------------------------------

module drawicosa_centered() {
    difference() {
        intersection() {
            icosahedron(icoheight);
            if(cut_corners)
                rotate([-10, 35, -28])
                dodecahedron(icoheight*1.2, 116.565, 1);
        }
        icosatext(icoheight);
    }
}

//------------------------------------------
// Helper Module: Profiled Text
//------------------------------------------
module profiled_text(txt, t_size, t_font) {
    depth = 0.6; 
    max_inset = 0.25; 

    if (text_steps <= 1) {
        linear_extrude(height=depth*1.1)
        text(txt, size=t_size, valign="center", halign="center", font=t_font);
    } else {
        step_height = depth / text_steps;
        for (i = [0 : text_steps-1]) {
            z_pos = i * step_height;
            ratio = i / (text_steps-1);
            current_inset = -max_inset * cos(ratio * 90);

            translate([0, 0, z_pos])
            linear_extrude(height=step_height + 0.01) 
            offset(delta = current_inset) 
            text(txt, size=t_size, valign="center", halign="center", font=t_font);
        }
    }
}

//------------------------------------------
// Geometry Modules
//------------------------------------------

module dodecahedron(height, slope, cutoff) {
    intersection() {
        cube([2 * height, 2 * height, cutoff * height], center = true); 
        intersection_for(i = [0:4]) { 
            rotate([0, 0, 72 * i])
            rotate([slope, 0, 0])
            cube([2 * height, 2 * height, height], center = true); 
        }
    }
}

module octahedron(height) {
    intersection() {
        cube([2 * height, 2 * height, height], center = true); 
        intersection_for(i = [0:2]) { 
            rotate([109.47122, 0, 120 * i])
            cube([2 * height, 2 * height, height], center = true); 
        }
    }
}

w = -15.525;

module icosahedron(height) {
    intersection() {
        octahedron(height);
        rotate([0, 0, 60 + w])
            octahedron(height);
        intersection_for(i = [1:3]) { 
            rotate([0, 0, i * 120])
            rotate([109.471, 0, 0])
            rotate([0, 0, w])
            octahedron(height);
        }
    }
}

//------------------------------------------
// Text Placement
//------------------------------------------

underscore = [" ", " ", " ", " ", " ", "_", " ", " ", "_", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " "];
otext = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"];

module octahalf(height, j) {
    text_depth = 0.6; 
    rotate([0, 0, 180]) {
        rotate([0, 0, 39])
        translate([0, 0, 0.5 * height - text_depth])
        profiled_text(otext[j], 0.21 * height, font);

        rotate([0, 0, 39])
        translate([0, 4, 0.5 * height - text_depth])
        profiled_text(underscore[j], 0.21 * height, font);
    }
    for (i = [0:2]) { 
        rotate([109.47122, 0, 120 * i]) {
            rotate([0, 0, 39])
            translate([0, 0, 0.5 * height - text_depth])
            profiled_text(otext[i + j + 1], 0.21 * height, font);

            rotate([0, 0, 39])
            translate([0, 4, 0.5 * height - text_depth])
            profiled_text(underscore[i + j + 1], 0.21 * height, font);
        }
    }
}

module icosatext(height) {
    rotate([70.5288, 0, 60])
    octahalf(height, 0);

    rotate([0, 0, 60 + w]) {
        octahalf(height, 4);
    }

    for(i = [1:3]) { 
        rotate([0, 0, i * 120])
        rotate([109.471, 0, 0])
        rotate([0, 0, w])
        octahalf(height, 4 + i * 4);
    }
}