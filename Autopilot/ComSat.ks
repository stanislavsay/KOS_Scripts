declare parameter orbAlt.
SET orbAltGS TO 2868750.
run lib_common.
run lib_PID.
run lib_staging.
run lib_warp.
run lib_node.
run lib_vessel.

if ( orbAlt = 0 ) { set orbAlt to 2868750. }
local densAlt is 12500. // for Kerbin

local logFile to "orbit.csv".
local orbVelocity to sqrt(ship:body:mu/(ship:body:radius + orbAlt)).

log "Running into orbit " + orbAlt + "m, vel = " + orbVelocity to logFile.
log "Alt; termVel; ship:airSpeed; ship:surfaceSpeed; targetVerticalSpeed; myTh; vertAcc; newPitch" to logFile.

 // Kp, Ki, Kd, min, max control  range vals.
local atmoPID to PID_init( 0.05, 0.01, 0.001, 0, 1, 0.001 ).
local gravPID to PID_init( 0.005, 0.01, 0.001, 0, 1, 0.01 ).
local period is 0.1.

local targetVerticalSpeed is 0.
local vertAcc is 0.
local termVel is 0.
local gravAlt is 0. // when gravity turn starts
 
lock targetVerticalSpeed to orbVelocity * (orbAlt - ship:altitude) / orbAlt.

print "target orbit = " + orbAlt.
print "target velocity = " + orbVelocity.
local thrustDir is getThrustDirection().
local facingErr is rotateFromTo(up:vector, facing:vector).

//local dv is vecDrawArgs(v(0,0,0), thrustDir:vector, red, "thrustDir", 20, true).
//local dv2 is vecDrawArgs(v(0,0,0), facing:vector, yellow, "facing", 20, true).
//local dv3 is vecDrawArgs(v(0,0,0), facingErr:vector, green, "facingErr", 20, true).
//local dv4 is vecDrawArgs(v(0,0,0), (facingErr * heading(90, 90)):vector, blue, "stering", 50, true).

print facingErr:vector.

local myTh to 0.
local hpitch is 0.
local newPitch is 90.

print "taking controls".
// controls
sas on.
set ship:control:pilotmainthrottle to 0.

lock throttle to myTh.
lock steering to (facingErr * heading(90, 90-hpitch) + R(0, 0, 270)).
print ship:status.
if ( ship:status = "PRELAUNCH" or ship:status = "LANDED" ) {
  local countDown is 5.
  until countDown <= 0 {
    print countDown + "...".
    set countDown to countDown - 1.
    wait 1.
  }

  //ignition
  until ship:availablethrust > 0 {
    wait 0.5.
    stage.
  }.
}


if ( ship:altitude < densAlt ) {
  print "ignition".
  set myTh to 1.
  until readAcc() > 0 and ship:verticalSpeed > 30 {
    wait .1.
  }
  set mode to "low ascent".
}

when termVel > targetVerticalSpeed or ship:altitude > densAlt or ship:apoapsis > orbAlt / 2 then {
  set mode to "gravity turn".
  set gravAlt to ship:altitude.
}

local prevTermVel is 0.

clearScreen.
print "mode:                  ". 
print "drag:                  ". // 1
print "terminal speed:        ". // 2
print "air speed:             ". // 3
print "surface speed:         ". // 4
print "target vertical speed: ". // 5
print "vertical acceleration: ". // 6
print "    angle of attack:   ". // 7
///////012345678901234567890123
local tx is 23.

until ship:apoapsis > orbAlt {

  //set termVel to getTermVel().
  //set dv4:vector to (facingErr * heading(90, 90-hpitch)):vector.
  set vertAcc to readVertAcc().
  set termVel to getTermVel() * 3.
  set termAcc to (termVel - prevTermVel) / period.
  set prevTermVel to termVel.
  local shipAcc to readAcc().
  //local targetAcc to (min(termVel, orbVelocity) - ship:airspeed) / period.
  local newTh to PID_seek( atmoPID, min(termVel, orbVelocity), ship:airspeed ).
  //local newTh to PID_seek( atmoPID, termAcc, shipAcc ).

  //ship:verticalspeed
  print mode at (tx, 0).
  print round2(getDrag()) at (tx, 1).
  
  //print "P: " + atmoPID[6] + " I: " + atmoPID[7] + " D: " + atmoPID[8].
  print round2(termVel) + " m/s " at (tx, 2).
  print round2(ship:airSpeed) + " m/s " at (tx, 3).
  print round2(ship:surfaceSpeed) + " m/s " at (tx, 4).
  print round2(targetVerticalSpeed) + " m/s " at  (tx, 5).
  print round2(vertAcc) + " m/s^2 " at (tx, 6).
  print round2(angle_of_attack()) + "  " + round2(max_aoa(termVel)) + " " at (tx, 7).
  

  if ( mode = "gravity turn" ) {

    set newPitch to apoapsis * 90 / orbAlt.

    if ( angle_of_attack() < max_aoa(termVel) ) {
      if ( newPitch - hpitch > 1 ) {
        set hpitch to hpitch + (newPitch - hpitch)/abs(newPitch - hpitch)/2.
      } else {
        set hpitch to newPitch.
      }
      print "   " at (0, 7).
    } else {
      print "AoA" at (0, 7).
    }

    print "Pitch control: " + round2(apoapsis) + " -> " + round2(orbAlt) + " : " + round2(90-newPitch) + 
     " " + round2(hpitch) + "         " at (0, 9).    

  } else {
    print "Throttle control: " + round2(shipAcc) + " -> " + round2(termAcc) + " : " + round2(newTh) + "        " at (0, 8).
  }

  set myTh to newTh.//myTh + (newTh - myTh) / 10.

  log ship:altitude + "; " + termVel + "; " + 
    ship:airSpeed + "; " + ship:surfaceSpeed + "; " + 
    targetVerticalSpeed + "; " + myTh + "; " + 
    vertAcc + "; " + newPitch to logFile.
  if ( checkStages() > 0 ) {
    // zero integral error
    set atmoPID[7] to 0.
    set gravPID[7] to 0.
  }
  wait period.
}

unlock throttle.
set ship:control:pilotmainthrottle to 0.

print "circularize".
set mode to "circularize".
createNodeAtApo(orbAlt).
//PRINT "Low orbit".
//PRINT "Now lift orbit to GeoSync altitude".
//createNodeAtApo(orbAltGS).
//execNode().
WAIT 3.
AG4 ON. //Fairing jettison
PRINT "Fairing jettison!".
WAIT 3.
AG1 ON. // Deploy Solar panels and VODA-Backup antenna
PRINT "Services deployed".
WAIT 1.
AG3 ON. // Undock launcher
PRINT "Luncher undocked. Good luck!".
WAIT 1.
print "Mission Complete. Sattelite on GeoSync orbit".
PRINT "Now destroy Luncher on low orbit".
LOCK STEERING TO RETROGRADE.
LOCK Throttle TO 1.

function max_aoa {
  declare parameter termVel.
  if ( ship:body:atm:exists and ship:altitude < ship:body:atm:height ) {
  // if ship:vel ~= termVel max aoa ~= 1
    return max( 1, min(90, (termVel/ship:airSpeed-1)*90)).
  }

  return 360.
}

//when angle_of_attack() > 10 then {
//  set mode to "Stabilization manevuer".
//  lock throttle to 0.
//  lock STEERING to ship:srfprograde:vector.
//}

//when angle_of_attack() < 5 then {
//  lock throttle to myTh.
//  LOCK STEERING TO heading(90, hpitch).
//}
//unlock throttle.

