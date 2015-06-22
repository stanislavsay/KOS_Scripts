SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
// staging, throttle, steering, go
WHEN STAGE:LIQUIDFUEL < 0.1 THEN {
    STAGE.
    PRESERVE.
}
LOCK THROTTLE TO 1.
SET starting_pitch TO 80.
LOCK STEERING TO R(0,0,-90) + HEADING(90,starting_pitch).
STAGE.
WAIT UNTIL SHIP:ALTITUDE > 1000.
WHEN SHIP:ALTITUDE > 20000 THEN {
   SET gforce_setpoint TO 2.
}
 
// PID-loop
SET g TO KERBIN:MU / KERBIN:RADIUS^2.
LOCK accvec TO SHIP:SENSORS:ACC - SHIP:SENSORS:GRAV.
LOCK gforce TO accvec:MAG / g.
 
SET gforce_setpoint TO 1.3.
 
LOCK P TO gforce_setpoint - gforce.
SET I TO 0.
SET D TO 0.
SET P0 TO P.
 
LOCK in_deadband TO ABS(P) < 0.01.
 
SET Kp TO 0.016.
SET Ki TO 0.006.
SET Kd TO 0.006.
 
LOCK dthrott TO Kp * P + Ki * I + Kd * D.
 
SET thrott TO 1.
LOCK THROTTLE to thrott.
SET target_apoapsis TO 75000.
SET target_periapsis TO 75000.
 
SET t0 TO TIME:SECONDS.
UNTIL (SHIP:APOAPSIS > target_APOAPSIS) {
    SET dt TO TIME:SECONDS - t0.
    IF dt > 0 {
        IF NOT in_deadband {
            SET I TO I + P * dt.
            SET D TO (P - P0) / dt.
 
            // If Ki is non-zero, then limit Ki*I to [-1,1]
            IF Ki > 0 {
                SET I TO MIN(1.0/Ki, MAX(-1.0/Ki, I)).
            }
 
            // set throttle but keep in range [0,1]
            SET thrott to MIN(1, MAX(0, thrott + dthrott)).
 
            SET P0 TO P.
            SET t0 TO TIME:SECONDS.
        }
    }
    IF (SHIP:ALTITUDE < 30000) {
        SET target_pitch TO MAX(1, starting_pitch * (1 - ALT:RADAR / 50000)).
    }
    ELSE {
        SET target_pitch TO MAX(1, starting_pitch * (1 - ALT:RADAR / 40000)).
    }
    LOCK STEERING TO R(0,0,-90) + HEADING(90,target_pitch).
 
    
    WAIT 0.001.
}
 
LOCK STEERING TO R(0,0,-90) + HEADING(90,0).
SET thrott TO 0.
WAIT UNTIL ETA:APOAPSIS < 1.
 
//RUN circularize.
//circularization script, starts immediately when called.
//via http://www.reddit.com/r/Kos/comments/37zk1g/how_can_i_make_my_orbits_more_precise/crriaho
 
set th to 0.
lock throttle to th.
local dV is ship:facing:vector:normalized. //temporary
lock steering to lookdirup(dV, ship:facing:topvector).
ag1 off. //ag1 to abort
 
local timeout is time:seconds + 9000.
when dV:mag < 0.05 then set timeout to time:seconds + 3.
until ag1 or dV:mag < 0.02 or time:seconds > timeout {
    set vecNormal to vcrs(up:vector,velocity:orbit).
    set vecHorizontal to -1 * vcrs(up:vector, vecNormal).
    set vecHorizontal:mag to sqrt(body:MU/(body:Radius + altitude)).
 
    set dV to vecHorizontal - velocity:orbit. //deltaV as a vector
 
    //Debug vectors , feel free to delete
    set mark_h to VECDRAWARGS(ship:position, vecHorizontal / 100, RGB(0,1,0), "h", 1, true).
    set mark_v to VECDRAWARGS(ship:position, velocity:orbit / 100, RGB(0,0,1), "dv", 1, true).
    set mark_dv to VECDRAWARGS(ship:position + velocity:orbit / 100, dV, RGB(1,1,1), "dv", 1, true).
 
    //throttle control
    if vang(ship:facing:vector,dV) > 1 { set th to 0. } //Throttle to 0 if not pointing the right way
    else { set th to max(0,min(1,dV:mag/10)). } //lower throttle gradually as remaining deltaV gets lower
    wait 0.
}
set th to 0.
set mark_h:SHOW TO false.
set mark_v:SHOW TO false.
set mark_dv:SHOW TO false.
 
unlock throttle.
unlock steering.
 
SET thrott to 0.
PRINT "Are we in space?".
