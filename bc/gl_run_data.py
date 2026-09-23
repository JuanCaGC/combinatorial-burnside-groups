"""Run each group in an isolated process with a 180s wall timeout, including startup."""
import subprocess, time, os
from pathlib import Path
root = Path(__file__).resolve().parent
with (root/'gl_data_output.txt').open('w') as out:
    for p in (2,3,5):
        for r in (1,2,3):
            started=time.monotonic()
            try:
                result=subprocess.run(['/Users/juancagc/.julia/juliaup/julia-1.12.4+0.aarch64.apple.darwin14/bin/julia','--project=.','--startup-file=no','--compiled-modules=existing','gl_bootstrap.jl','gl_data.jl',str(p),str(r)],cwd=root,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=180)
                text=result.stdout+f'PROCESS p={p} r={r} exit={result.returncode} wall={time.monotonic()-started:.3f}\n'
            except subprocess.TimeoutExpired as e:
                text=(e.stdout or b'').decode()+f'TIMEOUT p={p} r={r} limit=180s\n'
            out.write(text); out.flush(); print(text,flush=True)
