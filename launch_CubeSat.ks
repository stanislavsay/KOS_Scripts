CLEARSCREEN.
SET TERMINAL:WIDTH TO 57.
SET TERMINAL:HEIGHT TO 14.

SET apo TO 75000. //Высота плановой орбиты
SET inc TO 0. //Наклонение плановой орбиты
SET err TO 0.
SET int TO 0.
SET tv TO 0. //Тепловая скорость
SET Countdown TO 10.
SAS ON. //Включаем SAS
SET f to 0. //flag
SET th TO 1. //Установка газа на 100%
SET st TO HEADING (90 + inc ,88). //Устанавливаем стартовый угол
LOCK THROTTLE TO th. //Закрепляем значение газа за переменной
LOCK STEERING TO st.

// Выводим инф.табло
PRINT "********************************************************" AT (0,0).
PRINT "**                                                    **" AT (0,1).
PRINT " Launch to orbit " + (apo/1000) + " km and inc. " + inc + " degree " AT (2,1).
PRINT "********************************************************" AT (0,2).
PRINT "**                                                    **" AT (0,3).
PRINT "**                                                    **" AT (0,4).
PRINT "**                                                    **" AT (0,5).
PRINT "**                                                    **" AT (0,6).
PRINT "**                                                    **" AT (0,7).
PRINT "**                                                    **" AT (0,8).
PRINT "**                                                    **" AT (0,9).
PRINT "**                                                    **" AT (0,10).
PRINT "**                                                    **" AT (0,11).
PRINT "********************************************************" AT (0,12).

// Начинаем предстартовый отсчет. Фаза 0
UNTIL Countdown > 0 {
  PRINT " Countdown: " + Countdown + "..." AT (2,4).
  WAIT .5.
  SET Countdown TO Countdown - 1.
  }.

staging().
PRINT " Launch!!! " AT (2,4).

UNTIL ALTITUDE > 300 {
  IF VERTICALSPEED > 5 and f = 0 {
    PRINT " Liftoff..." AT (2,4).
    prn(5).
    SET f TO 1. //Переход в фазу 1 при отрыве от стола
    }.
  }.


UNTIL ALTITUDE > 500 {
  PRINT " Phase One         " AT (2,4).
  prn(5).
  //SAS OFF.
  LOCK tv TO 2100.
  }.

//SET f TO 0.
// Фаза 1. f=1. Ждем пока Ap не достигнет 9 км
UNTIL APOAPSIS > 9000 {
  SET int TO int + err.
  SET err TO tv - AIRSPEED.
  IF int > 30 {
    SET int TO 30.
    }.
  IF int < -5 {
    SET int TO -5.
    }.
  SET th TO 0.2 * err + 0.02 * int.
  IF th < 1 AND f = 1 {
    PRINT " Start Throttle correction...           " AT (2,4).
    SET f to 2. //Начало фазы 2 - корректируем ускорение пока не достигнем 9 км.
    }.
  prn(5).
  //IF th < 1 AND f = 0 {
    //PRINT "max Q".
    //SET f TO 1.
    //}.
}.

SET s TO 50.
SET st TO heading(inc + 90, (40+s)).
PRINT " Phase Two. Pitch programm                    " AT (2,4).
prn(5).

//SET f to 0.
//Фаза 2. f=2. Ждем пока Ap  не достигнет 45 км
UNTIL APOAPSIS > 45000 {
  IF ALTITUDE > 40000 AND f = 2 {
    SET f TO 3. //Переходим к фазе 3
  }.

  SET s TO ((50000 - APOAPSIS) / 2100).
  IF s > 50 {
    SET s TO 50.
    }.
  SET st TO HEADING(inc + 90, (40+s)).
  SET int TO int + err.
  SET err TO tv - AIRSPEED.
  IF int > 30 {
    SET int TO 30.
    }.
  IF int < -10 {
    SET int TO -10.
    }.
  SET th TO 0.2 * err + 0.02 * int.

  IF th < 1 AND f = 2 {
      PRINT " Phase Three. Pitch to be continue...        " AT (2,4).
      SET f TO 3. //Переходим к фазе 3
    }.
    prn(5).
  }.

LOCK st TO PROGRADE.
PRINT " Steering Prograde... Throttle to 100%...          " AT (2,4).
SET th TO 1.
prn(5).
// Фаза 3. Ждем пока Ap не достигнет расчетной высоты
UNTIL APOAPSIS > apo {
  IF ALTITUDE > 43800 and f = 3 {
    SET f TO 4. //Переходим к Фазе 4
    SET th TO 0.
    staging().
    WAIT .2.
    }.
  UNTIL f = 4 {
    staging().
    }.
  prn(5).
  }.

SET th TO 0.
PRINT " Wait to Ap." AT (2,4).
SET WARP TO 3.
SET s TO 2200.
SET dv TO s - VELOCITY:ORBIT:MAG.
SET t to (MASS * dv) / (MAXTHRUST).
PRINT " Timeout: " + (ETA:APOAPSIS - (t/2)) + "s" AT (15,4). 

UNTIL ( ETA:APOAPSIS < ( t / 2)) {
  SET dv TO s - VELOCITY:ORBIT:MAG.
  SET t TO (MASS * dv) / (MAXTHRUST).
  }.

SET ecco TO APOAPSIS - PERIAPSIS.
SET WARP TO 0.
SET th TO 1.
WAIT .1.

SET ecc TO APOAPSIS - PERIAPSIS.
SET err TO 0.
SET int TO 0.
SET tht TO 1.
SET th TO tht.
SET f1 TO 0.
SET f2 TO 0.

UNTIL ((ecc - 50) > ecco) {
  SET ecco TO ecc.
  SET dv TO s - VELOCITY:ORBIT:MAG.
  SET t TO (MASS * dv) / (MAXTHRUST).
  SET err TO t - ETA:APOAPSIS + 1.
  SET int TO int + err.
  IF int > 15 {
    SET int TO 15.
    }.
  IF int < -5 {
    SET int TO -5.
    }.
  SET tht TO 0.3 * err + 0.03 * int.
  IF t < 1 {
    SET tht TO .5.
    IF f1 = 0 {
      SET f1 TO 1.
      PRINT "Less than 1s, Finalizing Burn                    " AT (2,4).
      }.
    }.
  IF VERTICALSPEED < 0 {
    SET tht TO 1.
    IF f2 = 0 {
      SET f2 TO 1.
      PRINT "Falling! Throttle to 100%!                      " AT (2,4).
      }.
    }.
  SET th TO tht.
  staging().
  SET ecc TO APOAPSIS - PERIAPSIS.
  }.

LOCK THROTTLE TO 0.
SET ecc TO APOAPSIS-PERIAPSIS.
PRINT "Final Eccentricity: " + ecc +". Done!" AT (2,10).

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.



/////////////////////////////////////////////////////////////////////
//             FUNCTION PLACE                                      //
/////////////////////////////////////////////////////////////////////


// Функция определяет запущен ли двигатель (Ignition) и отсутствует ли топливо (Flameout).
// Если топливо отсутствует то переключаем флаг
// Если двигатель запущен то переключаем флаг
// Если оба флага были переключены, значит двигатель работает, но топливо кончилось, значит отделяем ступень
// 
DECLARE FUNCTION staging {
    SET engFlameOut to 0.
    SET engIgnition to 0.
    SET curThr to th.
    SET tempThr to 0.
    LIST ENGINES IN enginelist.
    FOR eng IN enginelist {
        IF eng:FLAMEOUT {
            SET engFlameOut to engFlameOut + 1.
        }.
        IF eng:IGNITION {
            SET engIgnition TO engIgnition + 1.
            }.
    }.
    IF engIgnition > engFlameOut AND engFlameOut > 0 {
        SET th TO tempThr.
        WAIT .2.
        STAGE.
        WAIT .2.
        SET th TO curThr.
        } ELSE IF engIgnition = engFlameOut {
            SET th TO tempThr.
            STAGE.
            WAIT .2.
            STAGE.
            WAIT .2.
            SET th TO curThr.
            }.
}.

// Функция вывода данных о полете
DECLARE FUNCTION prn {
  PARAMETER line.
  PRINT " Altitude:" + ROUND(ALTITUDE) + " m            " AT (2,line).
  PRINT " Vertical speed: " + ROUND(VERTICALSPEED) + " m/s             " AT (2,line+1).
  PRINT " Throttle: " + ROUND(th) + " %             " AT (2,line+2).
  PRINT " Apoapsis: " + ROUND(APOAPSIS)/1000 + " km             " AT (2,line+3).
  }.
