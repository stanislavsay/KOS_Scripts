run lib_common.

//local v1 is vecdrawArgs( v(0,0,0), v(0,0,0), rgb(1,1,0), "velocity", 1, false).
//local v2 is vecdrawArgs( v(0,0,0), v(0,0,0), rgb(0,1,0), "projection", 1, false).
//local v3 is vecdrawArgs( v(0,0,0), v(0,0,0), rgb(0,1,1), "fore", 1, false).
//local v4 is vecdrawArgs( v(0,0,0), v(0,0,0), rgb(.1,.1,.1), "facing:rightVector", 3, true).
//local v5 is vecdrawArgs( v(0,0,0), v(0,0,0), rgb(0, 0, 1), "side", 1, false).
//local v6 is vecdrawArgs( v(0,0,0), v(0,0,0), rgb(0,.1,.1), "vcrs", 3, true).

function stabByRCS {

	local foreAxis is -vcrs(facing:vector, facing:rightVector).
	local vel is vxcl( facing:vector, ship:velocity:surface ).
	local foreVec is vxcl( facing:rightVector, vel ).
	local sideVec is vxcl( foreVec, vel ).
	local foreErr is foreVec:mag.
	
  // if on left side do it -0..-180
  if vang( foreAxis, vel ) > 90 { // we are facing  left of prograde
    set foreErr to -foreErr.
  }

  local sideErr to sideVec:mag.
  if vang( facing:rightVector, vel ) < 90 { // we are facing  left of prograde
    set sideErr to -sideErr.
  }
  
  local err is v( sideErr, foreErr, 0 ).
	if( err:mag < 1 ) {
		set err to err / 10.
	}
	
  set ship:control:translation to err.
}

function stab {
  HUDText( "Stabilization", 10, 4, 40, yellow, true).
  sas on.
  SET arwangularMomentum TO VECDRAW().
  
  SET arwangularMomentum:SHOW TO true.
  set arwangularMomentum:color to rgb(0, 1, 0).
  until ship:angularMomentum:mag < 0.5 and ship:angularVel:mag < 0.05 {
    print "angular momentum = " + ship:angularMomentum:mag.
    print "angular vel = " + ship:angularVel:mag.
    set arwangularMomentum:vec TO ship:angularVel * 25.
    wait 0.5.
  }
  HUDText( "Stabilization done", 1, 4, 40, green, true).
  sas off.
}

function rotate {
	declare parameter dir.
  stab().
  local croll is 0.
  lock croll to (facing - dir):roll.
  print croll.
  // roll to half

  local hroll is croll / 2.
  print hroll.
  print "acc".
  until abs(croll) < abs(hroll) {
    local d is abs(croll - hroll).
    print croll + " / " + hroll + ". " + d/hroll.
    set ship:control:roll to d/hroll/10. // -1 , 1
    wait 0.01.
  }

  print "dec".
  until abs(croll) < 0.05 {
    local d is abs(croll - hroll).
    print croll + " / " + hroll + ". " + d/hroll.
    set ship:control:roll to -d/hroll/10. // -1 , 1
    wait 0.01.
  }

  set ship:control:roll to 0.
  sas on.
  print "Current rotation: " + croll.
}

function point {
  declare parameter dir.
  stab().
  local cdiff is 0.
  local angdiff is 0.
  local dp is 0.
  local dy is 0.
  local arwMult is 20.
  local logFile is "rot.csv".
  lock cdiff to dir:vector - facing:vector.

  lock dp to vxcl( facing:rightvector , dir:forevector ):normalized.
  lock dy to vxcl( facing:upvector, dir:forevector ):normalized.

  //local arwFacing is vecDraw().
  //set arwFacing:color to rgb(0, 1, 0).
  //set arwFacing:show to true.
  //set arwFacing:vec to dy*arwMult.

  lock angDiff to vang(facing:vector, dir:vector).
  local angHalf to angDiff / 2.

  //log "x; y; z; pitch; yaw; roll; res yaw; res pitch" to logFile.

  until angDiff < 0.5 {

    local handling to v(0, 0, 0).
    CLEARSCREEN.

    local pitcherr to facing:rightvector * vcrs( dp, facing:forevector ).
    local yawerr to facing:upvector * vcrs( facing:forevector, dy ).
    print "cross pitch: " + vcrs( dp, facing:forevector ):mag.
    print "cross yaw  : " + vcrs( facing:forevector, dy ):mag.
    print "err pitch  : " + pitcherr.
    print "err yaw    : " + yawerr.
    print "momentum   : " + (ship:angularMomentum / ship:mass).
    print "ang velo   : " + (ship:angularVel).
    //set yawerr to arcsin (yawerr).

    // deal with angles more than 90 deg off.
    //if ( facing:forevector * dy < 0 ) {
    //  local sign to yawerr / abs (yawerr).
    //  set yawerr to sign*180 - yawerr.
    //}

    set handling:x to yawerr/abs(yawerr).
    set handling:y to pitcherr/abs(pitcherr).
    local k is (abs(angDiff)/angHalf-1).
    set handling to handling * k.

    //set ship:control:rotation to handling.



    //
    print round2(angHalf) + "/" + round2(angDiff) + "= " + round2(k) + 
      " yaw: " + round2(handling:x)  + " pitch: " + round2(handling:y) at (0, 20).
    

    wait 0.01.
    //log cdiff:x + "; " +
    //  cdiff:y + "; " +
    //  cdiff:z + "; " +
    //  cdiff:direction:pitch +"; " + cdiff:direction:yaw + "; " + cdiff:direction:roll +
    //"; " + resY + "; " + resP to logFile.
  }


  set ship:control:vector to v(0, 0, 0).
  sas on.
  print "Current diff: " + cdiff.

}
