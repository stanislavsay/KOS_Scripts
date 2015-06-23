CLEARSCREEN.


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
PRINT " Запуск ЛА на орбиту " + (apo/100) + " км с наклонением " + inc + " град. " AT (2,1).
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

// Начинаем предстартовый отсчет
UNTIL Countdown > 0 {
  PRINT " Отсчет :" + Countdown + "..." AT (2,4).
  WAIT .5.
  SET Countdown TO Countdown - 1.
  }.

staging().
PRINT " ПУСК!!! " AT (2,4).

UNTIL ALTITUDE > 300 {
  IF VERTICALSPEED > 5 and f = 0 {
    PRINT "Есть отрыв!" AT (2,4).
    SET f TO 1. //Переход в фазу 2
    }.
  }.

UNTIL ALTITUDE > 500 {
  PRINT " Высота 500 м" AT (2,4).
  SAS OFF.
  LOCK tv TO 2000.
  }.



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
