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
PRINT " Launch to orbit " + (apo/100) + " km and inc. " + inc + " degree " AT (2,1).
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
    PRINT " Vertical speed: " + ROUND(VERTICALSPEED) + " m/s           " AT (2,5).
    SET f TO 1. //Переход в фазу 1
    }.
  }.

UNTIL ALTITUDE > 500 {
  PRINT " Altitude:" + ROUND(ALTITUDE) + " m            " AT (2,4).
  PRINT " Vertical speed: " + ROUND(VERTICALSPEED) + " m/s             " AT (2,5).
  PRINT " Throttle: " + ROUND(th)*100 + " %             " AT (2,6).
  PRINT " Apoapsis: " + ROUND(APOAPSIS)/1000 + " km             " AT (2,7).
  SAS OFF.
  LOCK tv TO 2100.
  }.

//SET f TO 0.
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
    SET f to 2. //Переход к фазе 2
    }.

  //IF th < 1 AND f = 0 {
    //PRINT "max Q".
    //SET f TO 1.
    //}.
}.



  PRINT "Finish" AT (0,14).



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
