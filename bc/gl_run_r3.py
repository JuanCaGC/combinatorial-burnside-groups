"""Run a scoped Julia script with redirected scratch and bounded wall time."""
import os
import subprocess
import sys
import time
from pathlib import Path
root = Path(__file__).resolve().parent
script, output = sys.argv[1:3]
limit = int(sys.argv[3]) if len(sys.argv) > 3 else 240
cmd = ['/Users/juancagc/.julia/juliaup/julia-1.12.4+0.aarch64.apple.darwin14/bin/julia', '--project=.', '--startup-file=no', '--compiled-modules=existing', 'gl_bootstrap.jl', script, *sys.argv[4:]]
env = dict(os.environ, TMPDIR=str(root / 'gl_tmp'), JULIA_HISTORY=str(root / 'gl_tmp' / 'history'))
(root / 'gl_tmp').mkdir(exist_ok=True)
start = time.monotonic()
with (root / output).open('w') as out:
    try:
        result = subprocess.run(cmd, cwd=root, env=env, stdout=out, stderr=subprocess.STDOUT, timeout=limit)
        status = f'RUN_EXIT {result.returncode} WALL_SECONDS {time.monotonic()-start:.3f}'
    except subprocess.TimeoutExpired:
        status = f'TIMEOUT {limit}s WALL_SECONDS {time.monotonic()-start:.3f}'
    out.write(status + '\n')
print(status)
