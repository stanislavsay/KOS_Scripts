CLEARSCREEN.
TOGGLE AG1. //Poweroff Cubesat.

SET apo TO 2868750. //Apoapsis var
SET inc TO 0. //Inclination var
SET err TO 0.
SET int TO 0.
SET tv TO 0.

PRINT "Launching CubeSat to Geosync orbit at 2868 km" AT (0,0).
PRINT "3" AT (0,1). WAIT .5. //Countdown
PRINT "2" AT (0,1). WAIT .5.
PRINT "1" AT (0,1). WAIT .5.
SAS ON. //SAS ON
SET f to 0. //flag
SET th TO 1. //throttle
SET tv TO 0. //thermal velocity
LOCK THROTTLE TO th. //Set full throttle
SET st TO HEADING (90 + inc ,88). //Start roll angle
STAGE. //stage launch enchancers
PRINT "Launch!                                                  " AT (0,1).
WAIT 1.
STAGE. //Run engines of first stage

UNTIL ALTITUDE > 200 {
	IF (VERTICALSPEED > 5 and f=0) {
		PRINT "Positive rate                                        " AT (0,1).
		SET f TO 1.
	}.
}.

SET f TO 0.
PRINT "200m, roll program                                       " AT (0,1).
LOCK STEERING TO st.
SAS OFF.
//PRINT "intelligent throttle" AT (0,1).
LOCK tv TO 2000. //SHIP:TERMVELOCITY.
UNTIL APOAPSIS > 9000 {

  PRINT "Stage fuel is: " + STAGE:LIQUIDFUEL AT (0,3).

  SET int TO int + err.
  SET err TO tv - AIRSPEED.
  IF int > 30 {SET int TO 30.}.
  IF int < -5 {SET int TO -5.}.
  SET th TO 0.2 * err + 0.02 * int.

  IF th < 1 AND f = 0 {
    //PRINT "max Q".
    SET f TO 1.
    }.
}.

SET s TO 50.
SET st TO heading(inc + 90, (40+s)).
PRINT "pitch program                                           " AT (0,1).
set f to 0.
UNTIL APOAPSIS > 45000 {
  IF ALTITUDE > 40000 AND f = 0 {
    SET f TO 1.
  }.

PRINT "Stage fuel is: " + STAGE:LIQUIDFUEL AT (0,3).

SET s TO ((45000 - APOAPSIS) / 2000).
IF s > 50 {set s to 50.}.
SET st TO HEADING(inc + 90, (40+s)).

set int to int + err.
set err to tv - airspeed.
if int > 30 {set int to 30.}.
if int < -10 {set int to -10.}.
set th to 0.2 * err + 0.02 * int.

if th < 1 and f = 0 {
    //print "max Q2".
    set f to 1.
}.
}.

PRINT "CubeSat APOAPSIS more them 45km. All system ok.             " AT (0,0).

lock st to prograde.
print "steering prograde                                        " AT (0,1).
set th to 1.
print "throttle to 100%                                         " AT (20,1).
until apoapsis > apo{
if altitude > 43800 and f = 0 {
    set f to 2.
		set th to 0.
		stage.
		wait .2.
}.
PRINT "Ship fuel is:     " + SHIP:LIQUIDFUEL AT (0,3).

UNTIL SHIP:liquidfuel > 3447 and f=1 {
//    set th to 0.
//    stage.
//    print "Staging".
//		set f to 2.
//    wait .2.
}.

set th to 1.
}.
set th to 0.
print "wait to ap".
set warp to 3.
set s to 2200.
set dv to s - velocity:orbit:mag.
set t to (mass * dv) / (maxthrust).
print "waiting: " + (eta:apoapsis - (t/2)) + "s".
until ( eta:apoapsis < ( t / 2)) {

set dv to s - velocity:orbit:mag.

set t to (mass * dv) / (maxthrust).
}.
set ecco to apoapsis - periapsis.
set warp to 0.
set th to 1.
wait .1.
set ecc to apoapsis - periapsis.
set err to 0.
set int to 0.
set tht to 1.
set th to tht.
set f1 to 0.
set f2 to 0.
until ((ecc - 50) > ecco) {
set ecco to ecc.

set dv to s - velocity:orbit:mag.

set t to (mass * dv) / (maxthrust).

set err to t - eta:apoapsis + 1.

set int to int + err.

if int > 15 {set int to 15.}.

if int < -5 {set int to -5.}.

set tht to 0.3 * err + 0.03 * int.

if t < 1 {

    set tht to .5.
    if f1 = 0 {
        set f1 to 1.
        print "less than 1s, finalizing burn".
    }.
}.

if verticalspeed < 0 {
    set tht to 1.
    if f2 = 0 {
        set f2 to 1.
        print "falling!  Throttle to 100%".
    }.

}.

set th to tht.

until stage:liquidfuel > .001 {
    set th to 0.
    stage.
    print "Staging".
    set th to tht.
    wait .2.
}.

set ecc to apoapsis - periapsis.
}.
lock throttle to 0.
set ecc to apoapsis-periapsis.
print "eccentricity: "+ecc.
print "Done!".
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

