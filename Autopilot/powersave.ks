@LAZYGLOBAL off.

function powersave {
	global np is body("Sun"):position.
	lock steering to np.
	wait until abs(np:direction:pitch - facing:pitch) < 0.15 and abs(np:direction:yaw - facing:yaw) < 0.15.
	sas on.
  local ele is getElectric.
  if ( ele:amount <> ele:capacity ) {
    local elFlow is getEnergyInc.
    if ( elFlow > 0 ) {
      print "Power is enough to operate further.".
    } else {
      print "Lack of power, entering powersaving mode.".
      shutdown.
    }
  }
}

function getEnergyInc {
  local el1 is getElectric.
  wait 1.
  local el2 is getElectric.
  //if ( el2:amount > el1:amount and el1:amount <> el1:capacity) {
  return el2:amount - el1:amount.
}

function getElectric {
  //local res is .
  //list resources in res.
  for r in ship:resources {
    if ( r:name = "ELECTRICCHARGE") {
      return r.
    }
  }
  
  return.
}

powersave.
