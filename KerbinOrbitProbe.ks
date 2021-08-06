function main{
    launch().
    ascent().
    coast().
    local mnv to circularize().
    executeManeuver(mnv).
    deployPayload().
    wait until false.
}

function launch{
    print "Launch initiated.".
    sas off.
    lock throttle to 1.
    stage.
}

function ascent{
    print "Ascent initiated.".
    local rotation to 90.
    set steering to heading(90, 90).
    wait until velocity:surface:mag > 50.
    local targetPitch to 84.
    set steering to heading(rotation, targetPitch).
    wait until (90-vang(ship:up:forevector, ship:facing:forevector)) < targetPitch.
    lock steering to heading(90, 90-vang(ship:up:forevector, srfprograde:forevector)).
    wait until apoapsis > 80000.
    set throttle to 0.
}

function coast{
    print "Coasting.".
    local apHeight to apoapsis.
    wait 1.
    until abs(apoapsis-apHeight) < .01{
        set apHeight to apoapsis.
        wait 1.
    }
}

function circularize{
    print "Creating circular maneuver.".
    local apOrbitalVel to sqrt((constant:G*body:mass) * ((2/(body:radius+apoapsis)) - (1/orbit:semimajoraxis))).
    local deltaVPrograge to sqrt((constant:G * body:mass)/(body:radius+apoapsis)) - apOrbitalVel.
    local mnv to node(time:seconds+orbit:eta:apoapsis, 0, 0, deltaVPrograge).
    return mnv.
}

function deployPayload{
    print "Deploying payload.".
    lock steering to prograde.
    wait until vang(prograde:forevector, ship:facing:vector) < 0.25.
    stage.
    wait 1.
    stage.
}

//TODO optimize this code to create better orbits
function executeManeuver{
    print "Maneuver initiated.".
    parameter mnv.
    add mnv.
    local burnTime to maneuverBurnTime(mnv:deltaV:mag).
    lock steering to mnv:burnvector.
    set nd to nextnode.
    local startTime to burnTime/2.
    //TODO the start time is off by 1.35 sec
    wait until mnv:eta <= startTime.

    set tset to 0.
    lock throttle to tset.

    set done to False.
    set dv0 to nd:deltav.
    until done
    {
        //set max_acc to ship:maxthrust/ship:mass.
        set max_acc to ship:availablethrust/ship:mass.

        //set tset to min(nd:deltav:mag/max_acc, 1).
        set tset to min(maneuverBurnTime(mnv:deltaV:mag), 1).

        if vdot(dv0, nd:deltav) < 0
        {
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }

        if nd:deltav:mag < 0.1
        {
            print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            wait until vdot(dv0, nd:deltav) < 0.5.

            lock throttle to 0.
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done to True.
        }
    }
    unlock steering.
    unlock throttle.

    wait 1.
    remove nd.
    // lock throttle to 1.
    // wait burnTime.
    // lock throttle to 0.
    // unlock steering.
    // unlock throttle.
}

function maneuverBurnTime{
    parameter deltaV.
    local dV to deltaV.
    local g0 to constant:g0.
    local isp to 0.

    list engines in myEngines.
    for en in myEngines{
        if en:ignition and not en:flameout{
            set isp to isp + (en:isp * (en:maxthrust/ship:maxthrust)).
        }
    }
    local mi to mass.
    local dm to mi*(1-constant:e^(-1*dv/isp/g0)).
    local flowRate to availablethrust / (isp*g0).
    local t to dm/flowRate.
    return t.
}

main().