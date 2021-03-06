
DECLARE PARAMETER MODE.

IF MODE = "INIT" {
  SET THROTTLE_MODE TO "MANUAL".

  SET THROTTLE_GOAL_MODE TO FALSE.
  SET THROTTLE_GOAL_MINIMUM TO 0.
  SET THROTTLE_GOAL_MAXIMUM TO 1.
  SET THROTTLE_GOAL_INPUT TO 0.

  SET THROTTLE_TWR_SAFETY TO FALSE.
  SET THROTTLE_STAGE_SAFETY TO FALSE.

  SET THROTTLE_LOCK TO 0.

  PRINT "THROTTLE COMPUTER INITIALIZED".
}

ELSE IF MODE = "AERODYNAMIC" {
  SET THROTTLE_MODE TO "AERODYNAMIC".
  PRINT "SWITCHING THROTTLE COMPUTER TO AERODYNAMIC MODE".
}

ELSE IF MODE = "DESCENT" {
  SET THROTTLE_MODE TO "DESCENT".
  PRINT "SWITCHING THROTTLE COMPUTER TO DESCENT MODE".
}

ELSE IF MODE = "TIME_APOAPSIS" {
  SET THROTTLE_MODE TO "TIME_APOAPSIS".
  SET TIME_APOAPSIS_SAFETY_MARGIN TO 1.1.
  PRINT "SWITCHING THROTTLE COMPUTER TO PRECISE TIME/APOAPSIS MODE".
}

ELSE IF MODE = "TIME_APOAPSIS_10X" {
  SET THROTTLE_MODE TO "TIME_APOAPSIS".
  SET TIME_APOAPSIS_SAFETY_MARGIN TO 10.
  PRINT "SWITCHING THROTTLE COMPUTER TO FUZZY TIME/APOAPSIS MODE".
}

ELSE IF MODE = "MANUAL" {
  SET THROTTLE_MODE TO "MANUAL".
  PRINT "SWITCHING THROTTLE COMPUTER TO MANUAL".
}

ELSE {
  PRINT "UNRECOGNIZED THROTTLE MODE: " + MODE.
}