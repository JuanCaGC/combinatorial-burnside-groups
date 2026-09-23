"""Run the two scoped action cases with a 180s wall limit including startup."""
import subprocess
from pathlib import Path
root=Path(__file__).resolve().parent
cmd=['/Users/juancagc/.julia/juliaup/julia-1.12.4+0.aarch64.apple.darwin14/bin/julia','--project=.','--startup-file=no','--compiled-modules=existing','gl_bootstrap.jl','gl_action.jl']
with (root/'gl_action_output.txt').open('w') as out:
    try:
        result=subprocess.run(cmd,cwd=root,stdout=out,stderr=subprocess.STDOUT,timeout=180)
        print('EXIT',result.returncode)
    except subprocess.TimeoutExpired:
        out.write('TIMEOUT 180s\n'); print('TIMEOUT 180s')
