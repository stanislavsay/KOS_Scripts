@LAZYGLOBALS off

//// fly - 2 modes - H.ALT autopilot, thrust limiter - to hold term speed
local halt_autopilot is false.
local term_autopilot is false.

on ag1 { set halt_autopilot to not halt. preserve. }
on ag1 { set term_autopilot to not term_autopilot. preserve. }

local pitch_pid is PID_init( 0.05, 0.01, 0.001, -45, 45, 0.1 ).
local diffpitch_pid is PID_init( 1, 0.01, 0.1, -1, 1, 0.01 ).
clearScreen.
///////0         1         2
///////012345678901234567890
//print " pitch    = ".

local cx is 12.

until false {

  if ( halt_autopilot ) {
    local pitch is PID_seek(pitch_pid, 0, ship:verticalSpeed).
    local p is 90 - vang( ship:facing:vector, up:vector).

    set ship:control:pitch to PID_seek( diffpitch_pid, pitch, p ).
  }


  print round(pitch) at (cx, 0).
}
