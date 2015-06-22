run lib_common.
run lib_vessel.
run lib_debug.
set v3:show to true.
set v3:label to "up".
set v3:scale to 5.

set v4:show to true.
set v4:label to "crs up and facing:right".
set v4:scale to 5.

local g to body:mu / body:radius ^ 2.

until false {
	
	clearscreen.

  //print "Total thrust = " + totalThrust.
  print "Acceleration = " + readAcc().
  print "Drag = " + getDrag().
	print "Terminal velocity = " + getTermVel().
  print "Suicide dist = " + round2( ship:airSpeed^2 / ( 2 * g * twr ) ).
  print "Fore prograde = " + getForeErr(ship:velocity:surface).
  print "Star prograde = " + getStarErr(ship:velocity:surface).

  set v3:vector to up:vector.
  set v4:vector to vcrs( up:vector, facing:rightVector ).
  wait 1.

}
// project to eliptic
//local d is 0.
//global head is 0.
//lock d to vxcl( up:vector, srfretrograde:vector ).
//lock head to arccos( vdot(d,north:vector) / sqrt ( vdot( d, d ) * vdot( north:vector, north:vector )) ).
//lock steering to angleAxis(45, srfretrograde:rightvector) * srfretrograde.
//wait 50.
//print head.