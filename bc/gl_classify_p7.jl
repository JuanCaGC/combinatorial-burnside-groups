include("BurnsideC.jl")
using .BurnsideC, Oscar, Serialization
const B=BurnsideC
matrows(A)=[[Int(A[i,j]) for j in 1:ncols(A)] for i in 1:nrows(A)]
function main()
rawdata=deserialize("gl_action_p7_data.bin")
r=merge(rawdata,(Q=matrix(ZZ,rawdata.Q),L=matrix(ZZ,rawdata.L),actions=[matrix(ZZ,R) for R in rawdata.actions]))
p=r.p
GAP.evalstr(raw"""
P7Setup := function(p,a)
 local gs,g,es,tbl,reps;
 gs := [[[1,1],[0,1]],[[a,0],[0,1]],[[0,1],[1,0]]]*Z(p)^0;
 g := Group(gs);
 es := Elements(g);
 tbl := CharacterTable(g);
 reps := List(ConjugacyClasses(tbl),Representative);
 return rec(gs:=gs,g:=g,es:=es,tbl:=tbl,
 data:=rec(elements:=List(es,x->List(x,row->List(row,IntFFE))),
 edges:=List(es,x->List(gs,y->Position(es,x*y))),
 identity:=Position(es,One(g)), reps:=List(reps,x->Position(es,x))));
end;;
""")
s=GAP.Globals.P7Setup(p,r.primitive)
data=GAP.gap_to_julia(s.data;recursive=true)
es=data[:elements]; edges=data[:edges]; id=data[:identity]; reps=data[:reps]
@assert length(es)==2016
ctx=B.CharCtx([p,p]); col=Dict(g=>i for (i,g) in enumerate(r.gens))
function cp(a)
 af=matrix(GF(p),reduce(vcat,permutedims.(a)))
 cm=[Int(lift(ZZ,transpose(inv(af))[i,j])) for i in 1:2,j in 1:2]
 B.char_perm(ctx,cm)
end
function action(perm)
 r.L*r.Q[[col[sort(perm[g])] for g in r.gens],:]
end
congruent(X,Y)=all(r.moduli[j]==0 ? X[i,j]==Y[i,j] : iszero(mod(X[i,j]-Y[i,j],r.moduli[j])) for i in 1:nrows(X),j in 1:ncols(X))
gp=[cp([collect(a[i,:]) for i in 1:2]) for a in r.mats]
hp=Dict(id=>collect(1:ctx.m)); ap=deepcopy(hp); queue=[id]
for k in queue
 for j in 1:3
  h=edges[k][j]
  if !haskey(hp,h)
   hp[h]=gp[j][hp[k]]
   ap[h]=ap[k][gp[j]]
   push!(queue,h)
  end
 end
end
@assert length(queue)==2016
ti=findall(!=(0),r.moduli); fi=findall(==(0),r.moduli)
println("DIMENSIONS torsion_moduli=$(r.moduli[ti]) free_rank=$(length(fi))")
hm=0; am=0; chars=zeros(Int,2016); tors=Any[]
for k in eachindex(es)
 actual=action(cp(es[k]))
 hm+=!congruent(actual,action(hp[k]))
 am+=!congruent(actual,action(ap[k]))
 chars[k]=Int(tr(actual[fi,fi]))
 push!(tors,matrows(actual[ti,ti]))
end
println("DIRECT_CONVENTION elements=2016 hom_assignment_mismatches=$hm anti_assignment_mismatches=$am")
@assert am==0
println("SELECTED R_(g*h)=R_h*R_g. Transposes define the genuine homomorphism.")
for (label,R) in zip(["T","D","S"],r.actions)
 println("BLOCK $label torsion_rows_free_columns_zero=$(iszero(R[ti,fi])) free_rows_torsion_columns_zero=$(all(iszero(mod(R[i,j],r.moduli[j])) for i in fi,j in ti))")
end
GAP.evalstr(raw"""
P7Character := function(s,chi)
 local tbl,irr,degs,mults,inner,counts;
 tbl:=s.tbl;
 irr:=Irr(tbl);
 degs:=List(irr,x->Int(x[1]));
 mults:=List(irr,x->Int(Sum([1..Length(chi)],k->SizesConjugacyClasses(tbl)[k]*chi[k]*ComplexConjugate(x[k]))/Size(s.g)));
 if not ForAll(mults,x->x>=0) then Error("negative multiplicity"); fi;
 inner:=Int(Sum([1..Length(chi)],k->SizesConjugacyClasses(tbl)[k]*chi[k]^2)/Size(s.g));
 counts:=Collected(degs);
 return rec(degrees:=degs,multiplicities:=mults,degree_counts:=counts,
 dimension:=Sum([1..Length(degs)],i->degs[i]*mults[i]),
 inner_product:=inner,sum_multiplicities_squared:=Sum(mults,x->x^2),
 degree_squares:=Sum(degs,x->x^2),class_sizes:=SizesConjugacyClasses(tbl),
 class_orders:=OrdersClassRepresentatives(tbl),character:=chi,
 constituents:=List(Filtered([1..Length(degs)],i->mults[i]>0),i->[i,degs[i],mults[i]]));
end;;
P7Torsion := function(s,rs,prime)
 local mats,m,factors,detvalues,k,d,rr,factorsdet,scalarpowers,e,n,na,du;
 mats:=List(rs,x->TransposedMat(x)*Z(prime)^0);
 m:=GModuleByMats(mats,GF(prime));
 factors:=MTX.CompositionFactors(m);
 n:=Length(mats[1]);
 na:=false; du:=false;
 if prime=7 and n=2 then
  na:=MTX.IsEquivalent(m,GModuleByMats(s.gs,GF(prime)));
  du:=MTX.IsEquivalent(m,GModuleByMats(List(s.gs,x->TransposedMat(x^-1)),GF(prime)));
 fi;
 return rec(prime:=prime,dimension:=n,irreducible:=MTX.IsIrreducible(m),
 factor_dimensions:=List(factors,MTX.Dimension),natural_isomorphic:=na,dual_natural_isomorphic:=du,
 image_order:=Size(Group(mats)),generator_matrices:=List(mats,x->List(x,row->List(row,IntFFE))));
end;;
""")
c=GAP.gap_to_julia(GAP.Globals.P7Character(s,GAP.GapObj(chars[reps]));recursive=true)
for (k,v) in sort(collect(pairs(c));by=x->string(first(x)))
 println("CHARACTER $k = $v")
end
@assert c[:dimension]==length(fi) && c[:inner_product]==c[:sum_multiplicities_squared] && c[:degree_squares]==2016
@assert c[:degree_counts]==[[1,6],[6,21],[7,6],[8,15]]
for prime in [2,7]
 @assert all(d->d==14,r.moduli[ti])
 rs=[matrows(R[ti,ti]) for R in r.actions]
 mt=GAP.gap_to_julia(GAP.Globals.P7Torsion(s,GAP.GapObj(rs;recursive=true),prime);recursive=true)
 println("MTX $mt")
 values=Dict{Int,Any}(); mismatches=0
 for (a,rr) in zip(es,tors)
  d=mod(a[1][1]*a[2][2]-a[1][2]*a[2][1],p)
  value=[mod.(row,prime) for row in rr]
  if haskey(values,d)
   mismatches+=values[d]!=value
  else
   values[d]=value
  end
 end
 println("DETERMINANT prime=$prime exhaustive_elements=2016 mismatches=$mismatches factors_through_det=$(mismatches==0) values=$(sort(collect(values);by=first))")
 if prime==7 && mismatches==0
  D=matrix(GF(prime),r.actions[2][ti,ti])
  eigendims=[length(ti)-rank(D-GF(prime)(powermod(r.primitive,e,prime))*identity_matrix(GF(prime),length(ti))) for e in 0:prime-2]
  @assert sum(eigendims)==length(ti)
  println("DETERMINANT_CHARACTER exponents=$(collect(0:prime-2)) multiplicities=$eigendims meaning=direct_sum_of_det_powers")
 end
 flush(stdout)
 # A row section [X,I] is invariant exactly when X*A - F*X = -C.
 nt=length(ti); nf=length(fi); field=GF(prime)
 H=zero_matrix(field,3*nf*nt,nf*nt); b=zero_matrix(field,3*nf*nt,1)
 for (k,R) in enumerate(r.actions), i in 1:nf,j in 1:nt
  eq=(k-1)*nf*nt+(i-1)*nt+j
  b[eq,1]=-R[fi[i],ti[j]]
  for a in 1:nt
   H[eq,(i-1)*nt+a]+=R[ti[a],ti[j]]
  end
  for l in 1:nf
   H[eq,(l-1)*nt+j]-=R[fi[i],fi[l]]
  end
 end
 rh=rank(H); ra=rank(hcat(H,b))
 println("SPLITTING prime=$prime equations=$(nrows(H)) unknowns=$(ncols(H)) coefficient_rank=$rh augmented_rank=$ra solvable=$(rh==ra)")
end
end
elapsed=@elapsed main()
println("CLASSIFICATION_SECONDS $elapsed")
