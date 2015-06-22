list engines in myEng.
set sum_f to 0. // thrust in N
set sum_f_isp to  0. // thrust/Isp

for engine in myEng {
	if ( engine:IGNITION ) {
    set engine_thrust to engine:maxthrust * engine:thrustlimit / 100.
    set sum_f to sum_f + engine_thrust.
    set sum_f_isp to  sum_f_isp + (engine_thrust / engine:isp).
  }

	//print engine + ": " + ).
}

set Isp to sum_f / sum_f_isp.
print "Isp = " + Isp.
