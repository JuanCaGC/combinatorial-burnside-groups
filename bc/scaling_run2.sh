#!/bin/zsh
run() { perl -e 'alarm 600; exec @ARGV' julia --project=. scaling.jl "$@" 2>&1 | tail -6; echo "--- exit for $1 done"; }
run He7 2 3
run PSL28 2 3 4
run PSL29 2 3 4
run M11 2 3 4
run D31 2
run C2^5 2 3 4
run S10 2 3
