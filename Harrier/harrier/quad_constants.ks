// Constants for the quad program

set QUAD_VEC_RANGE to 7.8.
set QUAD_MAX_ROT to 20.
set QUAD_MAX_FORTILT to 10.
set QUAD_MAX_LATTILT to 10.
set QUAD_MAX_THRUST to SHIP:MAXTHRUST.
set QUAD_MAX_CLIMBSINK to 10.

set k_rad to KERBIN:RADIUS.
set k_g to constant():G.
set k_mass to KERBIN:MASS.

set k_mu to k_g * k_mass.
function grav_force {
    // G * m / r^2
    return (k_mu * SHIP:MASS)/ ((k_rad + SHIP:ALTITUDE)^2).
}.

// Altitude correction for IMU height with landing gear.
set radar_alt_bias to -1.5802.

// VTOL Mode Gains
set vtol_pitch_Kpf to 0.04.
set vtol_pitch_Kpe to 0.04.

set vtol_pitch_Kif to 0.001.
set vtol_pitch_Kie to 0.001.

set vtol_pitch_Kdf to 0.03.
set vtol_pitch_Kde to 0.03.

set vtol_pitch_dlim to 15.
set vtol_pitch_ilim to 10.
set vtol_pitch_dz to 0.00.


set vtol_roll_Kpf to 0.04.
set vtol_roll_Kpe to 0.04.

set vtol_roll_Kif to 0.001.
set vtol_roll_Kie to 0.001.

set vtol_roll_Kdf to 0.03.
set vtol_roll_Kde to 0.03.

set vtol_roll_dlim to 15.
set vtol_roll_ilim to 5.
set vtol_roll_dz to 0.00.

set vtol_vv_Kpf to 0.15.
set vtol_vv_Kpe to 0.15.

set vtol_vv_Kif to 0.1.
set vtol_vv_Kie to 0.1.

set vtol_vv_Kdf to 0.0.
set vtol_vv_Kde to 0.0.

set vtol_vv_dlim to 5.
set vtol_vv_ilim to 5.
set vtol_vv_dz to 0.1.


set vtol_yawrate_Kpf to 0.6.
set vtol_yawrate_Kpe to 0.6.

set vtol_yawrate_Kif to 0.000.
set vtol_yawrate_Kie to 0.000.

set vtol_yawrate_Kdf to 0.1.
set vtol_yawrate_Kde to 0.1.

set vtol_yawrate_dlim to 10.
set vtol_yawrate_ilim to 5.
set vtol_yawrate_dz to 0.05.


set vtol_dir_Kpf to 0.013.
set vtol_dir_Kpe to 0.013.

set vtol_dir_Kif to 0.000.
set vtol_dir_Kie to 0.000.

set vtol_dir_Kdf to 0.00.
set vtol_dir_Kde to 0.00.

set vtol_dir_dlim to 20.
set vtol_dir_ilim to 5.
set vtol_dir_dz to 0.15.


set vtol_vfor_Kpf to 0.25.
set vtol_vfor_Kpe to 0.25.
set vtol_vfor_Kif to 0.125.
set vtol_vfor_Kie to 0.125.
set vtol_vfor_Kdf to 0.1.
set vtol_vfor_Kde to 0.1.

set vtol_vfor_dlim to 1.
set vtol_vfor_ilim to 0.01.
set vtol_vfor_dz to 0.0001.

set vtol_vlat_Kpf to 0.2.
set vtol_vlat_Kpe to 0.2.
set vtol_vlat_Kif to 0.06.
set vtol_vlat_Kie to 0.06.
set vtol_vlat_Kdf to 0.08.
set vtol_vlat_Kde to 0.08.

set vtol_vlat_dlim to 1.
set vtol_vlat_ilim to 0.02.
set vtol_vlat_dz to 0.0001.

set vtol_alt_Kpf to 0.05.
set vtol_alt_Kpe to 0.05.
set vtol_alt_Kif to 0.001.
set vtol_alt_Kie to 0.001.
set vtol_alt_Kdf to 0.0.
set vtol_alt_Kde to 0.0.

set vtol_alt_dlim to 2.
set vtol_alt_ilim to 0.1.
set vtol_alt_dz to 0.05.

set vtol_frontbias_empty to 0.545.
set vtol_frontbias_full to 0.555.
set vtol_frontbias_delta to vtol_frontbias_full - vtol_frontbias_empty.

set vtol_full_mass to 8.7457.
set vtol_empty_mass to 7.6168.
set vtol_delta_mass to vtol_full_mass - vtol_empty_mass.

set vtol_gainsched_a to 0.1.
set vtol_gainsched_b to (1 - vtol_gainsched_a * (vtol_delta_mass^2)) / vtol_delta_mass.

function oneway_lowpass_filter {
  declare parameter tc.
  declare parameter oldval.
  declare parameter newval.
  declare parameter minval.

  if newval = 0 {
    return oldval.
  }.

  if oldval > 0 {
    if newval < oldval and oldval < minval {
      return 0.
    }.
  } else if oldval < 0 {
    if newval > oldval and oldval > -minval {
      return 0.
    }.
  }.

  return (tc * newval) + ((1 - tc) * oldval).
}.
