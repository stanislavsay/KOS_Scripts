//*****************************************************************************
// Introduction to Kerbal Space Program and kOS (2)
//*****************************************************************************

// VEHICLE: Cadet Rocket 1

// So we can put data in variables, but how does that help us fly?

// Well, the computer/language define a bunch of special variables. We we put
// data in those variables, the computer reads them and does something in the
// real world. For instance. 
set LIGHTS to true. // This tells the computer to turn on the craft's lights.

// I'll say quickly, the wait keyword allows you to wait some decimal number
// of seconds.
wait 5.0. // Wait 5 whole seconds.

// The language allows you to use a nice shorthand for some of the more
// important booleans. Also on/off are synonyms for true/false.
LIGHTS off.

// Other variables are set constantly by the computer, and we can use them to
// tell what's happening in the real world.
print "Our current altitude above sea level is: " + SHIP:ALTITUDE.
// SHIP is an example of a structure. A structure is basically a variable that
// holds other variables, including other structures. In this case, the number
// variable ALTITUDE that tells us how high we are ASL is a part of the SHIP
// structure that holds all kinds of variables with information about our ship.

// This is an example of a number inside a struct inside a struct inside
// another struct. The FACING struct holds variables describing which way the
// plane/rocket is pointed. STARVECTOR is a struct representing a direction
// (down the right wing). Directions are represented by sets of 3 numbers
// called vectors, but we'll talk about that another day. In this case, X is
// one of those three number variables (X, Y and Z). 
print SHIP:FACING:STARVECTOR:X.

// A complete list of these variables with descriptions of what they do can be
// found here: http://ksp-kos.github.io/KOS_DOC/bindings.html

// BUT ENOUGH OF THIS! LETS FLY!