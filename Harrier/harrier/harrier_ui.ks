// User controls for the harrier.
declare parameter fbw_mode.

lock pilotpitch to SHIP:CONTROL:PILOTPITCH.
lock pilotroll to SHIP:CONTROL:PILOTROLL.
lock pilotyaw to SHIP:CONTROL:PILOTYAW.

// For debugging
local lock blctx to vtol_ctx[quadctx_servos][quadctx_blservo].

// Filtered control input values for fbw
set fbw_filteredpitch to 0.
set fbw_filteredroll to 0.
set fbw_filteredyaw to 0.

set maxpitch to 7.
set maxroll to 7.

function run_vtol_fbw {
  declare parameter ctx.

  // Lock out control surfaces.
  set SHIP:CONTROL:PITCH to 0.02.
  set SHIP:CONTROL:ROLL to 0.02.
  set SHIP:CONTROL:YAW to -0.02.

  // Filter pilot inputs
  set fbw_filteredpitch to oneway_lowpass_filter(0.10,
                                                 fbw_filteredpitch,
                                                 pilotpitch,
                                                 0.1).
  set fbw_filteredroll to oneway_lowpass_filter(0.08,
                                                fbw_filteredroll,
                                                pilotroll,
                                                0.1).
  set fbw_filteredyaw to oneway_lowpass_filter(0.04,
                                               fbw_filteredyaw,
                                               pilotyaw,
                                               0.1).

  // Set pitch and roll setpoints
  quad_set_pitch_sp_abs(ctx, maxpitch * fbw_filteredpitch).
  quad_set_roll_sp_abs(ctx, maxroll * fbw_filteredroll).
}.

// Emergency cut (not recomended in flight)
ON AG10 {
    //set quad_logging to (not quad_logging).
    quad_radar_alt_mode(vtol_ctx, not radar_alt_mode).
    PRESERVE.
}

ON AG9 {
    if vtol_state = "gr" {
        set next_state to "to".
    } else if vtol_state = "ab" {
        set next_state to "ld".
    }.
    PRESERVE.
}.

ON AG1 {
  //quad_set_roll_sp_rel(vtol_ctx, -0.5).
  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vlatSP]) > 0.99 {
    quad_set_vlat_sp_rel(vtol_ctx, -1.0).
  } else {
    quad_set_vlat_sp_rel(vtol_ctx, -0.1).
  }.

  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vlatSP]) < 0.05 {
    set vtol_ctx[quadctx_ctlSPs][quadctx_vlatSP] to 0.
  }

  PRESERVE.
}.

ON AG2 {
  //quad_set_roll_sp_rel(vtol_ctx, 0.5).
  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vlatSP]) >= 0.99 {  
    quad_set_vlat_sp_rel(vtol_ctx, 1.0).
  } else {
    quad_set_vlat_sp_rel(vtol_ctx, 0.1).
  }

  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vlatSP]) < 0.05 {
    set vtol_ctx[quadctx_ctlSPs][quadctx_vlatSP] to 0.
  }
  
  PRESERVE.
}.

ON AG5 {
  quad_set_dir_sp_rel(vtol_ctx, -10.0).
  //quad_set_yawrate_sp_rel(vtol_ctx, -5).
  //servo_set_rot(blctx, blctx[servoctx_sp] - 10).
  PRESERVE.
}.

ON AG6 {
  quad_set_dir_sp_rel(vtol_ctx, 10.0).
  //quad_set_yawrate_sp_rel(vtol_ctx, 5).
  //servo_set_rot(blctx, blctx[servoctx_sp] + 10).
  PRESERVE.
}.

ON AG3 {
  //quad_set_pitch_sp_rel(vtol_ctx, -0.5).
  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vforSP]) > 0.99 {
    quad_set_vfor_sp_rel(vtol_ctx, -1.0).
  } else {
    quad_set_vfor_sp_rel(vtol_ctx, -0.1).
  }.

  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vforSP]) < 0.05 {
    set vtol_ctx[quadctx_ctlSPs][quadctx_vforSP] to 0.
  }

  PRESERVE.
}.

ON AG4 {
  //quad_set_pitch_sp_rel(vtol_ctx, 0.5).
  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vforSP]) >= 0.99 {  
    quad_set_vfor_sp_rel(vtol_ctx, 1.0).
  } else {
    quad_set_vfor_sp_rel(vtol_ctx, 0.1).
  }

  if abs(vtol_ctx[quadctx_ctlSPs][quadctx_vforSP]) < 0.05 {
    set vtol_ctx[quadctx_ctlSPs][quadctx_vforSP] to 0.
  }

  PRESERVE.
}.

ON AG7 {
  //quad_set_vv_sp_rel(vtol_ctx, -0.5).
  quad_set_alt_sp_rel(vtol_ctx, -1).
  PRESERVE.
}.

ON AG8 {
  quad_set_alt_sp_rel(vtol_ctx, 1).
  PRESERVE.
}.
