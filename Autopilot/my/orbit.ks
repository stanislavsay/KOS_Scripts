declare parameter OrbAlt.
set _r to ship:body:radius + OrbAlt.
set _orbv to sqrt(ship:body:mu/_r).

print "target velocity = " + _orbv.


