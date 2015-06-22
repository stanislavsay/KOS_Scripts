set vector1 to ship:position + v(1000,0,0). //position 1km away from ship, in SOI reference direction (1000,0,0)
print "X/fore: " vdot(ship:facing:forevector, vector1).
print "Y/starboard: " vdot(ship:facing:starvector, vector1).
print "Z/top: " vdot(ship:facing:topvector, vector1).
