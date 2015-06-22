// Engine library for the quad script

// Set engine power percentage
function quad_engines_set_power {
    declare parameter ctx.
    declare parameter fl.
    declare parameter fr.
    declare parameter bl.
    declare parameter br.

    set ctx[quadctx_engines][0]:thrustlimit to fl.
    set ctx[quadctx_engines][1]:thrustlimit to fr.
    set ctx[quadctx_engines][2]:thrustlimit to bl.
    set ctx[quadctx_engines][3]:thrustlimit to br.
}.

// Activate/Shutdown engines
function quad_engines_switch {
    declare parameter ctx.
    declare parameter switch.

    if switch = true {
        for engine in ctx[quadctx_engines] {
            engine:activate().
        }.
    } else {
        for engine in ctx[quadctx_engines] {
            engine:shutdown().
        }.
    }.
}.
