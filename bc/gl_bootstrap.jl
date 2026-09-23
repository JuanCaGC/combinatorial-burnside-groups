# Keep installed package/cache paths; redirect runtime scratch writes into this copy.
ENV["JULIA_SCRATCH_TRACK_ACCESS"] = "0"
using UUIDs, Pkg
# Pkg has no log-directory environment override; this process-local method only
# redirects its usage bookkeeping, not dependency resolution or computation.
@eval Pkg logdir() = $(joinpath(@__DIR__, "gl_local_depot", "logs"))
const GLScratch = Base.require(Base.PkgId(UUID("6c6a2e73-6563-6170-7368-637461726353"), "Scratch"))
GLScratch.SCRATCH_DIR_OVERRIDE[] = joinpath(@__DIR__, "gl_scratch")
include(joinpath(@__DIR__, popfirst!(ARGS)))
