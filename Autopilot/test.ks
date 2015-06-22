
sas on.
local myTh is 0.
local prevTh is 0.

lock throttle to myTh.

checkStage().

local targetVel is 100.


until false {
  local P is (targetVel - ship:airspeed).
  local D is ( P - prevTh ).
  set prevTh to P.
  set myTh to myTh + 0.1*D.
  checkStage().
  wait 0.1.
}

unlock throttle.

function checkStage {
  local engs is list().
  list engines in engs.

  for e in engs {
    if ( e:flameout ) {
      stage.
      break.
    }
  }

  if ( ship:availableThrust = 0 ) {
    stage.
  }

}
