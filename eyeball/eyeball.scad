// Eyeball blank: truncated sphere / spherical cap
// Customizer parameters
diameter_mode = "base"; // [sphere, base]

// If mode == "sphere": diameter is the original sphere / max diameter.
// If mode == "base":   diameter is the flat back/base circle diameter.
diameter = 50;

// Overall height from flat cut plane to the top of the dome.
height = 11;

$fn = 128;
eps = 0.01;

module truncated_sphere(diam=50, h=38, mode="sphere") {
    raw_h = max(h, eps);

    // Compute the sphere radius depending on what "diameter" means.
    r = (mode == "base")
        ? (diam*diam/4 + raw_h*raw_h) / (2*raw_h)
        : diam/2;

    // In sphere mode, height cannot exceed the sphere diameter.
    hh = (mode == "base") ? raw_h : min(raw_h, diam);

    // Place sphere center so the top is at z = hh and the cut is at z = 0.
    z_center = hh - r;

    intersection() {
        translate([0, 0, z_center])
            sphere(r = r);

        // Keep only the part above z = 0 and below z = hh.
        translate([0, 0, -eps])
            cylinder(h = hh + 2*eps, r = r + 1);
    }
}

truncated_sphere(diam=diameter, h=height, mode=diameter_mode);