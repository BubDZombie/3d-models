/* 
 * Switch Box and Lid - Single Post
 * Based on dimensions from image_b59a97.jpg
 */

// --- PARAMETERS ---

// PCB Dimensions
pcb_length = 50;
pcb_width = 15;
tolerance = 0.6; // Extra breathing room for the PCB

// Box Dimensions
box_internal_depth = 12;
wall_thickness = 2;

// Component Placement & Dimensions
switch_width = 12;
switch_depth = 12; // Distance down from the top edge
post_diameter = 5;
hole_to_edge_gap = 2;
post_to_switch_dist = 11; // Distance from switch cut-out edge to post center
post_height = box_internal_depth - 3; // Height of the standoff
switch_offset = 15;

// Wire Notch Dimensions
wire_notch_width = 4;
wire_notch_depth = 10;

// Lid Parameters
lid_thickness = 2;
lid_lip_height = 2.5;
lid_clearance = 0.2; // Gap for friction fit

// Smoothness
$fn = 50;

// --- DERIVED MEASUREMENTS ---
inner_l = pcb_length + tolerance;
inner_w = pcb_width + tolerance;
outer_l = inner_l + (2 * wall_thickness);
outer_w = inner_w + (2 * wall_thickness);
outer_h = box_internal_depth + wall_thickness;

// Layout Math
pcb_start_x = wall_thickness + (tolerance / 2);
switch_pos_x = pcb_start_x + switch_offset;
post_pos_x = switch_pos_x + switch_width + post_to_switch_dist;

// --- RENDER ---
box();
translate([0, outer_w + 10, 0]) lid();

// --- MODULES ---

module box() {
    difference() {
        // Main solid box
        cube([outer_l, outer_w, outer_h]);
        
        // Hollow interior
        translate([wall_thickness, wall_thickness, wall_thickness])
            cube([inner_l, inner_w, box_internal_depth + 1]);
            
        // Slide switch cutout (Offset based on post distance)
        translate([switch_pos_x, 0, outer_h - switch_depth])
            cube([switch_width, wall_thickness + 1, switch_depth + 1]);
            
        // Wire notch 1 (Left short side)
        translate([-1, (outer_w - wire_notch_width) / 2, outer_h - wire_notch_depth])
            cube([wall_thickness + 2, wire_notch_width, wire_notch_depth + 1]);
            
        // Wire notch 2 (Right short side)
        translate([outer_l - wall_thickness - 1, (outer_w - wire_notch_width) / 2, outer_h - wire_notch_depth])
            cube([wall_thickness + 2, wire_notch_width, wire_notch_depth + 1]);
    }
    
    // Single Mounting Post
    post_y_center = outer_w / 2;
    
    translate([post_pos_x, post_y_center, wall_thickness])
        cylinder(h = post_height, d = post_diameter);
}

module lid() {
    // Flat top cover
    cube([outer_l, outer_w, lid_thickness]);
    
    // Friction-fit inner lip
    lip_length = inner_l - (2 * lid_clearance);
    lip_width = inner_w - (2 * lid_clearance);
    
    translate([wall_thickness + lid_clearance, wall_thickness + lid_clearance, lid_thickness])
        difference() {
            // Main lip block
            cube([lip_length, lip_width, lid_lip_height]);
            // Hollow out the lip to save plastic and allow slight flex for snapping
            translate([wall_thickness, wall_thickness, -1])
                cube([lip_length - (2 * wall_thickness), lip_width - (2 * wall_thickness), lid_lip_height + 2]);
        }
}