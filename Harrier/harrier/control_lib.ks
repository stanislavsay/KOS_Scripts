// Controls library

// Constants (indices) for accessing fields in control context "objects" (lists for now)
set ctlctx_name to 0.
set ctlctx_Kpf to 1.   // Proportional gain (full)
set ctlctx_Kif to 2.   // Integral gain (full)
set ctlctx_Kdf to 3.   // Derrivative gain (full)
set ctlctx_Kpe to 4.   // Proportional gain (empty)
set ctlctx_Kie to 5.   // Integral gain (empty)
set ctlctx_Kde to 6.   // Derrivative gain (empty)
set ctlctx_ilim to 7. // Integrator error limit (explained below)
set ctlctx_dlim to 8. // Derrivative error limit (explained below)
// Internal state
set ctlctx_i to 9. // Integrator value
set ctlctx_laste to 10. // Last error value for calculating derrivative
set ctlctx_lastlog to 11. // Last time we wrote to the log file
set ctlctx_enorml to 12. // Normalize the error via this in the log

set ctl_start_time to TIME:SECONDS.

// Initialize a control context "object" (list for now)
//    Kp: Proportional gain
//    Ki: Integral gain
//    Kd: Derrivative gain
// i_lim: Error below which integral term is applied
// d_lim: Error below which derrivative term is applied
function ctl_ctxinit {
  declare parameter name.
	declare parameter Kp_f.
	declare parameter Ki_f.
	declare parameter Kd_f.
  declare parameter Kp_e.
  declare parameter Ki_e.
  declare parameter Kd_e.
	declare parameter i_lim.
	declare parameter d_lim.
  declare parameter enorml.

  // Init log file
  log " " to (name + "_log.csv").
  delete (name + "_log.csv") from 0.
  log "names,time,error,Kp*e,Ki*i,Kd*d,out" to (name + "_log.csv").
  log "0,0,0,0,0,0" to (name + "_log.csv").

  return list(name, Kp_f, Ki_f, Kd_f, Kp_e, Ki_e, Kd_e, i_lim, d_lim, 0.0, 0.0, 0.0, enorml).
}.

// Runs a PID controller, returning the controller output value [-1.0 , 1.0]
// ctx: Controller context (we can modify it since it's a struct)
//   e: Current error term
//  dt: Time delta since last control interation
set last_print_time to 0.
function ctl_run_pid {
  declare parameter ctx.
  declare parameter e.
  declare parameter dt.
  declare parameter run_d.
  declare parameter gain_sched.
  declare parameter prnt.

  // Apply gain scheduling
  local Kp is ctx[ctlctx_Kpe] + ( (ctx[ctlctx_Kpf] - ctx[ctlctx_Kpe]) * (gain_sched) ).
  local Ki is ctx[ctlctx_Kie] + ( (ctx[ctlctx_Kif] - ctx[ctlctx_Kie]) * (gain_sched) ).
  local Kd is ctx[ctlctx_Kde] + ( (ctx[ctlctx_Kdf] - ctx[ctlctx_Kde]) * (gain_sched) ).

  local d is 0.0.
  // Calculate derivative if we're within limits to appy the Kd term.
  if dt > 0 and run_d and abs(e < ctx[ctlctx_dlim]) {
    set d to (e - ctx[ctlctx_laste]) / dt.
  }.
  set ctx[ctlctx_laste] to e. // Update the last error with the current in the context

  // Calculate integral if we're within limits to apply the Ki term.
  if Ki <> 0 and abs(e < ctx[ctlctx_ilim]) {
    set ctx[ctlctx_i] to ctx[ctlctx_i] + (e * dt).
    set ctx[ctlctx_i] to MIN( (1.0 / Ki), MAX( (-1.0 / Ki), ctx[ctlctx_i])).
  } else {
    set ctx[ctlctx_i] to 0.0.
  }.
  local i is ctx[ctlctx_i].

  // Calculate the output of the control equation.
  local output is ( (Kp * e) +
                    (Ki * i) +
                    (Kd * d) ).

  if prnt and (TIME:SECONDS - ctx[ctlctx_lastlog]) > 0.1 {
    local logfile is (ctx[ctlctx_name] + "_log.csv").
    //print "********".
    //print "e: " + e.
    //print "P: " + (Kp * e * 1000).
    //print "I: " + (Ki * i * 1000).
    //print "D: " + (Kd * d * 1000).
    //print "********".
    log (TIME:SECONDS - ctl_start_time) + "," + 
        (e / ctx[ctlctx_enorml]) + "," +
        (Kp * e) + "," +
        (Ki * i) + "," +
        (Kd * d) + "," +
        (output)
        to logfile.
    set ctx[ctlctx_lastlog] to TIME:SECONDS.
  }.

  // Bound the output and return
  return MIN(1.0, MAX(-1.0, output)).
}.

// Zero last error
function ctl_zero_laste {
  declare parameter ctx.

  set ctx[ctlctx_laste] to 0.0.
}.
