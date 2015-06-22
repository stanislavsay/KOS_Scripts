// Auto-manage gear in a very basic way.

DECLARE FUNCTION gear_up {
    PRINT "Retract landing struts.".
    GEAR OFF.
    WHEN radar_altitude() < 50 THEN gear_down().
}

DECLARE FUNCTION gear_down {
    PRINT "Deploying landing struts.".
    GEAR ON.
    WHEN radar_altitude() > 75 THEN gear_up().
}

// Initialize the script with struts deployed.
WHEN radar_altitude() > 75 THEN gear_up().
