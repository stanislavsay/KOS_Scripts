@LAZYGLOBAL off.

function getElectric {
  //local res is .
  //list resources in res.
  for r in ship:resources {
    if ( r:name = "ELECTRICCHARGE") {
      return r.
    }
  }
  
  return.
}
