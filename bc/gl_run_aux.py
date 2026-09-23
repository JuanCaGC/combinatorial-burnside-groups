"""Run priorities 1b, 3 and the installation probe with bounded processes."""
import subprocess
from pathlib import Path
root=Path(__file__).resolve().parent
julia='/Users/juancagc/.julia/juliaup/julia-1.12.4+0.aarch64.apple.darwin14/bin/julia'
for script in ['gl_cyclic.jl','gl_dimensions.py','gl_packages.jl']:
    cmd=([julia,'--project=.','--startup-file=no','--compiled-modules=existing','gl_bootstrap.jl',script] if script.endswith('.jl') else ['python3',script])
    try:
        proc=subprocess.run(cmd,cwd=root,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True,timeout=180)
        output=proc.stdout+f'EXIT {proc.returncode}\n'
    except subprocess.TimeoutExpired as e:
        output=(e.stdout or b'').decode()+'TIMEOUT 180s\n'
    (root/(Path(script).stem+'_output.txt')).write_text(output)
    print(output,flush=True)
