//circularization script, starts immediately when called.
set th to 0.
lock throttle to th.
local dV is ship:facing:vector:normalized. //temporary
lock steering to lookdirup(dV, ship:facing:topvector).
ag1 off. //ag1 to abort

local timeout is time:seconds + 9000.
when dV:mag < 0.05 then set timeout to time:seconds + 3.
until ag1 or dV:mag < 0.02 or time:seconds > timeout {
    set vecNormal to vcrs(up:vector,velocity:orbit).
    set vecHorizontal to -1 * vcrs(up:vector, vecNormal).
    set vecHorizontal:mag to sqrt(body:MU/(body:Radius + altitude)).

    set dV to vecHorizontal - velocity:orbit. //deltaV as a vector

    //Debug vectors , feel free to delete
    set mark_h to VECDRAWARGS(ship:position, vecHorizontal / 100, RGB(0,1,0), "h", 1, true).
    set mark_v to VECDRAWARGS(ship:position, velocity:orbit / 100, RGB(0,0,1), "dv", 1, true).
    set mark_dv to VECDRAWARGS(ship:position + velocity:orbit / 100, dV, RGB(1,1,1), "dv", 1, true).

    //throttle control
    if vang(ship:facing:vector,dV) > 1 { set th to 0. } //Throttle to 0 if not pointing the right way
    else { set th to max(0,min(1,dV:mag/10)). } //lower throttle gradually as remaining deltaV gets lower
    wait 0.
}
set th to 0.
unlock throttle.
unlock steering.
set mark_h:SHOW TO false.
set mark_v:SHOW TO false.
set mark_dv:SHOW TO false.
