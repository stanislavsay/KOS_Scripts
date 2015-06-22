
//SET p to ship:rootpart.
//print p.
//print ship:rootpart.
//print (p = ship:rootpart).
///print ( p:UID = SHIP:ROOTPART:UID ).

LIST ENGINES in myeng.
IF SHIP:LIQUIDFUEL > 0 AND STAGE:LIQUIDFUEL < 0.01 AND STAGE:SOLIDFUEL < 0.01 {
  PRINT "ENGINE START REQUIRED".
  STAGE.
  WAIT 1.5.
}

UNTIL FALSE {
  for e in myeng {

    if ( e:flameout ) {
      set curstage to e:stage.
        set p to e.
        set found to false.

      until not(p:hasparent) {
        if ( p:modules:contains("ModuleAnchoredDecoupler") and p:stage = e:stage - 1 ) {
          print "found for " + e + " dec " + p.
          set found to true.
          break.
        }

        set p to p:PARENT.
      }

      if ( found ) { 
        print "stage flameout engines!".
        stage.
      }
    }
    //print e:stage + " " + e:parent:parent:stage.
  }

}