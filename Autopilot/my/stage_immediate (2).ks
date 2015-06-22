IF STAGE:SOLIDFUEL > SRB_FUEL_BASELINE {
  SET SRB_FUEL_BASELINE TO STAGE:SOLIDFUEL.
}

IF STAGE:LIQUIDFUEL > LIQUID_FUEL_BASELINE {
  SET LIQUID_FUEL_BASELINE TO STAGE:LIQUIDFUEL.
}

IF STAGE:SOLIDFUEL < SRB_FUEL_BASELINE / 4 {
  PRINT "SRB SEP ARMED".
}

IF STAGE:LIQUIDFUEL < LIQUID_FUEL_BASELINE / 4 {
  PRINT "STAGE SEP ARMED".
}

IF STAGE:SOLIDFUEL < 0.1 AND SRB_FUEL_BASELINE > 0.1 {
  PRINT "SRB SEP".
  PRINT "IMMINENT".
  LOCK THROTTLE TO 0.1.
  WAIT 0.5.
  PRINT "NOW".
  IF ABORT {
    PRINT "ABORT MODE DETECTED - UNSAFE TO STAGE".
  }
  ELSE {
    STAGE.
    PRINT "STANDBY".
    WAIT 5.
    UNLOCK THROTTLE.
  }

  SET SRB_FUEL_BASELINE TO 0.
}

IF STAGE:LIQUIDFUEL < 0.1 AND LIQUID_FUEL_BASELINE > 0.1 {
  PRINT "STAGE SEPARATION".
  PRINT "IMMINENT".
  LOCK THROTTLE TO 0.
  WAIT 0.5.
  PRINT "NOW".
  IF ABORT {
    PRINT "ABORT MODE DETECTED - UNSAFE TO STAGE".
  }
  ELSE {
    STAGE.
    PRINT "STANDBY".
    WAIT 10.
    UNLOCK THROTTLE.
  }

  SET LIQUID_FUEL_BASELINE TO 0.
}

// I use long variables to avoid reference to others
LIST ENGINES in myEngines.
for shipEngine in myEngines {
  if ( shipEngine:flameout ) {
    set currentStage to shipEngine:stage.
      set parentPart to shipEngine.
      set foundDecoupler to false.

    until not(parentPart:hasparent) {
      if (
        parentPart:modules:contains("ModuleAnchoredDecoupler") and
        parentPart:stage = shipEngine:stage - 1 
      ) {
        print "found for " + shipEngine + " dec " + parentPart.
        set foundDecoupler to true.
        break.
      }

      set parentPart to parentPart:PARENT.
    }

    if ( foundDecoupler ) { 
      print "stage flameout engines!".
      stage.
    }
  }
  //print e:stage + " " + e:parent:parent:stage.
}



IF SHIP:LIQUIDFUEL > 0 AND STAGE:LIQUIDFUEL < 0.01 AND STAGE:SOLIDFUEL < 0.01 {
  PRINT "ENGINE START REQUIRED".
  STAGE.
  WAIT 1.5.
}