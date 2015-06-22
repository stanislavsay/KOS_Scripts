# controls-tutorial
Code and materials uploaded for the purposes of teaching people control theory and automation using Kerbal Space Program and the kOS mod. The material is targeted at people in middle school to high school, so no advanced math is required. In fact, it is my goal to use the practical application of math to controls in order to make you care enough to go learn the underlying mathmatics (and/or actually pay attention when you get to them in school). 

## Required Kerbal Space Program Mods:

- Ferram Aerospace Research
- Deadly Re-entry Continued
- FASA Launch Clamps and Towers
- kOS: Kerbal Operating System

The program CKAN can be used to manage mods easily, and I highly suggest it's use!

## Tutorial Order

I suggest going through the files in the following order:

1) data_and_vars        - Introduces basic variables and data types

2) input_output_structs - Shows how to find out what's happening around you,
                          and how to affect it by reading/writing variables.
                          Also introduces the concept of structure variables.

3) first_flight         - Demonstrates a sequential program and some basic 
                          control flow. Takes a rocket up to 14,000 meters or
                          so and safely back to the ground.

4) controlling_accel    - Our first real look at a control loop, this code
                          keeps the rocket climbing at a constant rate of
                          acceleration.

5) controlling_speed    - Exploring the concept of a controller wrapping a
						  controller, this code builds on the acceleration
						  control code to keep the rocket climbing at a
						  constant speed.

Much more is on the way!
