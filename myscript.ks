function main{
    launch().
    ascent(). 
    until apoapsis > 100000 {
        if alt:radar >= midpoint and alt:radar < midpoint+5{
            print alt:radar + ", pitch: " + (90-vang(vec1, vec2)).
        }
        print targetPitch.
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
    lock throttle to .6.
    stage.
}

function ascent{
    // lock targetPitch to 90-10*ln(alt:radar).
    set midpoint to 20000.
    set vec1 to v(0, 1, 0).
    lock vec2 to v(1, 25000/alt:radar, 0).
    lock targetPitch to 90-vang(vec1, vec2).
    lock steering to heading(90, targetPitch).
}

main().
