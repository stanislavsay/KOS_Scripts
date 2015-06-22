// Main quad library include

// Required includes
run quad_constants.

set quad_logging to False.

// Constants (indices for accessing fields in vtol context "objects" (lists for now)
set quadctx_state to 0. // High level vtol controller state (explained below)
set quadctx_ctlctxs to 1.  // Controller context list
set quadctx_ctlSPs to 2. // Controller setpoint list
set quadctx_servos to 3. // Servo controller contexts (fl, fr, bl, br).
set quadctx_engines to 4. // List of 4 engine structs (fl, fr, bl, br).
set quadctx_ctlDZs to 5. // List of deadzone values for pitch, roll, vv, yaw, dir
set quadctx_prevSP to 6. // Previous setpoint, used to avoid derivative kick

// Setpoint list indices
set quadctx_pitchSP to 0.
set quadctx_rollSP to 1.
set quadctx_vvSP to 2.
set quadctx_yawrateSP to 3.
set quadctx_dirSP to 4.
set quadctx_vforSP to 5.
set quadctx_vlatSP to 6.
set quadctx_altSP to 7.

set quadctx_flservo to 0.
set quadctx_frservo to 1.
set quadctx_blservo to 2.
set quadctx_brservo to 3.

run quad_engine.

// Create VTOL controller context
//    state: a string describing the high level vtol controller state
// ctl_ctxs: a list of controller contexts (pitch, roll, vv, yaw)
//   servos: a list of 4 servo contextx for the engines
//  engines: a list of 4 engine part references
//deadzones: a list of deadzones for all the controllers
function quad_ctxinit {
    declare parameter state.
    declare parameter ctl_ctxs.
    declare parameter servos.
    declare parameter engines.
    declare parameter deadzones.

    return list(state, 
                ctl_ctxs,
                list(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), // Setpoints, initialize to 0.
                servos,
                engines,
                deadzones,
                list(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)). // Previous setpoints
}.

run quad_control.
