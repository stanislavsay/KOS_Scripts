// Create harrier control contexts

// Create quad control contexts
set vtol_pitch_ctx to ctl_ctxinit("pitch_ctl",
                                  vtol_pitch_Kpf, 
                                  vtol_pitch_Kif,
                                  vtol_pitch_Kdf,
                                  vtol_pitch_Kpe,
                                  vtol_pitch_Kie,
                                  vtol_pitch_Kde,
                                  vtol_pitch_ilim,
                                  vtol_pitch_dlim,
                                  10).

set vtol_roll_ctx to ctl_ctxinit("roll_ctl",
                                 vtol_roll_Kpf,
                                 vtol_roll_Kif,
                                 vtol_roll_Kdf,
                                 vtol_roll_Kpe,
                                 vtol_roll_Kie,
                                 vtol_roll_Kde,
                                 vtol_roll_ilim,
                                 vtol_roll_dlim,
                                 10).

set vtol_vv_ctx to ctl_ctxinit("vv_ctl",
                               vtol_vv_Kpf,
                               vtol_vv_Kif,
                               vtol_vv_Kdf,
                               vtol_vv_Kpe,
                               vtol_vv_Kie,
                               vtol_vv_Kde,
                               vtol_vv_ilim,
                               vtol_vv_dlim,
                               10).

set vtol_yawrate_ctx to ctl_ctxinit("yawrate_ctl",
                                    vtol_yawrate_Kpf,
                                    vtol_yawrate_Kif,
                                    vtol_yawrate_Kdf,
                                    vtol_yawrate_Kpe,
                                    vtol_yawrate_Kie,
                                    vtol_yawrate_Kde,
                                    vtol_yawrate_ilim,
                                    vtol_yawrate_dlim,
                                    10).

set vtol_dir_ctx to ctl_ctxinit("dir_ctl",
                                vtol_dir_Kpf,
                                vtol_dir_Kif,
                                vtol_dir_Kdf,
                                vtol_dir_Kpe,
                                vtol_dir_Kie,
                                vtol_dir_Kde,
                                vtol_dir_ilim,
                                vtol_dir_dlim,
                                10).

set vtol_vfor_ctx to ctl_ctxinit("vfor_ctl",
                                  vtol_vfor_Kpf,
                                  vtol_vfor_Kif,
                                  vtol_vfor_Kdf,
                                  vtol_vfor_Kpe,
                                  vtol_vfor_Kie,
                                  vtol_vfor_Kde,
                                  vtol_vfor_ilim,
                                  vtol_vfor_dlim,
                                  0.1).

set vtol_vlat_ctx to ctl_ctxinit("vlat_ctl",
                                  vtol_vlat_Kpf,
                                  vtol_vlat_Kif,
                                  vtol_vlat_Kdf,
                                  vtol_vlat_Kpe,
                                  vtol_vlat_Kie,
                                  vtol_vlat_Kde,
                                  vtol_vlat_ilim,
                                  vtol_vlat_dlim,
                                  1).

set vtol_alt_ctx to ctl_ctxinit("alt_ctl",
                                 vtol_alt_Kpf,
                                 vtol_alt_Kif,
                                 vtol_alt_Kdf,
                                 vtol_alt_Kpe,
                                 vtol_alt_Kie,
                                 vtol_alt_Kde,
                                 vtol_alt_ilim,
                                 vtol_alt_dlim,
                                 10).

// List of control contexts
set vtol_ctlctxs to list(vtol_pitch_ctx,
                         vtol_roll_ctx,
                         vtol_vv_ctx,
                         vtol_yawrate_ctx,
                         vtol_dir_ctx,
                         vtol_vfor_ctx,
                         vtol_vlat_ctx,
                         vtol_alt_ctx).

// Get references to the VTOL engine parts
set vtol_engines to list(SHIP:partsdubbed("FLEng")[0], 
                         SHIP:partsdubbed("FREng")[0], 
                         SHIP:partsdubbed("BLEng")[0], 
                         SHIP:partsdubbed("BREng")[0]).

// Create the servo controller contexts
set vtol_flservo to servo_ctxinit("FLServo",
                                  -90.0,
                                  90.0,
                                  50.0,
                                  0.325,
                                  0.0005,
                                  0.48,
                                  0.05).
set vtol_frservo to servo_ctxinit("FRServo",
                                  -90.0,
                                  90.0,
                                  50.0,
                                  0.325,
                                  0.0005,
                                  0.48,
                                  0.05).
set vtol_blservo to servo_ctxinit("BLServo",
                                  -90.0,
                                  90.0,
                                  50.0,
                                  0.325,
                                  0.0005,
                                  0.48,
                                  0.05).
set vtol_brservo to servo_ctxinit("BRServo",
                                  -90.0,
                                  90.0,
                                  50.0,
                                  0.325,
                                  0.0005,
                                  0.48,
                                  0.05).
set vtol_servos to list(vtol_flservo, vtol_frservo, 
                        vtol_blservo, vtol_brservo).


// Create deadzones list
set vtol_deadzones to list(vtol_pitch_dz,
                           vtol_roll_dz,
                           vtol_vv_dz,
                           vtol_yawrate_dz,
                           vtol_dir_dz,
                           vtol_vfor_dz,
                           vtol_vlat_dz,
                           vtol_alt_dz).

// Init VTOL context
set vtol_ctx to quad_ctxinit("gr",
                             vtol_ctlctxs,
                             vtol_servos,
                             vtol_engines,
                             vtol_deadzones).
