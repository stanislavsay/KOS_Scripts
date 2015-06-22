set engFO to 0.
set engIGN to 0.
list engines in enginelist.
    for eng in enginelist {
        if eng:flameout {
            set engFO to engFO + 1.
        }
        if eng:ignition {
            set engIGN to engIGN + 1.
        }           
    }
    if engIGN > engFO AND engFO > 0 {
        STAGE.
    } else if engIGN = engFO {
        STAGE.
        WAIT 2.
        STAGE.
}
