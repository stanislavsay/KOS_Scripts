@LAZYGLOBAL off.
global angle_of_attack is 0.


local max_acceleration to ship:availablethrust / ship:mass.
local acceleration_due_to_gravity to 9.8 * ship:body:mu / kerbin:mu * (kerbin:radius / ship:body:position:mag)^2.
global twr to max_acceleration / acceleration_due_to_gravity.

local lastMeasureTime to 0.
local lastShipSpeed to 0.
local lastDrag to 0.
local cachedAcc to 0.

local gasSpecific is body:atm:sealevelpressure / 1.2230948554874.
function round2 {
  declare parameter value.
  return round(value*100)/100.
}

function drawBar {
  declare parameter sx.
  declare parameter sy.
  declare parameter minvalue.
  declare parameter maxvalue.
  declare parameter value.

  local w is terminal:width - sx-1.
  local x is 1.
  until x >= w {
    print "-" at (sx + x, sy).
    set x to x + 1.
  }

  print "+" at( sx + w*(-minvalue) / (maxvalue-minvalue), sy ).
  print "|" at ( sx, sy ).
  print "|" at( sx + w, sy ).
  local vx is w * (value-minvalue) / (maxvalue-minvalue).
  print "#" at ( sx + vx, sy ).
}

function drawVec{
  declare parameter label.
  declare parameter color.
  declare parameter scale.

  local vecd to vecDraw().
  set vecd:show to true.
  set vecd:scale to scale.
  set vecd:color to color.
  set vecd:label to label.
  return vecd.
}
