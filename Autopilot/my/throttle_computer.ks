
// ######################################################################
//    AERODYNAMIC THROTTLE
// ######################################################################

  IF THROTTLE_MODE = "AERODYNAMIC" {
    SET CONFIG:SAFE TO FALSE.
    IF termvel < 2000 {
      SET THROTTLE_GOAL_MODE TO TRUE.
      SET THROTTLE_GOAL_MINIMUM TO termvel * 0.9.
      SET THROTTLE_GOAL_MAXIMUM TO termvel * 1.1.
      SET THROTTLE_GOAL_INPUT TO SHIP:AIRSPEED * COS(ANGLE_OF_ATTACK).
    }
    ELSE
    {
      SET THROTTLE_GOAL_MODE TO FALSE.
      SET THROTTLE_UNSAFE_LOCK TO 1.
    }
    SET CONFIG:SAFE TO TRUE.
  }

// ######################################################################
//    DESCENT
// ######################################################################

  ELSE IF THROTTLE_MODE = "DESCENT" {
    SET THROTTLE_GOAL_MODE TO TRUE.
    SET THROTTLE_GOAL_MINIMUM TO DESCENT_SPEED_GOAL - DESCENT_SPEED_FUZZ / 2.
    SET THROTTLE_GOAL_MAXIMUM TO DESCENT_SPEED_GOAL + DESCENT_SPEED_FUZZ / 2.
    SET THROTTLE_GOAL_INPUT TO SHIP:VERTICALSPEED.
  }

// ######################################################################
//    TIME/APOAPSIS
// ######################################################################

  ELSE IF THROTTLE_MODE = "TIME_APOAPSIS" {
    IF TIME_TO_ORBITAL_VELOCITY > 0 {
      SET THROTTLE_GOAL_MODE TO TRUE.
      SET THROTTLE_GOAL_MAXIMUM TO MAX(1, TIME_TO_ORBITAL_VELOCITY * TIME_APOAPSIS_SAFETY_MARGIN).
      SET THROTTLE_GOAL_MINIMUM TO 0.
      IF ETA:APOAPSIS < ETA:PERIAPSIS {
        SET THROTTLE_GOAL_INPUT TO ETA:APOAPSIS.
      }
      ELSE {
        SET THROTTLE_GOAL_INPUT TO 0.
      }
    }
    ELSE {
      SET THROTTLE_GOAL_MODE TO FALSE.
      SET THROTTLE TO 0.
    }
  }

// ######################################################################
//    MANUAL THROTTLE
// ######################################################################

  ELSE IF THROTTLE_MODE = "MANUAL" {
    SET THROTTLE_GOAL_MODE TO FALSE.
    UNLOCK THROTTLE.
  }

// ######################################################################
//    GOAL MODE
// ######################################################################

  IF THROTTLE_GOAL_MODE {
    SET THROTTLE_UNSAFE_LOCK TO 
      MAX(0, 
        MIN(1,
          (THROTTLE_GOAL_INPUT - THROTTLE_GOAL_MAXIMUM) /
          (THROTTLE_GOAL_MINIMUM - THROTTLE_GOAL_MAXIMUM)
            )).

    SET THROTTLE_UNSAFE_LOCK TO RECOMMENDED_HOVER_THROTTLE_LOW + THROTTLE_UNSAFE_LOCK * (1-RECOMMENDED_HOVER_THROTTLE_LOW).

    IF THROTTLE_STAGE_SAFETY {
      SET THROTTLE_UNSAFE_LOCK TO MIN(0.1, THROTTLE_UNSAFE_LOCK).
    }

    SET THROTTLE_SAFE_LOCK TO THROTTLE_UNSAFE_LOCK.
    LOCK THROTTLE TO THROTTLE_SAFE_LOCK.
  }

