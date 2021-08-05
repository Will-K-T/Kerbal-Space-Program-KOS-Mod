// Functional Launch Script

function main{
    launch().
    ascent().
    until apoapsis > 100000{
        autoStage().
    }
    doShutDown().
    doCirculurization().
    print "Prgram Complete".
    unlock steering.
    wait until false.
}

function doCirculurization{
    local circ is list(time:seconds+30, 0, 0, 0).

    until false {
        local oldScore is score(circ).
        set circ to improve(circ).
        if oldScore <= score(circ){
            break.
        }
    }
    executeManeuver(circ).
}

function score{
    parameter data.
    local mnv is node(data[0], data[1], data[2], data[3]).
    addManeuverToFlightPlan(mnv).
    local result is mnv:orbit:eccentricity.
    removeManeuverFromFlightPlan(mnv).
    return result.
}

function improve{
    parameter data.
    local scoreToBeat is score(data).
    local bestCand is data.
    local candidates is list(
        list(data[0] + 1, data[1], data[2], data[3]),
        list(data[0] - 1, data[1], data[2], data[3]),
        list(data[0], data[1] + 1, data[2], data[3]),
        list(data[0], data[1] - 1, data[2], data[3]),
        list(data[0], data[1], data[2] + 1, data[3]),
        list(data[0], data[1], data[2] - 1, data[3]),
        list(data[0], data[1], data[2], data[3] + 1),
        list(data[0], data[1], data[2], data[3] - 1)
    ).
    for can in candidates{
        local canScore is score(can).
        if canScore < scoreToBeat{
            set scoreToBeat to canScore.
            set bestCand to can.
        }
    }
    return bestCand.
}

function executeManeuver {
    parameter mList.
    local mnv is node(mList[0], mList[1], mList[2], mList[3]).
    addManeuverToFlightPlan(mnv).
    local startTime is calculateStartTime(mnv).
    wait until time:seconds > startTime - 10.
    lockSteeringAtManeuverTarget(mnv).
    wait until time:seconds > startTime.
    lock throttle to 1.
    wait until isManeuverComplete(mnv).
    lock throttle to 0.
    removeManeuverFromFlightPlan(mnv).
}

function addManeuverToFlightPlan{
    parameter mnv.
    add mnv.
}

function calculateStartTime{
    parameter mnv.
    return time:seconds + mnv:eta - maneuverBurnTime(mnv).
}

function maneuverBurnTime{
    parameter mnv.
    local dV is mnv:deltaV:mag.
    local g0 is 9.80665.
    local isp is 0.

    list engines in myEngines.
    for en in myEngines{
        if en:ignition and not en:flameout{
            set isp to isp + (en:isp * (en:maxthrust/ship:maxthrust)).
        }
    }

    local mf is ship:mass / constant():e^(dV/(isp*g0)).
    local fuelFlow is ship:maxthrust / (isp * g0).
    local t is (ship:mass - mf) / fuelFlow.
    print "Delta V: " + dv.
    print "Mass init: " + mass.
    print "Mass final: " + mf.
    print "Flow Rate: " + fuelFlow.
    print "Thrust: " + maxthrust.
    print "ISP: " + isp.
    print "Time: " + t.
    return t.
}

function lockSteeringAtManeuverTarget{
    parameter mnv.
    lock steering to mnv:burnvector.
}

function isManeuverComplete{
    parameter mnv.
    if not(defined originalVector) or originalVector = -1{
        global originalVector is mnv:burnvector.
    }
    if vang(originalVector, mnv:burnvector) > 90{
        global originalVector is -1.
        return true.
    }
    return false.
}

function removeManeuverFromFlightPlan{
    parameter mnv.
    remove mnv.
}

function doSafeStage{
    wait until stage:ready.
    stage.
}

function launch{
    sas off.
    lock throttle to 1.
    doSafeStage().
}

function ascent{
    lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
    set targetDirection to 90.
    lock steering to heading(targetDirection, targetPitch).
}

function autoStage{
    if not(defined oldThrust){
        global oldThrust is ship:availablethrust.
    }
    if ship:availablethrust < (oldThrust - 10){
        doSafeStage.
        global oldThrust is ship:availablethrust.
    }
}

function doShutDown{
    lock throttle to 0.
    lock steering to prograde.
}

main().