function main{
    // wait .1.
    // set kuniverse:timewarp:warp to 3.
    // wait 2.
    launch(1).
    ascent(50, 6, 80000).
    coast().
    local mnv to circularize().
    executeManeuver(mnv).
    set kuniverse:timewarp:warp to 0.
    deployPayload().
    activateSatellite().
    print "Program complete!".
}

function deployPayload{
    print "Deploying Payload...".
    lock steering to prograde.
    wait until vang(prograde:forevector, ship:facing:vector) < 0.25.
    stage.
    wait 2.
    stage.
    print "    payload deployment complete.".
    print " ".
}

function activateSatellite{
    print "Satellite Activation Initiated...".
    for solarPanel in ship:partsdubbedpattern("solarPanel"){
        solarPanel:getmodule(solarPanel:modules[0]):doevent("extend solar panel").
    }
    local commDish to ship:partsdubbed("commdish1")[0].
    commDish:getmodule(commDish:modules[0]):doevent("extend antenna").
    set steering to heading(0,0,0).
    wait 2.
    sas on.
    unlock steering.
    print "    satellite activation complete.".
    print " ".
}

if ship:velocity:orbit:mag <= 175{
    runoncepath("0:/HelperFiles/SubOrbital.ks").
    runoncepath("0:/HelperFiles/Orbital.ks").
    main().
}