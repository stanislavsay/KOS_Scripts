
DECLARE PARAMETER MODE.

IF MODE = "INIT" {
  SET NAV_MODE TO "OFF".

  PRINT "NAVIGATION COMPUTER INITIALIZED".
}
ELSE IF MODE = "OFF" {
  SET NAV_MODE TO "OFF".
  SET NAV_TARGET TO SHIP.

  PRINT "NAVIGATION COMPUTER OFF".
}
ELSE IF MODE = "HOLD-POSITION" {
  SET NAV_MODE TO "HOLD-POSITION".
  SET NAV_TARGET TO SHIP.

  PRINT "SWITCHING NAVIGATION COMPUTER TO HOLD POSITION".
} ELSE IF MODE = "TARGET" {
  SET NAV_MODE TO "TARGET".
  SET NAV_TARGET TO TARGET.

  PRINT "SWITCHING NAVIGATION COMPUTER TO PURSUE TARGET".
}

PRINT "TARGET IS " + NAV_TARGET:NAME.
