//*****************************************************************************
// Introduction to Kerbal Space Program and kOS (1)
//*****************************************************************************

// REQUIRED MODS:
// Ferram Aerospace Research
// Deadly Re-entry Continued
// FASA Launch Clamps and Towers
// and of course Kerbal Operating System (not classic)

// VEHICLE: Cadet Rocket 1

// A few quick basics before the fun stuff:

// Computer programs are sets of specific instructions and information which
// can be understood by a computer. 

// They are typically written in a language that's easy for humans to read, and
// then translated into sets of numbers that tell the computer what to do. 

// Programs contain both instructions and information, or data. Data is 
// typically stored as small chunks of memory (RAM) refered to as variables.

// Here is an example of an instruction which puts some data in a variable.
set message to "Hello 822 Squadron!".

// The data is the text in quotation marks, and the variable name is "message"

// Now we'll see an instruction that will print out that variable.
print message.

// There are different types of data. Text like the data above is typically 
// called a 'string'. There are also number data types:

set currentThrottle to 0. // A whole number is usually called an integer or int

set throtDelta to 1.0. // A fractional/decimal point number is called a 
                       // "floating point" number or float for short.

// Sometimes we want to describe something that as just two states, such as
// true/false or on/off. We can do that with a type of data called a boolean.
set isTrue to true.
set isFalse to false.
// We'll see more examples of how to use booleans soon.

// Once you have data in variables, you can use the variable names in other 
// instructions. Sometimes what operators like '+' do depend on what type of
// data the variable holds. For example:
set anInteger to 5.
set aFloat to 2.5.
set sum to anInteger + aFloat. // Adds the two numbers and stores the result in
                               // a variable named sum. Sum will be a float
                               // because 7.5 can't be represented as an int
                               // This language is smart like this, not all are.

print "Sum of numbers: " + sum. // Automatically converts the number stored in
                                // sum to a string, and joins it to the first
                                // one to be printed.

// Even if you haven't conciously realized it, you've probably figured out that
// these instructions are (generally) executed from the top of the file to the
// bottom. If you run this program, you'll see Hello 822 Squadron printed
// first, then print Sum of numbers: 7.5. The code in between doesn't produce
// any output.

// In a later part we will see how we alter the top-to-bottom flow of the
// program in order to let our code make decisions between different actions.