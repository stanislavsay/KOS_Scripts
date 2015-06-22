// Context and control functions for Infernal Robotics Rotatron servos.

// Indices for servo context "fields"
set servoctx_name to 0.
set servoctx_part to 1.
set servoctx_mod to 2.
set servoctx_sp to 3.
set servoctx_laste to 4.
set servoctx_nlim to 5.
set servoctx_plim to 6.
set servoctx_spdP to 7.
set servoctx_minspd to 8.
set servoctx_maxspd to 9.
set servoctx_posdz to 10.
set servoctx_moving to 11.

// Create a servo context "object"
function servo_ctxinit {
  declare parameter partname.
  declare parameter neg_limit.
  declare parameter pos_limit.
  declare parameter accel.
  declare parameter speed_gain.
  declare parameter min_speed.
  declare parameter max_speed.
  declare parameter pos_dz.

  local servo_part is SHIP:PARTSDUBBED(partname)[0].
  local servo_mod is servo_part:GETMODULE("MuMechToggle").
  servo_mod:setfield("acceleration", accel).
  servo_mod:setfield("speed", 1.0).

  return list(partname,   // Keep partname string for debug/reference
              servo_part, // Reference to part structure
              servo_mod,  // Reference to IR module
              0.0,        // Position setpoint
              0.0,        // Last position error
              neg_limit,  // Bottom most limit of servo rotation (degrees)
              pos_limit,  // Topmost limit of servo rotation (degrees)
              speed_gain, // Rate to increase servo speed with position error
              min_speed,  // Lowest the proportional controller will set the servo speed
              max_speed,  // Highest the proportional controller will set the servo speed
              pos_dz,     // Deadzone for position controller, "close enough".
              0           // Is the servo currently moving?
              ).
}.

// Run servo control for a servo context
function servo_run_control {
  declare parameter ctx.

  local smod is ctx[servoctx_mod].
  local error is ctx[servoctx_sp] - smod:getfield("rotation").
  local moving is ctx[servoctx_moving].

  smod:setfield("speed", 
                MIN(ctx[servoctx_maxspd], 
                    MAX(ctx[servoctx_minspd], 
                        (ctx[servoctx_spdP] * abs(error)) ))).

  if abs(error) > ctx[servoctx_posdz] {
    if error > 0 and moving <> 1 {
      smod:doaction("move -", False).
      smod:doaction("move +", True).
      set ctx[servoctx_moving] to 1.
    } else if error < 0 and moving <> -1 {
      smod:doaction("move +", False).
      smod:doaction("move -", True).
      set ctx[servoctx_moving] to -1.
    }.
  } else {
    if moving <> 0 {
      smod:doaction("move +", False).
      smod:doaction("move -", False).
      set ctx[servoctx_moving] to 0.
    }.
  }.

}.

// Set the rotation setpoint for a servo context
function servo_set_rot {
  declare parameter ctx.
  declare parameter new_sp.

  //print "SERVO TO: " + new_sp.
  set ctx[servoctx_sp] to MIN(ctx[servoctx_plim], MAX(ctx[servoctx_nlim], new_sp)).
}.

// Called to reset servos to the center position. Returns true if centered.
function servo_center {
  declare parameter ctx.

  local smod is ctx[servoctx_mod].
  local rotation is smod:getfield("rotation").

  // Speed proportional gain * absolute error
  local speed is ctx[servoctx_spdP] * abs(ctx[servoctx_sp] - rotation).

  smod:setfield("speed", MAX(ctx[servoctx_minspd], speed)).

  smod:doaction("move +", False).
  smod:doaction("move -", False).
  if abs(rotation) > 0 {
    smod:doaction("move center", true).
    return False.
  } else {
    smod:doaction("move center", false).
    return True.
  }.
  
}.
