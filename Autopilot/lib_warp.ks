function warpTo {
    declare parameter dtp.
    // warp (0:1) (1:5) (2:10) (3:50) (4:100) (5:1000)
    local dt to round(dtp).
    local t0 to round(time:seconds).
    set t1 to t0 + dt.

    print "T+" + round(missiontime) + " Warp for " + dt + "s".

    if dt > 3000 {
        print "T+" + round(missiontime) + " Warp 5.".
        set warp to 5.
    }
    if dt > 3000 {
        when time:seconds > t1 - 3000 then {
            print "T+" + round(missiontime) + " Warp 4.".
            set warp to 4.
        }
    }
    if dt > 300 and dt <= 3000 {
        print "T+" + round(missiontime) + " Warp 4.".
        set warp to 4.
    }
    if dt > 300 {
        when time:seconds > t1 - 300 then {
            print "T+" + round(missiontime) + " Warp 3.".
            set warp to 3.
        }
    }
    if dt > 10 and dt < 300 {
        print "T+" + round(missiontime) + " Warp 3.".
        set warp to 3.
    }
    if dt > 60 {
        when time:seconds > t1 - 60 then {
            print "T+" + round(missiontime) + " Warp 2.".
            set warp to 2.
        }
    }
    if dt > 30 {
        when time:seconds > t1 - 30 then {
            print "T+" + round(missiontime) + " Warp 1.".
            set warp to 1.
        }
    }
    if dt > 10 {
        when time:seconds > t1 - 10 then {
            print "T+" + round(missiontime) + " Realtime, " + round(t1-time:seconds) + "s remaining.".
            set warp to 0.
        }
    }

    wait until time:seconds > t1.
    print "T+" + round(missiontime) + " Warp complete " + time:calendar + " " + time:clock.
}