module tests::lang::php::types::TypeConstraintsTests
extend lang::php::types::TypeConstraints;

import IO;
import List;
import Set;
import Relation;
import analysis::graphs::Graph;

public void main()
{
	int iterationsPerTest = 500; 
	println("Running tests with <iterationsPerTest> iterations per test for the generated input tests");
	testRewriteRules(iterationsPerTest);
	println("All tests ended succesfully.");
}

private void testRewriteRules(int n)
{
	assertUnionRules(n);
	assertIntersectionRules(n);
	//assertLCARules(n); // these do not work properly yet.
	assertSubtypesRules(n);
	assertMixes(n);
	assertMixesWithSubtypes(n);
}

private set[TypeSymbol] types = {
	arrayType(),
	arrayType(\any()),
	booleanType(),
	classType(|php+class:///parent|),
	classType(|php+class:///childless|),
	classType(|php+class:///child1|),
	classType(|php+class:///child2|),
	classType(|php+class:///grandchild|),
	interfaceType(|php+interface:///barable|),
	floatType(),
	integerType(),
	numberType(),
	nullType(),
	objectType(),
	resourceType(),
	scalarType(),
	stringType(),
	callableType() };
	
private set[TypeSet] u = { Universe() };
private set[TypeSet] e = { EmptySet() };
	
private set[TypeSet] singles = { Single(s) | s <- types};
private set[TypeSet] subtypes = { Subtypes(s) | s <- singles};

private set[TypeSet] getMixed() 
	= { getOneFrom(singles) | x <- [getOneFrom([0..2])..getOneFrom([1..5])] }
	+ { Universe() | x <- [1..getOneFrom([0..2])] }
	+ { Root() | x <- [1..getOneFrom([0..2])] }
	+ { EmptySet() | x <- [1..getOneFrom([0..2])] }
	;

private set[TypeSet] getMixedWS()  // with subtypes
	= getMixed()
	+ { getOneFrom(subtypes) | x <- [getOneFrom([0..2])..getOneFrom([1..5])] }
	;
	
private TypeSet getUnion()  = Union(getMixed());
private TypeSet getUnions() = Union({ Union({getUnion()}), Union({getUnion()}) });
private TypeSet getIntersection()  = Intersection(getMixed());
private TypeSet getIntersections() = Intersection({ Intersection({getIntersection()}), Intersection({getIntersection()}) });
private TypeSet getMix1() = Union({ getIntersection(), getIntersections(), getUnion(), getUnions() });
private TypeSet getMix2() = Intersection({ Union({ getIntersection() }), getUnion(), getUnions() });

private TypeSet getUnionWS()  = Union(getMixedWS());
private TypeSet getUnionsWS() = Union({ Union({getUnionWS()}), Union({getUnionWS()}) });
private TypeSet getIntersectionWS()  = Intersection(getMixedWS());
private TypeSet getIntersectionsWS() = Intersection({ Intersection({getIntersectionWS()}), Intersection({getIntersectionWS()}) });
private TypeSet getMix1WS() = Union({ getIntersection(), getIntersections(), getUnion(), getUnions() });
private TypeSet getMix2WS() = Intersection({ Union({ getIntersectionWS() }), getUnionWS(), getUnionsWS() });

private void assertSubtypesRules(int n) {
	for (t <- types) {
		TypeSet expected = Set(reach(invert(getSubTypesMock()), {t}));
		TypeSet result   = solveSubtypes(Subtypes(Single(t)));
		assert expected == result : "<expected> :: <result>";
	}
}	

private void assertUnionRules(int n)
{
	for (s <- singles) 
		assert Universe() == Union({ Universe(), s });
	
	for (s1 <- singles, s2 <- singles) 
		assert 
			Universe() == Union({ s1, s2, Universe() }) &&
			Universe() == Union({ s1, s2, Universe(), EmptySet() });
	
	for (x <- [0..n]) 
	{
		input = getMixed();
		res = Union(input);
		
		if ({Universe() ,_*} := input) assert Universe() == res : "<input> :: <res>";
		elseif ({Subtypes(_) ,_*} := input) println("Skipped subtype test, please fix!! <input>");
		elseif ({Root() ,_*} := input) assert Set(({\any()} | it + s | Set(s) <- input)) == res : "<input> :: <res>";
		elseif ({Set(_) ,_*} := input) assert Set(({} | it + s | Set(s) <- input)) == res : "<input> :: <res>";
		elseif ({EmptySet()} := input) assert EmptySet() == res : "<input> :: <res>";
		else 					       assert Set({}) == res : "<input> :: <res>";
	}
}

private void assertIntersectionRules(int n)
{
	for (s <- singles) 
		assert s == Intersection({ Universe(), s });
	
	for (s1 <- singles, s2 <- singles) 
		assert 
			EmptySet() == Intersection({ s1, s2, EmptySet() }) &&
			EmptySet() == Intersection({ s1, s2, EmptySet(), Universe() });
	
	for (x <- [0..n]) 
	{
		input = getMixed();
		res = Intersection(input);
		
		if ({EmptySet() ,_*} := input) assert EmptySet() == res : "<input> :: <res>";
		elseif ({Root()}     := input) assert Root() == res : "<input> :: <res>";
		elseif ({Root(),Universe()} := input) assert Root() == res : "<input> :: <res>";
		elseif ({Root() ,_*} := input) assert Set(({\any()} & {*s | Set(s) <- input} | it & s | Set(s) <- input)) == res : "<input> :: <res>";
		elseif ({Set(_) ,_*} := input) assert Set(({*s | Set(s) <- input} | it & s | Set(s) <- input)) == res : "<input> :: <res>";
		elseif ({Universe()} := input) assert Universe() == res : "<input> :: <res>";
		else 						   assert Set({}) == res : "<input> :: <res>";
	}
}

private void assertLCARules(int n)
{
	for (s <- singles) 
		assert s == LCA(getSubTypesMock(), { Universe(), s });
		
	assert callableType() == LCA(getSubTypesMock(), { Single(objectType()), Single(stringType()) });
	assert callableType() == LCA(getSubTypesMock(), { Single(stringType()), Single(objectType()) });
	assert callableType() == LCA(getSubTypesMock(), { Single(stringType()), Single(class(|php:class:///childless|)) });
	assert numberType()   == LCA(getSubTypesMock(), { Single(floatType()),  Single(integerType()) });
	assert scalarType()   == LCA(getSubTypesMock(), { Single(floatType()),  Single(booleanType()) });
	assert scalarType()   == LCA(getSubTypesMock(), { Single(stringType()), Single(booleanType()) });
}

private void assertMixes(int n)
{
	bool testM(TypeSet m) = 
		EmptySet() := m ||	
		Universe() := m || 
		Root() := m || 
		Set(set[TypeSymbol] _) := m;
		
	// use the methods getMix1 and getMix2, 
	// The result should always EmptySet, Universe, or Set(literaltyps)
	for (x <- [0..n]) {
		TypeSet m1 = getMix1();
		assert testM(m1): "Failed to reduce: <m1>";
		TypeSet m2 = getMix2();
		assert testM(m2) : "Failed to reduce: <m2>";
	}
}

private void assertMixesWithSubtypes(int n)
{
	bool testM(TypeSet m) = 
		EmptySet() := m ||	
		Universe() := m || 
		Root() := m || 
		Set(set[TypeSymbol] _) := m;
		
	// use the methods getMix1 and getMix2, 
	// The result should always EmptySet, Universe, or Set(literaltyps)
	for (x <- [0..n]) {
		TypeSet m1 = getMix1WS();
		assert testM(solveSubtypes(m1)): "Failed to reduce: <m1>";
		TypeSet m2 = getMix2WS();
		assert testM(solveSubtypes(m2)) : "Failed to reduce: <m2>";
	}
}

// duplicate code (because it the implementation is tightly coupled with the context)
@memo
public rel[TypeSymbol, TypeSymbol] getSubTypesMock() 
{
	rel[TypeSymbol, TypeSymbol] subtypes
		// subtypes of any() are array(), scalar() and object()
		= { < subType, \any() > | subType <- { arrayType(), scalarType(), callableType() } }
	
		// subtypes of callable() are object() and string()
		+ { < subType, callableType() > | subType <- { objectType(), stringType() } }
		
		// subtypes of scalar() are resource(), boolean(), number() and string()
		+ { < subType, scalarType() > | subType <- { resourceType(), booleanType(), numberType(), stringType() } }
		// subtypes of number() are integer() and float()
		+ { < subType, numberType() > | subType <- { integerType(), floatType() } }
		
		+ { < classType(|php+class:///<l>|), classType(|php+class:///<r>|) > 
			| <l,r> <- { <"child1","parent">, <"child2","parent">, <"grandchild","child2"> } }
		+ { < classType(|php+class:///<c>|), objectType() > | c <- { "childless", "parent" } };
		
		// TODO, add subtypes for arrays

	return subtypes;
}
private rel[TypeSymbol, TypeSymbol] invertedSubtypes = invert(getSubTypesMock());

// duplicate code (because it the implementation is tightly coupled with the context)
TypeSet solveSubtypes(TypeSet ts) {
		return innermost visit(ts) {
			case Subtypes(Set({TypeSymbol s, *rest })) => Union({Single(s), Set(reach(invertedSubtypes, {s})), Subtypes(Set(rest))}) 
		}
}