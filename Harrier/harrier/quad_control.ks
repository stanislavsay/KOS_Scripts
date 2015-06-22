// Flight controller code/state

set quad_thrtl to 0.
lock THROTTLE to quad_thrtl.

// Values for pitch and angle of a attack
lock pitch_ang to (90 - VANG(SHIP:UP:VECTOR, SHIP:FACING:VECTOR)).
lock ang_attack to VANG(SHIP:PROGRADE:VECTOR, SHIP:FACING:VECTOR).

// Value for roll
lock roll_ang to VANG(SHIP:FACING:STARVECTOR, SHIP:UP:VECTOR) - 90.

// Value for vertical velocity
lock vv to SHIP:VERTICALSPEED.

// Value for yaw rate
lock yaw_rate to -(SHIP:ANGULARVEL:X * (180 / CONSTANT():PI)).

// Radar altitude
set radar_alt_mode to True.
lock radar_alt to (ALT:RADAR + radar_alt_bias).

set for_dir to 1.
// Calculate forward velocity
lock vfor to VXCL(SHIP:FACING:STARVECTOR, VXCL(SHIP:UP:VECTOR, SHIP:VELOCITY:SURFACE)):MAG
             * for_dir.


set lat_dir to 1.
// Calculate lateral velocity
lock vlat to VXCL(SHIP:FACING:VECTOR, VXCL(SHIP:UP:VECTOR, SHIP:VELOCITY:SURFACE)):MAG
             * lat_dir.

// Set to true when the servos are ceneterd. Pre-takeoff condition.
set quad_servos_centered to True.

////////////////////////////////////////////////////////////////////////////////
// HIGH LEVEL STATE MACHINE
////////////////////////////////////////////////////////////////////////////////

function quad_flight_control {
    declare parameter ctx.
    declare parameter newstate.
    declare parameter dt.

    set for_dir to VDOT(SHIP:VELOCITY:SURFACE, SHIP:FACING:VECTOR).
    set for_dir to for_dir / abs(for_dir).
    set lat_dir to VDOT(SHIP:VELOCITY:SURFACE, SHIP:FACING:STARVECTOR).
    set lat_dir to lat_dir / abs(lat_dir).

    // Run state machine and get current state
    quad_state_machine(ctx, newstate).
    local outputs is 0.
    local flight_state is ctx[quadctx_state].
    
    if flight_state = "gr" {
        // If we're on the ground

        // Keep the engine throttle at 0.
        set quad_thrtl to 0.

        // Keep the servos centered
        quad_center_servos(ctx).

        // Keep the engine outputs down
        quad_engines_set_power(ctx, 0, 0, 0, 0).
    
    } else if flight_state = "to" {
        // During takeoff

        // Run the PID equations
        set outputs to quad_run_controllers(ctx, dt, flight_state).

        // Call the function to adjust all the servo
        // positions. 
        quad_servo_control(ctx, flight_state, outputs).

        // Run the engine mixer
        quad_engine_mixing(ctx, outputs).

    } else if flight_state = "ab" {
        // While we're airborn

        // Run the PID equations
        set outputs to quad_run_controllers(ctx, dt, flight_state).

        // Call the function to adjust all the servo
        // positions. 
        quad_servo_control(ctx, flight_state, outputs).

        // Run the engine mixer
        quad_engine_mixing(ctx, outputs).

    } else if flight_state = "ld" {
        // While we're landing

        // Run the PID equations
        set outputs to quad_run_controllers(ctx, dt, flight_state).

        // Call the function to adjust all the servo
        // positions. 
        quad_servo_control(ctx, flight_state, outputs).

        // Run the engine mixer
        quad_engine_mixing(ctx, outputs).
    }.
    
}.

function quad_state_machine {
    declare parameter ctx.
    declare parameter next_state.

    local flight_state is ctx[quadctx_state].

    // If the state change request variable has been set
    if next_state <> "na" {
        if next_state = "to" and flight_state = "gr" {
            // Pre-flight checks.
            if not quad_servos_centered {
                print "Cannot start takeoff, servos not centered.".
                return.
            }.

            // Reset to false to guarantee we re-center before next takeoff.
            set quad_servos_centered to False.

            // Start takeoff
            print "Start takeoff...".
            set ctx[quadctx_state] to "to".
            quad_engines_switch(ctx, true).          // Turn on the engines
            quad_engines_set_power(ctx, 0, 0, 0, 0). // Set thrust limiters to 0.
            set quad_thrtl to 1. // Throttle to full
            set ctx[quadctx_ctlSPs][quadctx_vvSP] to 0.01. // Start a 1 cm/s climb

        } else if next_state = "ld" and flight_state = "ab" {
            // Start landing
            print "Start landing...".
            set ctx[quadctx_state] to "ld".
            set ctx[quadctx_ctlSPs][quadctx_vvSP] to -2. // Start a 2 m/s descent
            GEAR on.
            BRAKES on.
        } else {
            // Unsupported state change
            print "Invalid state change request!".
        }.
    }.
    set flight_state to ctx[quadctx_state].

    if flight_state = "to" {
        // If high enough, transition to airborn.
        if ALT:RADAR + radar_alt_bias > 10 {
            BRAKES off.
            GEAR off.
            set ctx[quadctx_state] to "ab".
            print "Airborn!".
            set ctx[quadctx_ctlSPs][quadctx_vvSP] to 0.0.
            // Set altitude controller setpoint to current altitude
            set ctx[quadctx_ctlSPs][quadctx_altSP] to ROUND(radar_alt).
        } else if ALT:RADAR + radar_alt_bias > 6.0 {
            set ctx[quadctx_ctlSPs][quadctx_vvSP] to 0.5. // Decrease ascent rate to 0.5 m/s
        } else if ALT:RADAR + radar_alt_bias > 2.5 {
            set ctx[quadctx_ctlSPs][quadctx_vvSP] to 1. // Increase ascent rate to 1 m/s
        } else if ALT:RADAR + radar_alt_bias > 0.5 {
            set ctx[quadctx_ctlSPs][quadctx_vvSP] to 0.5. // Increase ascent rate to 0.5 m/s
        }.

    } else if flight_state = "ld" {
        // If low enough, transition to landed.
        if ALT:RADAR < 2 {
            set ctx[quadctx_state] to "gr".
            print "Landed!".
            set quad_thrtl to 0.
        }.
    }.

}.

////////////////////////////////////////////////////////////////////////////////
// PID CONTROLLERS AND SUPPORTING FUNCTIONS
////////////////////////////////////////////////////////////////////////////////

// Return a "compass bearing" that will generate an error term in the direction we want
function quad_eff_comp {
    declare parameter yawSP.
    local cur_yaw is -(SHIP:BEARING).
    local left_turn is 0.0.
    local right_turn is 0.0.
    local effective_compass is 0.0.

    if yawSP <= 0 and cur_yaw <= 0 {
        return cur_yaw. // On same side, normal subtraction will work.
    } else if yawSP > 0 and cur_yaw > 0 {
        return cur_yaw. // On same side, normal subtraction will work.
    } else if yawSP <= 0 and cur_yaw > 0 {
        // Figure out how far it is turning left.
        set left_turn to cur_yaw + abs(yawSP).
        // Figure out how far it is turning right.
        set right_turn to (180 - cur_yaw) + (180 - abs(yawSP)).

        // Set effective compass based on which way is shorter
        if left_turn <= right_turn {
            set effective_compass to cur_yaw.
        } else {
            set effective_compass to -180 - (180 - cur_yaw).
        }.
    } else if yawSP > 0 and cur_yaw <= 0 {
        // Figure out how far it is turning right.
        set right_turn to abs(cur_yaw) + yawSP.
        // Figure out how far it is turning left.
        set left_turn to (180 - abs(cur_yaw)) + (180 - yawSP).

        // Set effective compass based on which way is shorter
        if right_turn < left_turn {
            set effective_compass to cur_yaw.
        } else {
            set effective_compass to 180 + (180 - abs(cur_yaw)).
        }.
    }.

    return effective_compass.
}.


set quad_outputs to list(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0).
set cur_vals     to list(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0).
function quad_run_controllers {
  declare parameter ctx.
  declare parameter dt.
  declare parameter state.

  // Run PID controllers
  local i is 0.
  local prevsps is ctx[quadctx_prevSP]. // Previous setpoints
  local sps is ctx[quadctx_ctlSPs].     // Setpoints
  local dzs is ctx[quadctx_ctlDZs].     // Deadzones
  local controllers is ctx[quadctx_ctlctxs].

  // Figure out gain scheduling term
  //local gain_sched is ((SHIP:MASS - vtol_empty_mass) / (vtol_full_mass - vtol_empty_mass)).
  local over_mass is SHIP:MASS - vtol_empty_mass.
  local gain_sched is (vtol_gainsched_a * (over_mass^2)) + (vtol_gainsched_b * over_mass).

  // Get a compass reading that will generate error in the correct direction for shortest turn
  local effective_compass is 0.
  // Don't run heading controller when pitch error too great.
  if abs(sps[quadctx_pitchSP] - pitch_ang) > 10 {
    set effective_compass to SHIP:BEARING.
  } else {
    set effective_compass to quad_eff_comp(sps[quadctx_dirSP]).
  }
  set cur_vals[0] to pitch_ang.
  set cur_vals[1] to roll_ang.
  set cur_vals[2] to vv.
  set cur_vals[3] to yaw_rate.
  set cur_vals[4] to effective_compass.
  set cur_vals[5] to vfor.
  set cur_vals[6] to vlat.
  if radar_alt_mode {
    set cur_vals[7] to radar_alt.
  } else {
    set cur_vals[7] to SHIP:ALTITUDE.
  }

  for ctrl in controllers {
    // Figure out if we should run the differentiator (setpoint change?)
    local run_d is True.
    if ctx[quadctx_prevSP][i] <> 0.0 {
        set run_d to False.
        set ctx[quadctx_prevSP][i] to 0.0.
    }.

    // Calculate the error term
    local e is (sps[i] - cur_vals[i]). // Subtract current value from setpoint for error

    // Run PID equations if outside deadzone
    local output is 0.
    if abs(e) > dzs[i] {
      set output to ctl_run_pid(ctrl, e, dt, run_d, gain_sched, (quad_logging and (i = 7))).
    } else {
        ctl_zero_laste(ctrl). // Set last error term to zero so derrivative isn't
                              // wierd (who knows what side of dz we'll come out of?)
    }.
    set quad_outputs[i] to output. // Add to the controller outputs list
    set i to i + 1.
  }.

  // Set yawrate setpoint to direction controller output
  set sps[quadctx_yawrateSP] to QUAD_MAX_ROT * quad_outputs[4].
  // Set pitch controller to forward velocity controller output
  set sps[quadctx_pitchSP] to QUAD_MAX_FORTILT * -(quad_outputs[5]).
  // Set roll controller to lateral velocity controller output
  set sps[quadctx_rollSP] to QUAD_MAX_LATTILT * (quad_outputs[6]).

  // If we're airborn, enable the altitude controller
  if state = "ab" {
    set sps[quadctx_vvSP] to QUAD_MAX_CLIMBSINK * (quad_outputs[7]).
  }.

  return quad_outputs.
}.

////////////////////////////////////////////////////////////////////////////////
// Engine and servo mixing
////////////////////////////////////////////////////////////////////////////////

// Return the servos to absolute center. Can be slow, not used in flight
function quad_center_servos {
  declare parameter ctx.

  local lock servos to ctx[quadctx_servos].
  local centered is True.

  for ctx in servos {
    set centered to (centered and servo_center(ctx)).
  }.

  set quad_servos_centered to centered.
}.

// Run the servo controllers, driving them towards their setpoints
// The forward engines aren't really vectored in VTOL flight, but
// I'm running the controllers for them anyways so I don't suffer a
// sudden performance hit by re-enabling them (they are slow-ish).
function quad_servo_control {
    declare parameter ctx.
    declare parameter flight_state.
    declare parameter outputs.

    local yawrate_out is outputs[3].
    local lock blctx to ctx[quadctx_servos][quadctx_blservo].
    local lock brctx to ctx[quadctx_servos][quadctx_brservo].

    if yawrate_out < 0 {
        // Turning left, front left forward, back right back
        //servo_set_rot(flctx, 0).
        //servo_set_rot(frctx, 0).
        servo_set_rot(blctx, ( yawrate_out * QUAD_VEC_RANGE)).
        servo_set_rot(brctx, (-yawrate_out * QUAD_VEC_RANGE)).
    } else if yawrate_out > 0 {
        // Turning right, back left back, front right forward
        //servo_set_rot(flctx, 0).
        //servo_set_rot(frctx, 0).
        servo_set_rot(blctx, ( yawrate_out * QUAD_VEC_RANGE)).
        servo_set_rot(brctx, (-yawrate_out * QUAD_VEC_RANGE)).
    } else {
        servo_set_rot(blctx, 0).
        servo_set_rot(brctx, 0).
    }.

    servo_run_control(ctx[quadctx_servos][quadctx_flservo]).
    servo_run_control(ctx[quadctx_servos][quadctx_frservo]).
    servo_run_control(blctx).
    servo_run_control(brctx).
}.

// These are going to represent the 4 engine thrust limits as a percentage.
// These are global for debug purposes.
set fl_lmt to 0.0.
set fr_lmt to 0.0.
set bl_lmt to 0.0.
set br_lmt to 0.0.

function quad_engine_mixing {
    declare parameter ctx.
    declare parameter outputs.

    // Calculate current force of gravity.
    local fgrav is grav_force().
    // Get convenient references to servo modules
    local lock blsmod to ctx[quadctx_servos][quadctx_blservo][servoctx_mod].
    local lock brsmod to ctx[quadctx_servos][quadctx_brservo][servoctx_mod].
    
    // Distribute the power to overcome gravity
    // to all four engines (with scheduling for bias)
    local over_mass is SHIP:MASS - vtol_empty_mass.
    local gain_sched is (vtol_gainsched_a * (over_mass^2)) + (vtol_gainsched_b * over_mass).
    local sched_bias is vtol_frontbias_empty + (gain_sched * vtol_frontbias_delta).

    local front_bias is (fgrav * sched_bias).
    local back_bias is (fgrav - front_bias).
    local fl_thr is (front_bias / 2.0).
    local fr_thr is fl_thr.
    // Account for cosine losses due to vectoring of rear two engines
    local bl_thr is (back_bias / 2.0) / cos(blsmod:getfield("rotation")).
    local br_thr is (back_bias / 2.0) / cos(brsmod:getfield("rotation")).

    // How much thrust do we have per engine?
    if QUAD_MAX_THRUST = 0 {
        set QUAD_MAX_THRUST to SHIP:MAXTHRUST.
    }
    local eng_thr is QUAD_MAX_THRUST / 4.0.
    // How much thrust do we have left over after overcoming gravity?
    local extra_thr is QUAD_MAX_THRUST - fgrav.

    local pitch_out is outputs[0].
    local roll_out is outputs[1].
    local vv_out is outputs[2].

    // Give some of the remaining thrust to
    // the pitch and roll controllers (one third each) first.
    local pitch_roll_prop is extra_thr / 3.0.
    local front is pitch_out * pitch_roll_prop.
    local back is -pitch_out * pitch_roll_prop.

    local left is roll_out * pitch_roll_prop.
    local right is -roll_out * pitch_roll_prop.

    // Add roll and pitch outputs to engine power outputs
    set fl_thr to fl_thr + front + left.
    set fr_thr to fr_thr + front + right.
    set bl_thr to bl_thr + back + left.
    set br_thr to br_thr + back + right.

    // Add VV controller output to engine thrusts
    local vv_thr is (pitch_roll_prop * vv_out).
    set fl_thr to fl_thr + vv_thr.
    set fr_thr to fr_thr + vv_thr.
    set bl_thr to bl_thr + vv_thr.
    set br_thr to br_thr + vv_thr.

    // Calculate thrust limits
    set fl_lmt to (fl_thr / eng_thr) * 100.
    set fr_lmt to (fr_thr / eng_thr) * 100.
    set bl_lmt to (bl_thr / eng_thr) * 100.
    set br_lmt to (br_thr / eng_thr) * 100.

    // Set the thrust limits!
    set ctx[quadctx_engines][0]:thrustlimit to fl_lmt.
    set ctx[quadctx_engines][1]:thrustlimit to fr_lmt.
    set ctx[quadctx_engines][2]:thrustlimit to bl_lmt.
    set ctx[quadctx_engines][3]:thrustlimit to br_lmt.
}.

////////////////////////////////////////////////////////////////////////////////
// Altimetry mode switch
////////////////////////////////////////////////////////////////////////////////

function quad_radar_alt_mode {
    declare parameter ctx.
    declare parameter radar_on.

    if radar_on {
      set radar_alt_mode to True.
      set ctx[quadctx_ctlSPs][quadctx_altSP] to radar_alt.
    } else {
      set radar_alt_mode to False.
      set ctx[quadctx_ctlSPs][quadctx_altSP] to SHIP:ALTITUDE.
    }
}

////////////////////////////////////////////////////////////////////////////////
// Setpoint adjustment functions
////////////////////////////////////////////////////////////////////////////////

// Sets absolute pitch setpoint
function quad_set_pitch_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    set ctx[quadctx_prevSP][quadctx_pitchSP] to ctx[quadctx_ctlSPs][quadctx_pitchSP].

    set ctx[quadctx_ctlSPs][quadctx_pitchSP] to MAX( MIN(new_sp, 89), -89 ).
}.

// Changes pitch setpoint by a delta
function quad_set_pitch_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    local new_sp is ctx[quadctx_ctlSPs][quadctx_pitchSP] + sp_delta.

    set ctx[quadctx_prevSP][quadctx_pitchSP] to ctx[quadctx_ctlSPs][quadctx_pitchSP].

    set ctx[quadctx_ctlSPs][quadctx_pitchSP] to MAX( MIN(new_sp, 89), -89).
}.


function quad_set_vfor_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    set ctx[quadctx_prevSP][quadctx_vforSP] to ctx[quadctx_ctlSPs][quadctx_vforSP].

    set ctx[quadctx_ctlSPs][quadctx_vforSP] to MAX( MIN(new_sp, 10), -10).
}.

function quad_set_vfor_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    local new_sp is ctx[quadctx_ctlSPs][quadctx_vforSP] + sp_delta.

    set ctx[quadctx_prevSP][quadctx_vforSP] to ctx[quadctx_ctlSPs][quadctx_vforSP].

    set ctx[quadctx_ctlSPs][quadctx_vforSP] to MAX( MIN(new_sp, 10), -10).
}.


// Sets absolute roll setpoint
function quad_set_roll_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    set ctx[quadctx_prevSP][quadctx_rollSP] to ctx[quadctx_ctlSPs][quadctx_rollSP].

    set ctx[quadctx_ctlSPs][quadctx_rollSP] to MAX( MIN(new_sp, 89), -89 ).
}.

// Changes roll setpoint by a delta
function quad_set_roll_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    local new_sp is ctx[quadctx_ctlSPs][quadctx_rollSP] + sp_delta.
    
    set ctx[quadctx_prevSP][quadctx_rollSP] to ctx[quadctx_ctlSPs][quadctx_rollSP].

    set ctx[quadctx_ctlSPs][quadctx_rollSP] to MAX( MIN(new_sp, 89), -89).
}.


function quad_set_vlat_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    set ctx[quadctx_prevSP][quadctx_vlatSP] to ctx[quadctx_ctlSPs][quadctx_vlatSP].

    set ctx[quadctx_ctlSPs][quadctx_vlatSP] to MAX( MIN(new_sp, 10), -10).
}.

function quad_set_vlat_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    local new_sp is ctx[quadctx_ctlSPs][quadctx_vlatSP] + sp_delta.

    set ctx[quadctx_prevSP][quadctx_vlatSP] to ctx[quadctx_ctlSPs][quadctx_vlatSP].

    set ctx[quadctx_ctlSPs][quadctx_vlatSP] to MAX( MIN(new_sp, 10), -10).
}.


// Sets absolute vertical velocity setpoint
function quad_set_vv_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    set ctx[quadctx_prevSP][quadctx_vvSP] to ctx[quadctx_ctlSPs][quadctx_vvSP].

    set ctx[quadctx_ctlSPs][quadctx_vvSP] to MAX( MIN(new_sp, 10), -10 ).
}.

// Changes vertical velocity setpoint by a delta
function quad_set_vv_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    local new_sp is ctx[quadctx_ctlSPs][quadctx_vvSP] + sp_delta.

    set ctx[quadctx_prevSP][quadctx_vvSP] to ctx[quadctx_ctlSPs][quadctx_vvSP].

    set ctx[quadctx_ctlSPs][quadctx_vvSP] to MAX( MIN(new_sp, 10), -10).
}.

// Sets absolute altitude setpoint
function quad_set_alt_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    set ctx[quadctx_prevSP][quadctx_altSP] to ctx[quadctx_ctlSPs][quadctx_altSP].

    set ctx[quadctx_ctlSPs][quadctx_altSP] to MAX( MIN(new_sp, 10), -10 ).
}.

// Changes altitude setpoint by a delta
function quad_set_alt_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    local new_sp is ctx[quadctx_ctlSPs][quadctx_altSP] + sp_delta.

    set ctx[quadctx_prevSP][quadctx_altSP] to ctx[quadctx_ctlSPs][quadctx_altSP].

    set ctx[quadctx_ctlSPs][quadctx_altSP] to MAX( MIN(new_sp, 1000), 0).
}.


// Sets absolute yaw rate setpoint
function quad_set_yawrate_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    set ctx[quadctx_prevSP][quadctx_yawrateSP] to ctx[quadctx_ctlSPs][quadctx_yawrateSP].

    set ctx[quadctx_ctlSPs][quadctx_yawrateSP] to MAX( MIN(new_sp, 180), -180).

    set ctx[quadctx_ctlctxs][quadctx_yawrateSP][ctlctx_i] to 0. // Kill integrator value
}.

// Changes yaw rate setpoint by a delta
function quad_set_yawrate_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    local new_sp is ctx[quadctx_ctlSPs][quadctx_yawrateSP] + sp_delta.

    set ctx[quadctx_prevSP][quadctx_yawrateSP] to ctx[quadctx_ctlSPs][quadctx_yawrateSP].

    set ctx[quadctx_ctlSPs][quadctx_yawrateSP] to MAX( MIN(new_sp, 180), -180).

    set ctx[quadctx_ctlctxs][quadctx_yawrateSP][ctlctx_i] to 0. // Kill integrator value
}.


// Sets absolute direction setpoint
function quad_set_dir_sp_abs {
    declare parameter ctx.
    declare parameter new_sp.

    local new_dir is new_sp.
    if new_dir < -180 {
        set new_dir to 180 + (180 + new_dir).
    } else if new_dir > 180 {
        set new_dir to -180 + (new_dir - 180).
    }.
    set ctx[quadctx_prevSP][quadctx_dirSP] to ctx[quadctx_ctlSPs][quadctx_dirSP].
    set ctx[quadctx_ctlSPs][quadctx_dirSP] to new_dir.
}.

// Changes direction setpoint by a delta
function quad_set_dir_sp_rel {
    declare parameter ctx.
    declare parameter sp_delta.

    quad_set_dir_sp_abs(ctx, ctx[quadctx_ctlSPs][quadctx_dirSP] + sp_delta).
}.
