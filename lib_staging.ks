
// Функция определяет запущен ли двигатель (Ignition) и отсутствует ли топливо (Flameout).
// Если топливо отсутствует то переключаем флаг
// Если двигатель запущен то переключаем флаг
// Если оба флага были переключены, значит двигатель работает, но топливо кончилось, значит отделяем ступень
// 
DECLARE FUNCTION staging {
    SET engFlameOut to 0.
    SET engIgnition to 0.
    SET curThr to THROTTLE.
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
            STAGE .2.
            SET th TO curThr.
            }.
}.