// staging, throttle, steering, go


// switch to archive.
// copy stage_immediate to 1.
//copy stage_init to 1.
//switch to 1.

run stage_init.
unlock steering.
//LOCK STEERING TO R(0,0,-90) + HEADING(90,90).
SET thrott TO 1.
LOCK THROTTLE to thrott.

//WAIT UNTIL SHIP:ALTITUDE > 1000.

// P-loop setup
SET gforce_setpoint TO 1.2.
SET Kp TO 0.01.
SET Ki TO 0.006.
SET Kd TO 0.006.

SET g TO ship:body:MU / ship:body:RADIUS^2.
SET I TO 0.
SET D TO 0.

LOCK in_deadband TO ABS(P) < 0.01.
LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce TO accvec:MAG / g.
LOCK P TO gforce_setpoint - gforce.
LOCK dthrott TO Kp * P + Ki * I + Kd * D.

SET t0 TO TIME:SECONDS.
set P0 to p.

UNTIL SHIP:ALTITUDE > 40000 {
    SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
      IF NOT in_deadband {
        SET I TO I + P * dt.
                    // If Ki is non-zero, then limit Ki*I to [-1,1]
        IF Ki > 0 {
            SET I TO MIN(1.0/Ki, MAX(-1.0/Ki, I)).
        }
        SET D TO (P - P0) / dt.

        // set throttle but keep in range [0,1]
        SET thrott to MIN(1, MAX(0, thrott + dthrott)).
        SET t0 TO TIME:SECONDS.
        SET P0 TO P.
      }
    }
    run stage_immediate.
    WAIT 0.001.
}
