DECLARE PARAMETER Kp.

LOCK g TO SHIP:BODY:MU / (SHIP:BODY:RADIUS + SHIP:ALTITUDE)^2.
LOCK maxtwr TO SHIP:MAXTHRUST / (g * SHIP:MASS).

// feedback based on atmospheric efficiency
LOCK surfspeed TO SHIP:VELOCITY:SURFACE:MAG.
LOCK atmoeff TO surfspeed / SHIP:TERMVELOCITY.
LOCK P TO 1.0 - atmoeff.

SET t0 TO TIME:SECONDS.
LOCK dthrott TO Kp*P.
SET start_time TO t0.

LOG "Throttle PID Tuning" TO throttle_log.
LOG "Kp: " + Kp TO throttle_log.
LOG "t;P;maxtwr" TO throttle_log.

LOCK logline TO (TIME:SECONDS - start_time)
        + ";" + P
        + ";" + maxtwr.

SET thrott TO 1.
LOCK THROTTLE TO thrott.
SAS ON.
STAGE.
WAIT 3.

UNTIL SHIP:ALTITUDE > 30000 {
    SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
        SET thrott TO MIN(1,MAX(0,thrott + dthrott)).
        SET t0 TO TIME:SECONDS.
        LOG logline TO throttle_log.
    }
    WAIT 0.001.
}
COPY throttle_log TO 0.