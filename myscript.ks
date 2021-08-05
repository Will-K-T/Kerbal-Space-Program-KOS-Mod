function main{
    launch().
    set ltime to round(time:seconds).
    ascent().
    set printed to false.
    until apoapsis > 100000 {
        // if alt:radar >= midpoint and alt:radar < midpoint+5{
        //     print alt:radar + ", pitch: " + (90-vang(vec1, vec2)).
        // }
        //print targetPitch.
        if(not printed and round(time:seconds) = ltime+10){
            print "10 seconds:".
            print "alt: " + altitude.
            print "vel: " + velocity:surface.
            print "ang: " + (90-vang(ship:up:forevector, ship:facing:forevector)).
            print " ".
            print " ".
            set printed to true.
        }
        //print 90-vang(ship:up:forevector, ship:facing:forevector).
        // when alt:radar = 2500 then{
        //     print "2500 m, pitch: " + 90-vang(vec1, vec2).
        // }
    }
    lock throttle to 0.
    wait until false.
}

function launch{
    print "Launch initiated.".
    sas off.
    lock throttle to 1.
    stage.
}

function ascent{
    // lock targetPitch to 90-10*ln(alt:radar).
    set midpoint to 20000.
    //set vec1 to v(0, 1, 0).
    //lock vec2 to v(1, 25000/alt:radar, 0).
    //lock targetPitch to 90-vang(vec1, vec2).
    //lock targetPitch to 90-.5*(alt:radar^.5).
    lock targetPitch to 90 - alt:radar^0.409511.
    lock steering to heading(90, targetPitch).
}

main().
