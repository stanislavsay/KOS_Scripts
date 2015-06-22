@LAZYGLOBAL off.

function getClosestWaypoint {
	local allw is allwaypoints().
  if ( allw:length = 0 ) {
    print "no waypoints".
    return false.
  }

  local d is (ship:position-allw[0]:position):mag.
  local closest is allw[0].

  for w in allw {
      if (ship:position-w:position):mag < d {
        set d to (ship:position-w:position):mag.
        set closest to w.
      }
  }

  return closest.
}
