"""Dimension-only arithmetic, using top pieces printed by gl_data.jl."""
from pathlib import Path
from math import comb
root=Path(__file__).resolve().parent
for line in (root/'gl_data_output.txt').read_text().splitlines():
    if not line.startswith('DATA\t'): continue
    _,p,m,n,total,pairs,st,bc,top,rank=line.split('\t')
    p,m,n,rank=map(int,(p,m,n,rank))
    sym=[comb(m+k-1,k) for k in range(7)]
    ext=[comb(m,k) if k<=m else 0 for k in range(7)]
    stein=p**(m*(m-1)//2)
    print(f'DIM p={p} m={m} n={n} top={top} rank={rank} Sym(k=0..6)={sym} Lambda(k=0..6)={ext} St={stein} matches_Sym={[k for k,d in enumerate(sym) if d==rank]} matches_Lambda_nonzero={[k for k,d in enumerate(ext) if d==rank and d>0]} match_St={rank==stein}')
