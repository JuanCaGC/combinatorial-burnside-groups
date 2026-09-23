"""Independent Python-integer checks of saved Julia certificates and n=2 actions.
No Julia, OSCAR, GAP, numerical library, or Smith routine is called.
"""
import ast
from pathlib import Path
root=Path(__file__).resolve().parent

def mm(A,B):
    if not A: return []
    assert B and len(A[0])==len(B)
    return [[sum(a*b for a,b in zip(row,col)) for col in zip(*B)] for row in A]
def ident(n):return [[int(i==j) for j in range(n)] for i in range(n)]
def sub(A,B):return [[a-b for a,b in zip(x,y)] for x,y in zip(A,B)]
def det(A):
    A=[r[:] for r in A]; n=len(A); sign=1; previous=1
    if n==0:return 1
    for k in range(n-1):
        j=next((j for j in range(k,n) if A[j][k]),None)
        if j is None:return 0
        if j!=k:A[j],A[k]=A[k],A[j];sign=-sign
        pivot=A[k][k]
        for i in range(k+1,n):
            for j in range(k+1,n):
                value=A[i][j]*pivot-A[i][k]*A[k][j]
                assert value%previous==0
                A[i][j]=value//previous
            A[i][k]=0
        previous=pivot
    return sign*A[-1][-1]
def smith_check(A,U,V,D):
    assert mm(mm(U,A),V)==D if A else D==[] and U==[]
    assert abs(det(U))==abs(det(V))==1
    assert all(x==0 for i,row in enumerate(D) for j,x in enumerate(row) if i!=j)
    diag=[abs(D[i][i]) for i in range(min(len(D),len(V)))]
    nz=[x for x in diag if x]
    assert diag[:len(nz)]==nz
    assert all(b%a==0 for a,b in zip(nz,nz[1:]))
def lattice(X,D):
    for row in X:
        for j,x in enumerate(row):
            d=D[j][j] if j<len(D) else 0
            assert (x%d==0) if d else (x==0)
def congruent(X,Y,ds):
    for x,y in zip(X,Y):
        for a,b,d in zip(x,y,ds):assert (a-b)%d==0 if d else a==b

certs={}
for line in (root/'gl_action_certificates.txt').read_text().splitlines():
    key,value=line.split('=',1)
    if key=='p':p=int(value);certs[p]={}
    else:certs[p][key]=ast.literal_eval(value.replace('Vector{Int64}[]','[]'))
outputs={}
for line in (root/'gl_action_output.txt').read_text().splitlines():
    if line.startswith('ACTION_CASE p='):
        p=int(line.split()[1].split('=')[1]);outputs[p]={'actions':[]}
    for prefix in ['CHARACTERS','TUPLES','FINAL_PROJECTION_Q','FINAL_LIFTS_L']:
        if line.startswith(prefix+'='):outputs[p][prefix]=ast.literal_eval(line.split('=',1)[1])
    if line.startswith('GEN '):outputs[p]['actions'].append(ast.literal_eval(line.split('final_row_matrix=')[1]))
for p,c in certs.items():
    A,U0,V0,D0=[c[k] for k in ['A','U_full','V_full','D_full']]
    E,J,M,U,V,D=[c[k] for k in ['E','J','M','U','V','D']]
    smith_check(A,U0,V0,D0);smith_check(M,U,V,D)
    assert mm(J,E)==ident(len(J))
    lattice(mm(mm(A,E),V),D)
    lattice(mm(mm(M,J),V0),D0)
    lattice(mm(sub(ident(len(A[0])),mm(E,J)),V0),D0)
    out=outputs[p]; chars=out['CHARACTERS']; tuples=out['TUPLES']; Q=out['FINAL_PROJECTION_Q'];L=out['FINAL_LIFTS_L']
    # Independent description of n=2 generators: unordered bases of F_p^2.
    independent=lambda a,b:(a[0]*b[1]-a[1]*b[0])%p!=0
    expected=[[i+1,j+1] for i,a in enumerate(chars) for j,b in enumerate(chars) if i<j and independent(a,b)]
    assert tuples==expected and len(tuples)==(p*p-1)*(p*p-p)//2
    index={tuple(t):i for i,t in enumerate(tuples)};ci={tuple(c):i+1 for i,c in enumerate(chars)}
    expected_rows=[]
    for i,(ai,bi) in enumerate(tuples):
        a,b=chars[ai-1],chars[bi-1]
        minus=lambda x,y:ci[tuple((xx-yy)%p for xx,yy in zip(x,y))]
        row=[0]*len(tuples);row[i]+=1
        row[index[tuple(sorted([minus(a,b),bi]))]]-=1
        row[index[tuple(sorted([ai,minus(b,a)]))]]-=1
        expected_rows.append(row)
    assert A==expected_rows
    ds=[2,2] if p==2 else [0]*7
    assert mm(L,Q)==ident(len(ds))
    # These character matrices are inverse transposes of T,D,S, independently.
    cms=[[[1,0],[-1%p,1]],[[1 if p==2 else 2,0],[0,1]],[[0,1],[1,0]]]
    perms=[]
    for C,R in zip(cms,out['actions']):
        cp=[ci[tuple(sum(C[i][j]*x[j] for j in range(2))%p for i in range(2))] for x in chars]
        perm=[index[tuple(sorted(cp[a-1] for a in t))] for t in tuples]
        perms.append(perm)
        PQ=[Q[k] for k in perm]
        congruent(PQ,mm(Q,R),ds)
        congruent(mm(L,PQ),R,ds)
    seen={tuple(range(len(tuples)))};stack=list(seen)
    while stack:
        g=stack.pop()
        for h in perms:
            hg=tuple(h[i] for i in g)
            if hg not in seen:seen.add(hg);stack.append(hg)
    assert len(seen)==(p*p-1)*(p*p-p)
    action=lambda perm:mm(L,[Q[i] for i in perm])
    for g in seen:
        for h in perms:congruent(mm(action(g),action(h)),action([h[i] for i in g]),ds)
    print(f'PYTHON VERIFIED p={p}: independent unordered-basis enumeration and blow-up rows; full/residual Smith certificates with unimodular transforms; inverse quotient maps; 3 action matrices; all {len(seen)*3} composition checks. Group order={len(seen)}.')
