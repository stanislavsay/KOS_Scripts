
DECLARE PARAMETER MODE.
DECLARE PARAMETER DATA.

IF MODE = "BEGIN" {
  SET REPORTLINE_N TO 0.
}

IF MODE = "PRINT" {
  PRINT "                                        |" AT (0,REPORTLINE_N).
  PRINT DATA AT (0,REPORTLINE_N).
  SET REPORTLINE_N TO REPORTLINE_N + 1.
}

IF MODE = "END" {
  UNTIL REPORTLINE_N = 10 {
    PRINT "                                        |" AT (0,REPORTLINE_N).
    SET REPORTLINE_N TO REPORTLINE_N + 1. 
  }
  PRINT "----------------------------------------" AT (0,REPORTLINE_N).
}