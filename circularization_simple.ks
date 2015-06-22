// Configuration Coefficients

SET thrust_gain TO 10.
SET max_attitude_error to 5.
SET goal to 0.01 .

// Start continuous recalculation of controller variables.
// These will be reevalued when needed, and once they are
// connected to STEERING and THROTTLE, that will happen
// every physics tick.

LOCK circular_speed TO SQRT(BODY:MU/(BODY:RADIUS+ALTITUDE)).
LOCK horizontal_velocity TO VXCL(UP:VECTOR,VELOCITY:ORBIT).
LOCK circular_velocity TO horizontal_velocity:NORMALIZED*circular_speed.
LOCK remaining_burn TO circular_velocity-VELOCITY:ORBIT.
LOCK remaining_delta_v to remaining_burn:MAG.
LOCK max_accel TO MAXTHRUST/MASS.
LOCK attitude_error TO VANG(FACING:VECTOR,remaining_burn).
LOCK attitude_fade TO MAX(0,max_attitude_error-attitude_error)/max_attitude_error.

// Start steering in the needed direction, and
// set up thrust command. Initially our attitude is
// likely to be very wrong, so expect to observe
// the throttle being cut to zero until we are
// pointed in the right direction.

LOCK STEERING TO LOOKDIRUP(remaining_burn,facing:topvector).
LOCK THROTTLE TO attitude_fade*thrust_gain*remaining_delta_v/max_accel.

// Hang out until we are done.
// NOTE: for some applications, this script could return
// to a calling script here. It would then be up to the
// calling script to keep hands off STEERING and THROTTLE
// until the job is done (or needs to be stopped), but
// would allow calling script to do other things.

WAIT UNTIL remaining_delta_v <= goal .

// Cut the throttle and stop steering.
// Calling script (if any) will reassert control.
// If called from keyboard, we leave the pilot
// throttle input at zero.

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
UNLOCK THROTTLE.
UNLOCK STEERING.
