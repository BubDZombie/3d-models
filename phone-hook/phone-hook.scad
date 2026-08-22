// MagSafe to Generic Slate Phone Adapter - NARROW SPINE VERSION
// All dimensions are in millimeters (mm)

/* [Charger Dimensions] */
// Width of the square charger (added 0.5mm for slip-fit tolerance)
charger_w = 60.5;  
// Height of the square charger block
charger_h = 60.5;  
// Depth the charger sticks out from the wall
charger_d = 30;  

/* [Phone Dimensions] */
// Width variable is no longer used for adapter width, kept for coil calculation
phone_w = 80;      
// Maximum thickness of the phone/case combo
phone_thickness = 14; 
// Distance from the bottom of the phone to the center of the wireless charging coil

coil_height = 72.5; 

/* [Print Settings] */
// Wall thickness for structural components
wall = 2.5;        
// Thickness of the plate between phone and charger (Keep at 1.5mm)
backplate_thickness = 1.5; 
// Height of the front lip holding the phone from slipping off
lip_height = 10;   

/* [Calculated Values] */
drop_distance = coil_height - (charger_h / 2);
// Defines the consistent narrow outer width of the *entire* assembly
outer_w = charger_w + 2*wall; 
// Full external height of the sleeve box
sleeve_h = charger_h + wall; 

module narrow_phone_adapter() {
    union() {
        // 1. The Hook / Sleeve (Slides over the charger)
        difference() {
            // Outer shell (Width restricted to `outer_w`)
            translate([-outer_w/2, 0, 0])
                cube([outer_w, charger_d + backplate_thickness, sleeve_h]);

            // Inner void
            translate([-charger_w/2, -0.1, -0.1])
                cube([charger_w, charger_d + 0.1, charger_h + 0.1]);
        }

        // 2. The Narrow Backplate / Spine
        // Connects the sleeve down to the shelf, width restricted to `outer_w`
        translate([-outer_w/2, charger_d, -drop_distance])
            cube([outer_w, backplate_thickness, drop_distance + sleeve_h]);

        // 3. The Narrow Bottom Hook / Shelf (No side walls)
        // Width restricted to `outer_w`
        translate([-outer_w/2, charger_d, -drop_distance])
            cube([outer_w, backplate_thickness + phone_thickness + wall, wall]);

        // 4. The Narrow Front Lip
        // Width restricted to `outer_w`
        translate([-outer_w/2, charger_d + backplate_thickness + phone_thickness, -drop_distance])
            cube([outer_w, wall, lip_height]);

        // (Original side gussets from image_0.png are removed)
    }
}

// Render the adapter
narrow_phone_adapter();