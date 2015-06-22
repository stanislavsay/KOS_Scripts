declare parameter Isp.

set Ispg to Isp*9.82.
set maneuverNode to nextnode.

// lock the steering to the node
sas off.
lock nodeDirection to maneuverNode:burnvector.//R(0,0,180) + (R(0,0,0)*maneuverNode:burnvector).
lock steering to nodeDirection.

// calculate burn time
set finalMass to ship:mass / ((constant():e) ^(maneuverNode:burnvector:mag / Ispg)).
// adjust thrust so the burn time is at least 1s.
set burnThrottle to 1.
set burnTime to 0.
until burnTime >= 1
{
    set massFlowRate to (ship:maxthrust*burnThrottle) / Ispg.
    set burnTime to (ship:mass - finalMass) / massFlowRate.    
    if burnTime < 1 { set burnThrottle to 0.75*burnThrottle. }.
}.
print "Burn time: " + round(burnTime, 3) + "s @ " + round(burnThrottle * 100) + "%".

// throttle up delay
set startDelay to 0.97.

// 1x (по-умолчанию), 5×, 10×, 50×, 100×,1 000×, 10 000× и 100 000×
when maneuverNode:eta <= 100000 * 12 then if warp > 6 { set warp to 6. }
when maneuverNode:eta <= 10000 * 10 then if warp > 5 { set warp to 5. }
when maneuverNode:eta <= 1000 * 8 then if warp > 4 { set warp to 4. }
when maneuverNode:eta <= 100 * 6 then if warp > 3 { set warp to 3. }
when maneuverNode:eta <= 50 * 4 then if warp > 2 { set warp to 2. }
when maneuverNode:eta <= 10 * 2 then if warp > 1 { set warp to 1. }
when maneuverNode:eta <= 5 then if warp > 0 { set warp to 0. }

wait until maneuverNode:eta <= ((burnTime / 2) + startDelay).
// start burn
set warp to 0.
lock throttle to burnThrottle.
wait burnTime - 0.02.
lock throttle to 0.

unlock steering.
sas on.

remove maneuverNode.