//Creates a maneuver node with a perfectly circular orbit
//Returns:
//(maneuver node) mnv - the maneuver node
function circularize{
    print "Calculating Circular Maneuver...".
    local apOrbitalVel to sqrt((constant:G*body:mass) * ((2/(body:radius+apoapsis)) - (1/orbit:semimajoraxis))).
    local deltaVPrograge to sqrt((constant:G * body:mass)/(body:radius+apoapsis)) - apOrbitalVel.
    local mnv to node(time:seconds+orbit:eta:apoapsis, 0, 0, deltaVPrograge).
    print "    circular maneuver calculation complete.".
    print " ".
    return mnv.
}

//TODO optimize this code to create better orbits
//Executes a desired maneuver node
//Params:
//(maneuver ndoe) mnv - the maneuver to be completed
function executeManeuver{
    print "Maneuver Initiated.".
    parameter mnv.
    add mnv.
    set nd to nextnode.
    local burnTime to maneuverBurnTime(nd:deltaV:mag).
    lock steering to nd:burnvector.
    local startTime to burnTime/2.
    print "    maneuver burntime: " + round(burnTime, 1) + " sec".
    //TODO the start time is off by 1.35 sec
    wait until nd:eta <= startTime.

    set tset to 0.
    lock throttle to tset.
    set done to False.
    set dv0 to nd:deltav.
    until done
    {
        //set max_acc to ship:maxthrust/ship:mass.
        set max_acc to ship:availablethrust/ship:mass.

        //set tset to min(nd:deltav:mag/max_acc, 1).
        set tset to min(maneuverBurnTime(nd:deltaV:mag), 1).

        if vdot(dv0, nd:deltav) < 0
        {
            //print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }

        if nd:deltav:mag < 0.1
        {
            //print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            wait until vdot(dv0, nd:deltav) < 0.5.

            lock throttle to 0.
            //print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done to True.
        }
    }
    unlock steering.
    unlock throttle.

    wait 1.
    remove nd.
    print "    apoapsis: " + round(apoapsis, 1) + " meters".
    print "    periapsis: " + round(periapsis, 1) + " meters".
    print "    maneuver complete.".
    print " ".
    // lock throttle to 1.
    // wait burnTime.
    // lock throttle to 0.
    // unlock steering.
    // unlock throttle.
}

//Calculates the burntime for a maneuver
//Params:
//(float) deltaV - the required deltaV for the maneuver
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