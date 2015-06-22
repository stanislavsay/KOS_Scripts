// Harrier control code!

// Import libraries
run control_lib. // Shared control library
run servo_lib.   // Shared servo library
run quad.

run harrier_ctx. // Create the control contexts


clearscreen.

// Don't want SAS on, ensure it's off.
wait 0.5.
SAS on.
wait 0.5.
SAS off.

// Use for control/debugging
lock pitch_sp to vtol_ctx[quadctx_ctlSPs][quadctx_pitchSP].
lock roll_sp to vtol_ctx[quadctx_ctlSPs][quadctx_rollSP].
lock vv_sp to vtol_ctx[quadctx_ctlSPs][quadctx_vvSP].
lock yaw_sp to vtol_ctx[quadctx_ctlSPs][quadctx_yawrateSP].
lock dir_sp to vtol_ctx[quadctx_ctlSPs][quadctx_dirSP].
lock vfor_sp to vtol_ctx[quadctx_ctlSPs][quadctx_vforSP].
lock vlat_sp to vtol_ctx[quadctx_ctlSPs][quadctx_vlatSP].
lock alt_sp to vtol_ctx[quadctx_ctlSPs][quadctx_altSP].

lock pitch_last_e to vtol_pitch_ctx[ctlctx_laste].
lock roll_last_e to vtol_roll_ctx[ctlctx_laste].
lock vv_last_e to vtol_vv_ctx[ctlctx_laste].
lock yaw_last_e to vtol_yawrate_ctx[ctlctx_laste].
lock dir_last_e to vtol_dir_ctx[ctlctx_laste].

lock bl_rot to vtol_ctx[quadctx_servos][quadctx_blservo][servoctx_mod]:getfield("rotation").
lock br_rot to vtol_ctx[quadctx_servos][quadctx_brservo][servoctx_mod]:getfield("rotation").

// Start running
lock vtol_state to vtol_ctx[quadctx_state].
set next_state to "na".
set shutdown to false.

// Set direction setpoint to nearest direction multiple of 10.
quad_set_dir_sp_abs(vtol_ctx, ROUND(-(SHIP:BEARING / 10.0)) * 10.0).

// Enable/disable fly by wire mode.
set fbwmode to false.
run harrier_ui(fbwmode). // Initialize UI.

set TERMINAL:HEIGHT to 17.

set k to 0.
set t0 to TIME:SECONDS.
set start to t0.
set last_1hz to t0.
until shutdown {
    set now to TIME:seconds.
    set dt to now - t0.

    // Run the flight controller
    quad_flight_control(vtol_ctx, next_state, dt).
    
    if next_state = vtol_state {
      set next_state to "na".
    }.

    //if fbwmode {
    //  run_vtol_fbw(vtol_ctx).
    //}.

    set print_debug to True.
    if print_debug and now - last_1hz > 1.0 {
       local over_mass is SHIP:MASS - vtol_empty_mass.
       local gain_sched is (vtol_gainsched_a * (over_mass^2)) + (vtol_gainsched_b * over_mass).
       //local gain_sched is ((SHIP:MASS - vtol_empty_mass) / (vtol_full_mass - vtol_empty_mass)).

       set last_1hz to now.
       
       print dt.
       //print "Gain       : " + gain_sched.
       print "Bearing    : " + -SHIP:BEARING.
       print "Radar Alt  : " + radar_alt().
       print "Forward Vel: " + vfor().
       print "Lateral Vel: " + vlat().
       print " ".
       print "Pitch SP   : " + pitch_sp.
       print "Roll  SP   : " + roll_sp.
       print "Yaw   SP   : " + yaw_sp.
       print "VV    SP   : " + vv_sp.
       print " ".
       print "Dir   SP   : " + dir_sp.
       print "vFor  SP   : " + vfor_sp.
       print "vLat  SP   : " + vlat_sp.
       print "Alt   SP   : " + alt_sp.
       print "RADAR ALT  : " + radar_alt_mode.

       //print "Pitch Error: " + pitch_last_e.
       //print "Roll  Error: " + roll_last_e.
       //print "Yaw   Error: " + yaw_last_e.
       //print "Dir   Error: " + dir_last_e.

       //print "Engine Outputs (%):".
       //print fl_lmt + " ---- " + fr_lmt.

	     //print bl_lmt + " ---- " + br_lmt.

       //print "Vectoring angles:".
       //print bl_rot + " ---- " + br_rot.

//       print "FBW_pitch: " + fbw_filteredpitch.
//       print "FBW_roll : " + fbw_filteredroll.
    }.

    set t0 to now.
    //wait 0.05. (Intetionally reduce code performance to test stability at lower refresh rate)
}.

// Kill the engines
quad_engines_switch(vtol_ctx, false).

print "Script exiting".
