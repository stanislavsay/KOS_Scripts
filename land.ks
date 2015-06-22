PRINT "Start descent program.".
LOCK THROTTLE TO 0.
// break_height is the height at which we must begin maximum deceleration in order to 
// stop in time. Doesn't currently take in to account change in inertia due to propellant
// or air resistance.
LOCK gravaccel TO KERBIN:MU / (KERBIN:RADIUS + SHIP:ALTITUDE)^2.
LOCK twr TO SHIP:AVAILABLETHRUST / (gravaccel * SHIP:MASS).
LOCK break_height TO (SHIP:VERTICALSPEED^2 / (2 * gravaccel * (twr - 1))).
WAIT UNTIL radar_altitude() <= break_height + 100.

PRINT "End descent program.".

PRINT "Start landing program.".

// THROTTLE PID
LOCAL throttle_pid IS PID_init(0.1, 0.06, 0.06, 0, 1).
LOCAL to_throttle IS 0.
LOCK THROTTLE TO to_throttle.

// PITCH/YAW PID
LOCAL yaw_pid IS PID_init(2, 0.5, 0.5, -45, 45).
LOCAL pitch_pid IS PID_init(2, 0.5, 0.5, -45, 45).
LOCAL to_yaw IS 0.
LOCAL to_pitch IS 0.
LOCK STEERING TO SHIP:UP + R(to_pitch, to_yaw, 0).

UNTIL radar_altitude() < 1 {
    if radar_altitude() > 10 {
        SET to_throttle TO PID_seek(throttle_pid, -7, SHIP:VERTICALSPEED).
    } else {
        SET to_throttle TO PID_seek(throttle_pid, -2, SHIP:VERTICALSPEED).
    }
	SET to_yaw TO PID_seek(yaw_pid, 0, SHIP:VELOCITY:SURFACE * ship:facing:starvector).
	SET to_pitch TO -1 * PID_seek(pitch_pid, 0, SHIP:VELOCITY:SURFACE * ship:facing:topvector).
    wait 0.001.
}.

LOCK THROTTLE TO 0.
PRINT "End landing program.".
