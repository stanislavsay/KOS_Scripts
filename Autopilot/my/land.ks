declare parameter descType. // "hover", "lander", or "skycrane", or "skycrane/lander".
declare parameter seekFlat. // Flatness slope level acceptable for landing.
declare parameter numCh. // Number of parachute parts on lander.
declare parameter chName. // Name of the parachute parts on lander.
print "Landing initiating for type = " + descType + " flat = " + seekFlat + " chutes = " + numCh + " chuteNames = " + chName.
sanityOK on.
if maxthrust = 0 {
  print "ABORTING 'descend' PROGRAM: ".
  print "  No active engines right now.".
  sanityOK off.
}.  
if alt:periapsis > descendTop {
  print "ABORTING 'descend' PROGRAM: ".
  print "  Get your periapsis below " + descendTop + "m before running this program".
  sanityOK off.
}.
set chMass to 0.
if numCh > 0 {
  print "Lookup for " + chName.
  run chutedata(chName).
  if chMass = 0 {
    sanityOK off.
  }.
}.

if sanityOK {
  print "Descend mode : " + descType .

  set minPayload to 0.1 .

  print "Descend program initialised. ".
  print "---------------------------- ".
  print " ".
  print "Program will start operations when ".
  print "your AGL is under " + descendTop + " meters.".
  wait until ( altitude < descendTop ) .

  print "Taking over rotation control.".

  SAS OFF.
  set mySteer to ship:SRFRETROGRADE.
  lock steering to mySteer.

  lock align to abs( cos(ship:facing:pitch) - cos(mySteer:pitch) )
                + abs( sin(ship:facing:pitch) - sin(mySteer:pitch) )
                + abs( cos(ship:facing:yaw) - cos(mySteer:yaw) )
                + abs( sin(ship:facing:yaw) - sin(mySteer:yaw) ) .


  wait until align < 0.2.

  set myTh to 0.0 .
  lock throttle to myTh.

  print "ENTERING DESCENT MODE.".

  // dModes are as follows:
  // dMode 0 = descending to descendBot AGL.
  // dMode 1 = hovering at descendBot AGL.
  // dMode 2 = skycrane drop payload and escape.
  // dMode 3 = coming down for final touchdown from descendBot.
  set dMode to 0.

  set beDone to 0.

  set chutesYet to 0.

  // variables for slope seeking:
  set slope to 0.  // Slope detected under lander.
  set gHeight to 0.  // Height of ground above sea level.
  set pgHeight to 0.  // previous Height of ground above sea.
  set pTime to missiontime. // Previous elapsed time.

  set needNewAG9 to 1.

  clearscreen.
  print "*== MODE: ==========================*".
  print "|     AGL Altitude =                |".
  print "|    Periapsis alt =                |".
  print "| Term. vel at Pe  =                |".
  print "|   Current Thrust =                |".
  print "|    Waiting for areobrake ? =      |".
  print "|   Neutral Thrust =                |".
  print "|              TWR =                |".
  print "|    Current Speed =                |".
  print "|  Preferred Speed =                *----------*".
  print "| Ground Slope Here=                           |".
  print "| Duration of prev iteration =                 |".
  print "*----------------------------------------------*".
  print " ========= Descend Type: " + descType + " ====".

  set bodyMass to ship:body:mass.
  set bodyRadius to ship:body:radius.

  lock heregrav to gConst*bodyMass/((altitude+bodyRadius)^2).
  lock twr to maxthrust/(heregrav*mass).
  set tfE to 9999999. set tfN to 9999999. set tfU to 9999999. // east,north,up vector
  lock absspd to (tfE^2 + tfN^2 + tfU^2) ^ 0.5 .
  set petermv to 999999.
  set usepe to 999999.

  set absvsup to abs(tfU).
  lock cossteerup to absvsup / ( (tfE^2+tfN^2+absvsup^2)^0.5 ).
  lock sinsteerup to ((tfE^2+tfN^2)^0.5) / ( (tfE^2+tfN^2+absvsup^2)^0.5 ).


  loopedOnce off.
  when bodyAtmSea = 0 or (loopedOnce and (absspd < petermv) and usepe <= bodyMaxElev ) then {
    unlock fdrag. set fdrag to 0.
    unlock usepe. set usepe to 0.
    unlock pegrav. set pegrav to gConst*bodyMass/(bodyRadius^2).
    unlock pepress. set pepres to 0.
    unlock vdrag. set vdrag to 0.2 .
    unlock petermv. set petermv to 999999.
  }.

  if bodyAtmSea > 0 {
    // Which periapsis to use: real or ground level?
    lock usepe to alt:periapsis. 
    when usepe < bodyMaxElev then {
      lock usepe to bodyMaxElev.
    }.
    // gravitational accelleration and pressure at periapsis:
    lock pegrav to gConst*bodyMass/((usepe+bodyRadius)^2).
    lock pepress to (atmToPres*bodyAtmSea) * e ^ ( (0-usepe)/bodyAtmScale) .
    // The current drag to calculate with:
    set useDrag to 0.2 .
    // The drag number to use will change when we hit certain conditions:
    if numCh > 0 {
      when pepress > chSemiPres then { set useDrag to chSemiDrag. }.
      when alt:periapsis < chFullAGL then { set useDrag to chFullDrag. }.
    }.
    lock vdrag to ( (mass-(numCh*chMass))*0.2 + (chMass*useDrag) ) / mass .
    // Force of drag from air pressure here:
    // current velocity when we got there:
    lock fdrag to 0.5*( (atmToPres*bodyAtmSea) * e^( (0-altitude)/bodyAtmScale) )*absspd^2*vdrag*0.008*mass.
    // Terminal velocity at periapsis:
    lock petermv to ( (250*pegrav)/( pepress * vdrag ) ) ^ 0.5 .
  }.

  // Hover throttle setting that would make my rate of descent constant:
  lock hovth to ((mass*heregrav)-fdrag) * (1/cossteerup) / maxthrust .

  // The acceleration I can do above and beyond what is needed to hover:
  lock extraac to (twr - 1) * heregrav.

  // My current stopping distance I need at that accelleration, with a 1.2x fudge
  // factor for a safety margin:
  lock stopdist to 1.2 * ( (absvsup-descendBotSpeed)^2)/(2*extraac).

  // naptime = Seconds to slow down the loop execution by.
  // Fast execution speed is only needed when near the bottom of the descent.
  // At the top it's safe to execute slowly and give more time to other KSP things:
  lock naptime to 10 * (alt:radar - descendBot)/(descendTop-descendBot).

  run tfXYZtoENU( velocity:surface:x, velocity:surface:y, velocity:surface:z ).
  set surfGrav to gConst*bodyMass/(bodyRadius^2).
  set surfExtraAc to ( (maxthrust/(mass*surfGrav) ) - 1 ) * surfGrav .

  until beDone {
    set airbrakeMult to 1. // 1 = not areobraking, 0 = areobraking.

    // Get surface velocity in terms of a coordinate system
    // based on the current East,North, and Up axes:
    // ...................................................
    run tfXYZtoENU( velocity:surface:x, velocity:surface:y, velocity:surface:z ).
    set absvsup to abs(tfU).

    // Try to save a snapshot of the dynamic data at one 
    // instant of time or as close as possible to that:
    // ...................................................
    // set absspd to (tfE^2 + tfN^2 + tfU^2) ^ 0.5 .
    set altAGL to alt:radar .
    set altSea to altitude .
    set spdSurf to surfacespeed.
    set dTime to missiontime - pTime.
    set pTime to missiontime.

    if bodyAtmSea > 0 {
      print "                          " at (22,2).
      if pepress > 0 and petermv < 10000 {
        print round( usepe* 10 ) / 10 + " m" at (22,2).
      }.
      if usepe = bodyMaxElev {
        print "(est max elev)" at (22,12).
      }.
      print "              " at (22,3).
      if pepress > 0 and petermv < 10000 {
        print round( petermv* 10 ) / 10 + " m/s" at (22,3).
      }.
    }.

    if dMode = 0 { print "  DESCENDING   " at (10,0). }.
    if dMode = 1 { print "   HOVERING    " at (10,0). }.
    if dMode = 2 { print "DEPLOYED/ESCAPE" at (10,0). }.
    if dMode = 3 { print "    LANDING    " at (10,0). }.

    print "        " at (32,11).
    print ( round( dTime * 100 ) / 100 ) + " s" at (32,11).

    // Guess AGL if we're too high to tell:
    if altAGL = altSea and altSea > 10000 {
      set altAGL to altSea - (bodyMaxElev/2).
    }.
    print "              " at (22,1).
    print ( round( altAGL * 10 ) / 10 ) + " m" at (22,1).


    set gHeight to (altSea-altAGL).
    set slope to 0.
    // Avoid calculating ground slope if not moving horizontally
    // fast enough to get a reliable reading.  If moving nearly
    // vertically, then the arithmetic gets chaotic and swingy:
    if spdSurf > 0.1 {
      set slope to (gHeight-pgHeight)/(dTime*spdSurf).
    }
    set pgHeight to gHeight.
    print "                        " at (22,10).
    print ( round( slope * 100 ) / 100 )  at (22,10).
    if abs(slope) > abs(seekFlat) {
      print "(seeking flatter)" at (28,10).
    }.
    print "            " at (22,7).
    print ( round( twr * 100) / 100 ) + " (at here)" at (22,7).
    print "            " at (22,8).
    print ( round( absspd * 100 ) / 100 ) + " m/s" at (22,8).

    if altAGL < descendBot*3 {
      // Check to see if we need to scope on further for
      // flatter land.  Only do this if landing has not
      // alrady begun.  Once it's begun commit to it:
      if dMode < 2 and abs(slope) > abs(seekFlat) {
        // Pretend the centered direction is a bit off from
        // what it really is, to make the code steer a bit
        // off on purpose, to make it seek a different
        // landing spot.
        if tfE > 0 { set tfE to tfE-10 . }.
        if tfE < 0 { set tfE to tfE+10 . }.
        if tfN > 0 { set tfN to tfN-10 . }.
        if tfN < 0 { set tfN to tfN+10 . }.
      }.

      set oldAbsVsUp to absvsup.
      if dMode = 1 or dMode = 3 { set absvsup to absspd + 1.0 . }.
    }.
    set mySteerVector to up * V( tfE, 0 - tfN, absvsup ).
    set mySteer to mySteerVector:direction.
    
    print "          " at (22,6).
    print ( round( hovth * 1000 ) / 10 ) + " %"  at (22,6).

    if dMode = 0 and altAGL > 0 and altAGL < descendBot {

      set dMode to 1.
      BRAKES ON.
      LEGS ON.
      LIGHTS ON.
    }.
    if dMode = 1 {
      set pDesSpd to 5 * ( altAGL - descendBot ) / descendBot  .
      if needNewAG9 = 1 {
        on AG9 set dMode to 3. 
        on AG9 set needNewAG9 to 1.
        set needNewAG9 to 0.
      }.

      if abs(slope) < abs(seekFlat) {
        if descType = "skycrane" or descType = "skycrane/lander" or descType = "lander" {
          set dMode to 3.
        }.
      }.
    }.
    if dMode = 0 and altAGL > descendBot {


      set guessMoreH to (bodyMaxElev-gHeight).
      if guessMoreH > altAGL { set guessMoreH to 0. }.
      // Height to use to calculate how much distance I have available to stop:
      set H to (altAGL-descendBot) - (guessMoreH*sinsteerup). 

      if H < 0  { set H to 0.  } // if dipping negative, don't allow sqrt to give NAN result.
      set pDesSpd to sqrt( 1.8 * surfExtraAc * H ) + descendBotSpeed.


      if periapsis > 0 and petermv > (absspd*1.3) {
        set pDesSpd to 0.
      }.


      if  bodyAtmSea > 0 and absspd > petermv*1.25 and stopdist < (altAGL-descendBot)/cossteerup {
        set airbrakeMult to 0.
        if numCh > 0 and chutesYet = 0 {
          CHUTES ON.
          set chutesYet to 1.
        }.
      }.
      if airbrakeMult = 1 { print "no " at (32,5).  }.
      if airbrakeMult = 0 { print "yes" at (32,5).  }.
    }.
    if dMode = 2 {

      set mySteer to up.
      set myTh to hovth*2/3.
      SAS ON. // So the SAS ON will be inherited by the payload before dropping it.

      set oldMass to 0.
      set n to 0.
      until n > 8 or mass < (oldmass-minPayload) {
        set oldMass to mass.
        print "Trying to drop stage.".
        wait 0.5 .
        STAGE.
        set n to n + 1.
      }.
      if n > 8 { print "I can't seem to stage a payload.  Giving up.".  }.
      SAS OFF.


      set myTh to 1.2 * hovth . 
      if myTh > 1 { set myTh to 1. }.
      set mySteer to up.
      wait 2.

      if descType = "skycrane" {
        set mySteer to up + R(30,0,0).
        set myTh to 1.5*hovth.
        if myTh > 1 { set myTh to 1. }.
          set beDone to 1.
          wait 5.
        }.
      if descType = "skycrane/lander" {
        set mySteer to up + R(20,0,0).
        set myTh to hovth .
        if myTh > 1 { set myTh to 1. }.
        // Become a lander now:
        set descType to "lander".
        set dMode to 3.
        wait 3 .
      }.
    }.
    if dMode = 3 {
      set pDesSpd to bodyLandingSpeed.
      if STATUS = "LANDED" or STATUS = "SPLASHED" {
        if descType = "hover" or descType = "lander" {
          // Stop moving:
          set mySteer to up.
          lock throttle to 0.
          wait 10.
          set beDone to 1. 
        }
        if descType = "skycrane" or descType = "skycrane/lander" {
          SAS ON. // To ensure the payload is holding itself stable.
          set dMode to 2.
        }.
      }.
    }.

    print "             " at (22,9).
    print ( round( pDesSpd * 100 ) /  100 ) + " m/s" at (22,9).
    set spd to absspd.
    if verticalspeed > 0.0 { set spd to 0 - absspd. }.

    set thOff to ( ( spd - pDesSpd ) / dTime ) / (maxthrust/mass).

    if altAGL < (descendBot*3) and spd > (pDesSpd*2) {
      set thOff to 1.5*thOff.
    }.
    
    set newTh to ( hovth + thOff ) * airbrakeMult .
    if newTh < 0.0 { set newTh to 0.0 . }.
    if newTh > 1.0 { set newTh to 1.0 . }.

    if align > 1.0 {
      set newTh to newTh / 3.
    }.
    set myTh to newTh.

    print "              " at (22,4).
    print ( round( myTh * 1000 ) / 10 ) + " %"  at (22,4).

    // extra delay when up high and not thrusting right now:
    if naptime > 0 and myTh = 0 { wait naptime. }.
    
    loopedOnce on.
  }.

}.

print "DONE.".