using Oscar
println("Julia=",VERSION," Oscar=",pkgversion(Oscar)," GAP=",GAP.evalstr("GAPInfo.Version"))
println("Installed GAP package names=",GAP.evalstr("RecNames(GAPInfo.PackagesInfo)"))
for name in ["meataxe","meataxe64","cmeataxe","ctbllib","atlasrep","repsn","recog"]
    println("TestPackageAvailability($name)=",GAP.evalstr("TestPackageAvailability(\"$name\", \"\")"))
end
for name in ["MTX","GModuleByMats","BrauerCharacterValue","DecompositionMatrix"]
    println("IsBound($name)=",GAP.evalstr("IsBound($name)"))
end
println("MTX fields=",GAP.evalstr("RecNames(MTX)"))
println("F2 natural module composition factor dimensions=",GAP.evalstr("List(MTX.CompositionFactors(GModuleByMats([[[1,1],[0,1]],[[0,1],[1,0]]]*One(GF(2)),GF(2))),MTX.Dimension)"))
println("F2 order-three matrix Brauer value=",GAP.evalstr("BrauerCharacterValue([[0,1],[1,1]]*One(GF(2)))"))
println("S3 characteristic-2 decomposition matrix=",GAP.evalstr("DecompositionMatrix(CharacterTable(\"S3\") mod 2)"))
