function main{
    launch().
    ascent().
    coast().
    circularize().
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
    local apOrbitalVel to sqrt((constant:G*body:mass) * ((2/(body:radius+apoapsis)) - (1/orbit:semimajoraxis))).
    local deltaVPrograge to sqrt((constant:G * body:mass)/(body:radius+apoapsis)) - apOrbitalVel.
    local mnv to node(time:seconds+orbit:eta:apoapsis, 0, 0, deltaVPrograge).
    executeManeuver(mnv).
}

function executeManeuver{
    parameter mnv.
    add mnv.
    local burnTime to maneuverBurnTime(mnv:deltaV:mag).
    lock steering to mnv:burnvector.
    wait until time:seconds > (time:seconds+mnv:eta-burnTime/2).
    lock throttle to 1.
    wait burnTime.
    lock throttle to 0.
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