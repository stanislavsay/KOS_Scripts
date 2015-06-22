LOCAL start_facing IS SHIP:FACING.

// Set a global base altitude so we know when we've landed.
GLOBAL base_altitude IS ALT:RADAR.

// Create a new radar altitude algorithm which takes this in to account.
FUNCTION radar_altitude {
	RETURN ALT:RADAR - base_altitude.
}.

LOCK STEERING TO start_facing.
PRINT "IGNITION".
LOCK THROTTLE TO 1.
STAGE.
WHEN ALT:RADAR > 1 THEN {
    PRINT " !!! LIFTOFF !!! ".
}.
