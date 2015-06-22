run lib_common.
run lib_pid.
run lib_debug.
run lib_res.


brakes on.
global mode is "locate".

local allw is allwaypoints().
local i is 0.
local wp is ship:position.
local mark is ship:geoPosition.
local wpName is "".

function setWpFrom {
  set wp to allw[i]:position. 
  set wpName to allw[i]:name.
}

on ag1 { set i to i + 1. if ( i >= allw:length ) { set i to 0. }. setWpFrom. preserve. }
on ag2 { set i to i - 1. if ( i < 0 ) { set i to allw:length - 1. }. setWpFrom. preserve. }
on ag3 { 
  if ( mode <> "locate") {
    set mode to "locate".
    brakes on.
    set mark to ship:geoPosition.
  } else {
    set wp to mark:position.
    set mode to "route".
    set wpName to "cust".
    brakes off.
  }

  preserve. 
}

on ag4 { set minSpeed to minSpeed - 1. preserve. }
on ag5 { set minSpeed to minSpeed + 1. if ( minSpeed > maxSpeed ) { set maxSpeed to minSpeed. }. preserve. }

clearScreen.
///////012345678901234567890
print "mode:       ".
print "current wp: ".
print "wp dist: ".
print "srf. velocity: ".
print "throttle:      ".
print "steer err:  ".
print "steer:      ".


local cx is 15.

local minSpeed is 10.
local maxSpeed is 30.
local steerPID to PID_init( 0.01, 0.001, 0.005, -1, 1, 0.01 ).
local throttlePID to PID_init( 0.005, 0.01, 0.001, -1, 1, 0.01 ).
local wpVec is vecDrawArgs( v(0,0,0), v(0,0,0), rgb(1, 1, 0), "wp", 1, false).

set debug_vector[0]:label to "facing".
set debug_vector[0]:scale to 2.
set debug_vector[0]:show to true.

set debug_vector[1]:label to "wpdir".
set debug_vector[1]:scale to 2.
set debug_vector[1]:show to true.

if ( allw:length > 0 ) { 
  set wp to allw[0].
  brakes off.
}

// else locate new waypoint
local k is 1000. // how fast mark is moved.

until ( mode = "route" and (wp - ship:position):mag < 200) {
  local serr is getSteerErr().

  if ( mode = "route" ) {
    set ship:control:wheelsteer to PID_seek( steerPID, 0, serr ).

    if ( ship:surfaceSpeed < minSpeed ) {
      set ship:control:wheelthrottle to PID_seek( throttlePID, minSpeed, ship:velocity:surface:mag ).
    } else if ( ship:surfaceSpeed > maxSpeed ) {
      set ship:control:wheelthrottle to PID_seek( throttlePID, maxSpeed, ship:velocity:surface:mag ).
    } else {
      set ship:control:wheelthrottle to 0.
    }

    print round2((wp - ship:position):mag) + " m     " at (cx, 2).
  }

  
  if ( mode = "locate" ) {

    when mapview = true then {
      set k to .1.
    }

    when mapview = false then {
      set k to 1000.
    }
    
    if ( ship:control:pilotPitch <> 0 ) {
      set mark to latlng( mark:lat + ship:control:pilotPitch / k, mark:lng ).
    }

    if ( ship:control:pilotYaw <> 0 ) {
      set mark to latlng( mark:lat, mark:lng + ship:control:pilotYaw / k ).
    }

    // target vector
    local tv is (mark:position - body:position).
    // height vector
    local hv is tv.

    // display mark
    if ( mapview ) {
      set hv to tv * 1.05.
    } else {
      set hv to tv + 2 * tv:normalized.
    }

    set wpVec:vector to hv - tv.
    set wpVec:start to mark:position.
    set wpVec:show to true.

    print round2((mark:position - ship:position):mag) + " m     " at (cx, 2).
  }

  print mode + "     " at( cx, 0 ).
  print wpName at (cx, 1).

  print minSpeed + " < " + round2(ship:velocity:surface:mag) + " m/s < " + maxSpeed + "   " at (cx, 3).
  print "     " at (cx, 4).
  print round2(ship:control:wheelthrottle) at (cx, 4).
  drawBar( cx + 6, 4, -1, 1, ship:control:wheelthrottle).
  print round2(serr) + "      " at (cx, 5).
  print "     " at (cx, 6).
  print round2(ship:control:wheelsteer) at (cx, 6).
  drawBar( cx + 6, 6, -1, 1, ship:control:wheelsteer).
  
  wait 0.1.

  when getElectric():amount < 200 then {
    set mode to "powersave".
    set ship:control:wheelthrottle to 0.
    brakes on.
  }

  when mode = "powersave" and ship:surfaceSpeed < 1 then {
    //retract
    set myPartList to ship:partsTagged("powersave").
    for p in myPartList {
      p:getModule("ModuleDeployableSolarPanel"):doevent( "Extend Panels" ).
    }

    shutdown.
  }

  when mode = "powersave" and getElectric():amount = getElectric():capacity then {
      set myPartList to ship:partsTagged("powersave").
    for p in myPartList {
      p:doevent( "Retract Panels" ).
    }

    brakes off.
    set mode to "route".
  }

}

function getSteerErr {
  local sv is vxcl(up:vector, facing:vector).
  local dv is vxcl(up:vector, (wp - ship:position)).
  set debug_vector[0]:vector to sv.
  set debug_vector[1]:vector to dv:normalized.


  local res is vang( sv, dv ).

  if ( vang( dv, facing:rightvector ) > 90 ) {
    set res to -res.
  }

  return res.
}

set ship:control:wheelthrottle to 0.
brakes on.
