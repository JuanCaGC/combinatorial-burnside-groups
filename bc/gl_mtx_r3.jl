using Oscar
r = isempty(ARGS) ? 3 : parse(Int,ARGS[1])
println("JULIA_VERSION ",VERSION," OSCAR_VERSION ",pkgversion(Oscar))
GAP.evalstr("Read(\"gl_action_r$(r)_data.g\");")
GAP.evalstr("Read(\"gl_mtx_r3.g\");")
@assert GAP.evalstr("ForAll(BCmoduli, x -> x=2)") == true
GAP.evalstr("BCAnalyse(BCmats, BCrows, BCp, BCr);")
print(read("gl_mtx_r$(r)_gap_raw.txt",String))
println("MTX_SCRIPT_COMPLETE")
