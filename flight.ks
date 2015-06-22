CLEARSCREEN.

PARAMETER height, duration.

RUN lib_pid.

PRINT "========= BEGIN FLIGHT CONTROL PROGRAM ==========".

RUN auto_gear.
RUN launch.
RUN ascent(height).
RUN hover(height, duration).
RUN land.


PRINT "Main control sequence complete. (Abort Program to resume manual control.)".
WAIT UNTIL 0 > 1.
