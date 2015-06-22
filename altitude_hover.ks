@LAZYGLOBAL OFF.

PARAMETER target_altitude, duration.

LOCAL t0 is TIME:SECONDS.

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

UNTIL TIME:SECONDS - t0 >= duration {
    SET to_throttle TO PID_seek(throttle_pid, target_altitude, SHIP:ALTITUDE).
    SET to_yaw TO PID_seek(yaw_pid, 0, SHIP:VELOCITY:SURFACE * ship:facing:starvector).
    SET to_pitch TO -1 * PID_seek(pitch_pid, 0, SHIP:VELOCITY:SURFACE * ship:facing:topvector).
    
    // Re-update t0 until we're 'hovering'
    if (abs(ship:verticalspeed) > 2) and (abs(ship:surfacespeed) > 2) {
        SET t0 TO TIME:SECONDS.
    }
    
    wait 0.001.
}.

LOCK THROTTLE TO 0.
