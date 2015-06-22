
DECLARE PARAMETER MODE.
DECLARE PARAMETER PARAM.

IF MODE = "INIT" {
  SET DESCENT_SPEED_GOAL TO 0.
  SET DESCENT_SPEED_FUZZ TO 1.
  SET ALTITUDE_GOAL TO 0.

  PRINT "DESCENT COMPUTER INITIALIZED".
}
ELSE IF MODE = "ALTITUDE-GOAL" {
  SET ALTITUDE_GOAL TO PARAM.

  IF PARAM < 0.01 {
    PRINT "CONFIGURING DESCENT COMPUTER FOR SURFACE LANDING".
  }
  ELSE {
    PRINT "CONFIGURING DESCENT COMPUTER FOR HOVER AT " + ALTITUDE_GOAL + " METERS".
  }
}