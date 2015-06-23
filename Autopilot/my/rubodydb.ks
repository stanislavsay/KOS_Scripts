//KOS bodystats: SETs up variables for use in programs
// that need stats about the orbital body that is the
// current SOI.  Looks up the body name and fills
// the appropriate variables.
DECLARE PARAMETER forBody.

PRINT "************************************************" AT (0,0).
PRINT "**    Connecting to KSC BodyDB...             **" AT (0,1).
PRINT "**      Query request...                      **" AT (0,2).
PRINT "************************************************" AT (0,3).

// Constants for important things that DON'T change per body:
// ==========================================================
SET gConst TO 6.67384*10^(0-11). // Гравитационная постоянная
SET pi TO 3.14159265359 . // Число Пи
SET e TO 2.718281828459 .
SET atmToPres TO 1.2230948554874 . // Давление 1.0 атм.

// Установка начальных значений констант, которые меняются для каждого тела:
// ========================================================
SET bodySurfaceGrav TO 10.   // Гравитация на поверхности  на уровне моря.
SET bodyMass TO 5.2915793*10^22. // Вес тела в килограммах.
SET bodyRadius TO 500000 .   // Радиус тела на уровне экватора.
SET bodyMaxElev TO 4000.     // Самая высокая точка поверхности в метрах.
SET bodyAtmSea TO 0.         // Атмосверное давление на уровне моря в кербинских единицах.
SET bodyAtmScale TO 0.       // Высота плотных слоев атмосферы в метрах.
SET descendTop TO 50000 .    // Высота начала атмосферного торможения (стратосфера) в метрах.
SET descendBot TO 100 .      // Высота перед касанием ЛА поверхности (высота зависания) в метрах.
SET descendTopSpeed TO 2000.0 . // Рекомендуемая скорость вхождения в атмосферу в м/с.
SET descendBotSpeed TO 4.0 .    // Рекомендуемая скорость перед посадкой ЛА в м/с.
SET bodyLandingSpeed TO 4.0.    // Рекомендуемая скорость посадки ЛА в м/с.

// Overrides for each body:
// ==========================

IF forBody = "Kerbin" {
  SET bodySurfaceGrav TO 9.802 .
  SET bodyRadius TO 600000 .
  SET bodyMass TO 5.2915793*10^22. 
  SET bodyMaxElev TO 6761 .
  SET bodyScaleHeight TO 5000 . 
  SET bodyAtmSea TO 1.0 .
  SET bodyAtmScale TO 5000 .
  SET descendTop TO 70000 .
  SET descendBot TO 150.
  SET descendTopSpeed TO 2100.0 .
  SET descendBotSpeed TO 6.0 .
  SET descendLandingSpeed TO 4.0 .
}.
IF forBody = "Mun" {
  SET bodySurfaceGrav TO 1.63 .
  SET bodyRadius TO 200000 .
  SET bodyMass TO 9.7600236*10^20.
  SET bodyMaxElev TO 7061 .
  SET descendTop TO 20000 .
  SET descendBot TO 80 .
  SET descendTopSpeed TO 542.0 .
  SET descendBotSpeed TO 6.0 .
  SET bodyLandingSpeed TO 1.0 .
}.
IF forBody = "Minmus" {
  SET bodySurfaceGrav TO 0.491 .
  SET bodyRadius TO 60000 .
  SET bodyMass TO 2.6457897*10^19.
  SET bodyMaxElev TO 5725 .
  SET descendTop TO 20000 .
  SET descendBot TO 50 .
  SET descendTopSpeed TO 274.0 .
  SET descendBotSpeed TO 5.0 .
  SET bodyLandingSpeed TO 2.0 .
}.
IF forBody = "Duna" {
  SET bodySurfaceGrav TO 2.94 .
  SET bodyRadius TO 320000 .
  SET bodyMass TO 4.5154812*10^21.
  SET bodyMaxElev TO 8264.
  SET bodyAtmSea TO 0.2 .
  SET bodyAtmScale TO 3000.
  SET descendTop TO 40000 .
  SET descendBot TO 100 .
  SET descendTopSpeed TO 1000.0 .
  SET descendBotSpeed TO 5.0 .
  SET bodyLandingSpeed TO 3.0 .
}.
IF forBody = "Ike" {
  SET bodySurfaceGrav TO 1.10 .
  SET bodyRadius TO 130000 .
  SET bodyMass TO 2.7821949*10^20.
  SET bodyMaxElev TO 12750 .
  SET descendTop TO 12000 .
  SET descendBot TO 50 .
  SET descendTopSpeed TO 534 .
  SET descendBotSpeed TO 5.0 .
  SET bodyLandingSpeed TO 3.0 .
}.

PRINT "**                                            **" AT (0,4).
PRINT "************************************************" AT (0,5).
PRINT "**                                            **" AT (0,6).
PRINT "************************************************" AT (0,7).
PRINT " Answer from KSC BodyDB: " + forBody + " " AT (5,6).
PRINT " " AT (0,8).
PRINT "bodySurfaceGrav  = " + bodySurfaceGrav AT (0,9).
PRINT "bodyRadius       = " + bodyRadius AT (0,10).
PRINT "bodyMass         = " + bodyMass AT (0,11).
PRINT "bodyAtmSea       = " + bodyAtmSea AT (0,12).
PRINT "bodyAtmScale     = " + bodyAtmScale AT (0,13).
PRINT "descendTop       = " + descendTop AT (0,14).
PRINT "descendBot       = " + descendBot AT (0,15).
PRINT "descendTopSpeed  = " + descendTopSpeed AT (0,16).
PRINT "descendBotSpeed  = " + descendBotSpeed AT (0,17).
PRINT "bodyLandingSpeed = " + bodyLandingSpeed AT (0,18).
PRINT "************************************************" AT (0,19).