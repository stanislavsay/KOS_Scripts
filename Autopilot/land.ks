//ALT:RADAR
declare parameter waypoint.

run lib_common.
run lib_PID.
run lib_staging.
run lib_vessel.
run lib_nav.
run lib_handling.

local g to body:mu / body:radius ^ 2.
local a to g * (twr/2).
local ma to a - g.

print "body g = " + g.
print "a = " + a.
print "max a = " + ma.

if waypoint <> 0 {
    set waypoint to getClosestWaypoint().
    print "waypoint = " + waypoint:name.
    print "burn dist = " + ship:velocity:surface:mag^2 / ( 2 * g * twr ).
}

local verPID to PID_init( 0.1, 0.01, 0.001, 0, 1, 0.001 ).
local horPID to PID_init( 0.1, 0.01, 0.001, 0, 1, 0.001 ).
local horPitchPID to PID_init( 0.1, 0.01, 0.001, -90, 90, 1 ).
local hoverAlt is 5.
local targetVel is 0.

print "taking controls".
local myTh is 0.
lock throttle to myTh.

sas off.


when (ship:velocity:surface:mag < 5) then { rcs on. }

local dT is 0.1.

local pitch is getLandPitchErr().

if ( ship:surfaceSpeed > 2 ) {
    local targetFacing is srfretrograde.
    // get pitch from surface retrograde projected to horizontal plane
    lock targetFacing to srfretrograde * r(pitch, 0, 0).
    lock steering to srfretrograde * r(pitch, 0, 0).
    wait until abs(targetFacing:pitch - facing:pitch) < 0.1 and 
      abs(targetFacing:yaw - facing:yaw) < 0.1.
} else {
    lock steering to up.
}

if waypoint <> 0 {
    wait until (ship:position-waypoint:position):mag <=
        ship:velocity:surface:mag^2 /
            ( 2 * (body:mu / body:radius ^ 2) * twr ).
    set warp to 0.
}

clearScreen.
print " ".
print "twr      = ". //(0,1)
print "alt      =         m".
print "v. speed =         m/s".
print "h. speed =         m/s".
print "target vs=         m/s".
print "throttle = ".
print "pitch    = ".
print "burnDist = ".
print "yaw err  = ".
print "pitch err= ".
local tx is 12.

until ship:surfaceSpeed < 2 {
    print "kill horizontal              " at ( 0, 0 ).
    set targetVel to sqrt( 2 * ma * abs((alt:radar - hoverAlt)) ) * 0.75.
    local ipitch to getLandPitchErr().
    //if (abs(ship:verticalSpeed) > targetVel) {

    if( ship:verticalSpeed < 0 ) {
        print "hover" at ( 18, 0 ).
        set pitch to ipitch - PID_seek( horPitchPID, 0, ship:verticalSpeed ).
    } else {
        set pitch to ipitch.
    }

        // -10 < -100?
    if -targetVel < ship:verticalSpeed {
        print " full " at (tx + 5, 0).
        //set myTh to PID_seek( horPID, 0, abs(ship:surfaceSpeed) ).
        set myTh to 1.
    } else {
        print " hovering " at (tx + 5, 0).
        set myTh to PID_seek( verPID, -targetVel, ship:verticalSpeed ).
    }

    print round2(twr) at( tx, 1 ).
    print round2(alt:radar - hoverAlt) at( tx, 2 ).
    print round2(ship:verticalSpeed) at( tx, 3 ).
    print round2(ship:surfaceSpeed) at( tx, 4 ).
    print round2(targetVel) at( tx, 5 ).
    print round2(myTh) at( tx, 6 ).
    print round2(pitch) at( tx, 7 ).
    //  print round2(burnDist)  + " m    " at( tx, 8 ).
}

lock steering to up.

until status = "LANDED" or status = "SPLASHED" {
    local startLoop is time:seconds.
    // kill horiz velocity

    //local burnTime to ship:velocity:surface:mag / ma ^ 2.
    //local burnDist to ship:velocity:surface:mag * burnTime / 2.
    local v is ship:velocity:surface:mag.
    local burnDist to v^2 / ( 2 * ma ).
    //set targetVel to (alt:radar - burnDist).
    set targetVel to sqrt( 2 * ma * abs((alt:radar - hoverAlt)) ).

    local horVel is vxcl( north:vector, ship:velocity:surface ).
    

    print "landing...                " at( 0, 0 ).
    //set pitch to 90.

    set myTh to PID_seek( verPID, -targetVel, ship:verticalSpeed ).
    //set ship:control:translation to v( getForeErr(ship:velocity:surface), getStarErr(ship:velocity:surface), 0 ):normalized.
    //print round2(getStarErr(ship:velocity:surface)) at( tx, 9 ).
    //print round2(getForeErr(ship:velocity:surface)) at( tx, 10 ).
    stabByRCS().

    

    print round2(twr) at( tx, 1 ).
    print round2(alt:radar - hoverAlt) at( tx, 2 ).
    print round2(ship:verticalSpeed) at( tx, 3 ).
    print round2(ship:surfaceSpeed) at( tx, 4 ).
    print round2(targetVel) at( tx, 5 ).
    print round2(myTh) at( tx, 6 ).
    print round2(pitch) at( tx, 7 ).
    print round2(burnDist)  + " m    " at( tx, 8 ).
    //checkStages().
    //set v1:vector to (targetFacing):vector.
    if ( time:seconds - startLoop ) > dT { set dT to time:seconds - startLoop. }
    wait dT.
}

print "Touchdown".
lock steering to up.
rcs on.
sas on.
until myTh > 0 {
    set myTh to myTh - 0.01.
    wait 0.5.
}
unlock throttle.
wait 5.
unlock steering.


// how retrograde vertical and horiz relates
function getLandPitchErr {
    //local hVec to vxcl(up:vector, srfretrograde:forevector).
    //local vVec to vxcl(north:vector, srfretrograde:forevector).
    local hVec to vxcl(up:vector, ship:velocity:surface).
    local vVec to vxcl(hVec, ship:velocity:surface).

    //set v1:vector to hVec.
    //set v2:vector to vVec.

    //from srfretrograde. not from zenith.
    local res is arctan(vVec:mag/hVec:mag).

    if ( vang( up:vector, vVec ) > 90 ) {
        set res to -res.
    }
    return res.
}
