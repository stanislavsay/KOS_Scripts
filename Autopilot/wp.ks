//waypoints
run lib_common.
// show all waypoints as vector from center of body

local allw is allwaypoints().
local i is 0.
on ag1 { set i to i + 1. if ( i >= allw:length ) { set i to 0. }. preserve. }
on ag2 { set i to i - 1. if ( i < 0 ) { set i to allw:length - 1. }. preserve. }

//print allw[i].
clearScreen.
local v is vecDrawArgs(v(0,0,0), v(0,0,0), rgb(1,0,0), "", 1, true ).

until false {

  local w is allw[i].
  // from waypoint's body
  local wdir is w:position - w:body:position.
  local k is 2 * ship:body:position:mag / wdir:mag .

  set v:label to w:name.
  set v:vector to wdir.
  set v:start to w:body:position / k.
  set v:scale to k.
  print i + " / " + allw:length + " " + w:name + "             " at (0, 0).
  print " Body   = "  + w:body at (0, 1).
  print " Latitude  = " + round2(w:geoPosition:lat) + "  " at (0, 2).
  print " Longitude = " + round2(w:geoPosition:lng) + "  " at (0, 3).

  print " Ship Latitude  = " + round2(ship:geoPosition:lat) + "  " at (0, 4).
  print " Ship Longitude = " + round2(ship:geoPosition:lng) + "  " at (0, 5).

  print " Distance = " + round2((ship:position - w:position):mag) + " m  " at (0, 5).  
  //vecList:add(v).
  wait .5.
//}
}

