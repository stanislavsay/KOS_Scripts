run lib_PID.
run lib_common.
run lib_vessel.
run lib_handling.

declare parameter hoverAlt.
if ( hoverAlt = 0 ) { set hoverAlt to 100. }

local alterr is 0.

// ship has a size. alt radar counts from center of mass. 
// so, gears can be 9m below of alt:radar.
if ( status = "LANDED" or status = "SPLASHED" or status = "PRELAUNCH" ) {
  set alterr to alt:radar.
}

clearScreen.
//sas on.
if( ship:availableThrust = 0 ) {
  //set ship:control:mainthrottle to 0.
  stage.
}

local dT is 0.1.

local g to body:mu / body:radius ^ 2.
local hoverTh to 0.
lock hoverTh to ship:mass * g / (ship:availablethrust/2).

local hovPID to PID_init( 0.1, 0, 0.05, -50, 50, 0.001 ).
//local velPID to PID_init( 0.01, 0.1, 0.5, -g, ma, 0.01 ).
local accPID to PID_init( 0.125, 0.05, 0.1, 0, 1, 0.01 ).

local pitchPID to PID_init( 1, 0.1, -0.1, -1, 1, 0.001 ).
local rollPID to PID_init( 1, 0.01, -0.1, -1, 1, 0.001 ).
local yawPID to PID_init( 0.01, 0.01, 0.5, -1, 1, 0.01 ).
local breakHover is false.

on ag1 { set hoverAlt to hoverAlt - 1. set hovPID[7] to 0. preserve. }
on ag2 { set hoverAlt to hoverAlt + 1. set hovPID[7] to 0. preserve. }
on ag3 { set hoverAlt to hoverAlt - 5. set hovPID[7] to 0. preserve. }
on ag4 { set hoverAlt to hoverAlt + 5. set hovPID[7] to 0. preserve. }
on ag5 { set breakHover to true. }

local myTh is hoverTh.
lock throttle to myTh.

local g to body:mu / body:radius ^ 2.
local a to g * twr.
local ma to a - g.

until breakHover {
  local startLoop is time:seconds.
  local sideErr to getSideErr().
  local pitchErr to getPitchErr().
  if (ship:surfaceSpeed > 1 ) {
    local yawErr to getYawErr().
  }

  //set ship:control:pilotmainthrottle to PID_seek( hovPID, hoverAlt, alt:radar ).

  local vel is PID_seek( hovPID, hoverAlt, alt:radar-alterr ).
  setMinMax( accPID, -hoverTh, (1-hoverTh) ).
  set myTh to hoverTh + PID_seek( accPID, vel, ship:verticalSpeed ).
  stabilize().
  //set myTh to PID_seek( accPID, acc, readVertAcc() ).
  //set ship:control:pitch to pitchErr.

  print "Alt  = " + round(alt:radar-alterr) + " / " + hoverAlt + " m. (dT= " + dT + "s)" at (0, 0).
  //print "throttle  = " + round2(ship:control:mainthrottle) + "    " at (0, 1).
  print "throttle  = " + round2(myTh) + "    " at (0, 1).
  print "vel  = " + round2(vel) + "    " at (0, 2).
  //print "acc  = " + round2(acc) + "    " at (0, 3).

  print "pitchErr  = " + round2(pitchErr) + "  " at (0, 5).
  print "control pitch = " + round2(ship:control:pitch) + "  " at (0, 6).

  print "sideErr   = " + round2(sideErr) + "  " at (0, 7).
  print "control roll = " + round2(ship:control:roll) + "  " at (0, 8).

  local sy is 11.
  for w in ALLWAYPOINTS() {
    print w:name + " " + round2((w:position - ship:position):mag) + " m" at ( 0, sy ).
    set sy to sy + 1.
  }

  //SET SHIP:CONTROL:NEUTRALIZE to TRUE.
  if ( time:seconds - startLoop ) > dT { set dT to time:seconds - startLoop. }
  wait dT.
}
unlock throttle.
set ship:control:mainthrottle to hoverTh.

function stabilize {
  if ( rcs ) {
    stabByRCS().
  }
}

function getPitchErr {
  //local facVec is vxcl( up:vector, facing:foreVector ).
  local proVec is vxcl( up:vector, vxcl( facing:rightVector, srfPrograde:vector )).
  local angVelVec is vxcl( up:vector, vxcl( facing:vector, ship:angularVel )).

  //set drawVec1:vector to proVec.
  //set drawVec2:vector to angVelVec.

  local res is proVec:mag.
  if vang( facing:foreVector, proVec ) > 90 {
    set res to -res.
  }

  local res2 is ship:angularVel:y.

  //print "res = " + round2(res) + "  " + ship:angularMomentum + "  " at (0, 9).

  return res.// + 5*res2.
}

function getYawErr {
  //local facVec is vxcl( up:vector, facing:foreVector ).
  //local proVec is vxcl( up:vector, srfPrograde:vector ).
  local dirVec is vxcl( facing:vector, srfPrograde:vector ).
  //local d is rotateFromTo(facVec, proVec).

  local res to vang(facing:vector, vxcl( facing:topvector, srfPrograde:vector)).
  // if on left side do it -0..-180
  if vang( facing:rightVector, dirVec ) < 90 { // we are facing  left of prograde
    set res to -res.
  }
  //print round2(res) + " "  at (0,9).
  return res.
}

// trying to reduce side vel
function getSideErr {

  local proVec is vxcl( up:vector, vxcl( facing:vector, srfPrograde:vector )).
  local res to proVec:mag.
  if vang( facing:rightVector, proVec ) < 90 { // we are facing  left of prograde
    set res to -res.
  }

  return res.
}
