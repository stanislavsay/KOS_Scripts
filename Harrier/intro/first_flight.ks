//*****************************************************************************
// Introduction to Kerbal Space Program and kOS (3)
//*****************************************************************************

// VEHICLE: Cadet Rocket 1

// Clear the console screen.
clearscreen.

// Create a variable to hold the throttle setting
set throt to 0.0.
// Tell the computer to set the throttle by reading our variable.
lock THROTTLE to throt.

// Tell the rocket to stay pointed up
lock STEERING to UP. // We'll cover this more in future lessons.

// Command full throttle.
set throt to 1.0.

// Print countdown
// Start the countdown at 5 seconds.
set count to 5.

// Do the code between the curly brackets until count becomes equal to zero.
until count = 0 {
  print count + "...". // Print seconds left till launch
  set count to count - 1. // Subtract 1 from the count variable
  wait 1.0. // Wait a second
}.

print "Main engine start".
STAGE. // Activate the first stage (engine)

wait 3.0. // Wait for the engine thrust to stabilize

print "Releasing launch clamps".
STAGE. // Release the launch clamps

// Wait till the stage burns out
until STAGE:LIQUIDFUEL < 0.1 {
  wait 0.001.
}.

print "First stage out of fuel, separating.".
STAGE. // Fire decoupler to drop first stage

// When we've ceased ascending and then dropped back down below 2500 feet,
// activate the parachutes.
until SHIP:ALTITUDE < 2500 {
  wait 0.001.
}.

print "Altitude dropped below 2500, authorizing chute deployment.".
STAGE.

until abs(SHIP:VERTICALSPEED) < 20 {
  wait 0.001.
}.

// When the bulk of the deceleration from the chutes is done, jetison
// the heat shield to further slow our decent.
print "Vertical speed has dropped below 20 m/s, jettison heat shield.".
wait 1.
STAGE.

print "Continuing unguided decent under parachute. Have a nice day!".
// Nothing more to do, the program exits.
