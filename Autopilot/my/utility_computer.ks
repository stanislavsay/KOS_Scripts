
// ######################################################################
//    LANDING LEGS
// ######################################################################

IF ALT:RADAR + SHIP:VERTICALSPEED*10 < 0 {
  LEGS ON.
  GEAR ON.
}
ELSE IF ALT:RADAR + SHIP:VERTICALSPEED*10 > 250 {
  LEGS OFF.
  GEAR OFF.
}

IF ANGLE_BETWEEN_BODY_AND_SUN < ANGLE_SWEPT_BY_CURRENT_BODY - ANGLE_SWEPT_BY_SUN {
  LIGHTS ON.
}
ELSE {
  LIGHTS OFF.
}
