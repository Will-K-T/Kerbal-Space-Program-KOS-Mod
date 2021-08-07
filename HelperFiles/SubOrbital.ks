//Initiates the launch sequence
//Params: 
//(int) numOfStages - the number of stages to start the launch
function launch{
    parameter numOfStages.
    print "Launch Initiated...".
    sas off.
    lock throttle to 1.
    local cnt to 0.
    until cnt >= numOfStages{
        stage.
        set cnt to cnt+1.
    }
    print "    launch complete.".
    print " ".
}

//Gets the rocket's apoapsis to the desired height
//Params:
//(float) vel - target velocity before initiating the turn over maneuver
//(float) turnOverPitch - the pitch of the pitch over maneuver (in degrees from the zenith)
//(float) targetAp - the desired apoapsis height in meters
function ascent{
    parameter vel, turnOverPitch, targetAp.
    print "Ascent Initiated...".
    local rotation to 90.
    set steering to heading(90, 90).
    wait until velocity:surface:mag > vel.
    local targetPitch to 90-turnOverPitch.
    set steering to heading(rotation, targetPitch).
    wait until (90-vang(ship:up:forevector, ship:facing:forevector)) < targetPitch.
    lock steering to heading(90, 90-vang(ship:up:forevector, srfprograde:forevector)).
    print "    pitch over maneuver complete.".
    wait until apoapsis > targetAp.
    print "    ascent complete.".
    print " ".
    set throttle to 0.
}

//Lets the rocket coast until it is out of the affects of the atmosphere
function coast{
    print "Coasting Initiated...".
    local apHeight to apoapsis.
    wait 1.
    until abs(apoapsis-apHeight) < .01{
        set apHeight to apoapsis.
        wait 1.
    }
    print "    coasting complete.".
    print " ".
}