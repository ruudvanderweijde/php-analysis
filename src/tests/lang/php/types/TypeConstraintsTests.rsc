module tests::lang::php::types::TypeConstraintsTests
extend lang::php::types::TypeConstraints;

import IO;
import List;
import Set;
import Relation;
import analysis::graphs::Graph;

public void main()
{
	// fill the subtype relation
	setSubTypeRelation(getSubtypesMock());
	
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
	assertIntersectionBug();
}

private set[TypeSymbol] types = {
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
	// single values
	for (t <- types) {
		TypeSet expected = Set(reach(invert(getSubtypesMock()), {t}));
		TypeSet result   = solveSubtypes(Subtypes(Single(t)));
		//iprintln("");
		//iprintln("----------");
		//iprintln("Type: <t>");
		//iprintln("Expected : <expected>");
		//iprintln("Actual: <result>");
		assert expected == result : "assertSubtypesRules failed for Subtypes(Set({<t>}); Expected: <expected>; Actual: <result>";
	}
	
	// multiple values	
	assert Set({integerType(), stringType()}) == Subtypes(Set({integerType(), stringType()})) 
		: "<Set({integerType(), stringType()})> == <Subtypes(Set({integerType(), stringType()}))>";
		
	assert Set({integerType(), floatType(), numberType(), stringType()}) == Subtypes(Set({numberType(), stringType()}))
		: "<Set({integerType(), floatType(), numberType(), stringType()}) == Subtypes(Set({numberType(), stringType()}))>";
	
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
	assert EmptySet() == LCA(getSubtypesMock(), {});
	
	for (s <- singles) 
		assert s == LCA(getSubtypesMock(), { Universe(), s });
		
	assert callableType() == LCA(getSubtypesMock(), { Single(objectType()), Single(stringType()) });
	assert callableType() == LCA(getSubtypesMock(), { Single(stringType()), Single(objectType()) });
	assert callableType() == LCA(getSubtypesMock(), { Single(stringType()), Single(class(|php:class:///childless|)) });
	assert numberType()   == LCA(getSubtypesMock(), { Single(floatType()),  Single(integerType()) });
	assert scalarType()   == LCA(getSubtypesMock(), { Single(floatType()),  Single(booleanType()) });
	assert scalarType()   == LCA(getSubtypesMock(), { Single(stringType()), Single(booleanType()) });
	assert scalarType()   == LCA(getSubtypesMock(), { Single(stringType()), Single(integerType()), Single(booleanType()) });
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
public rel[TypeSymbol, TypeSymbol] getSubtypesMock() 
{
	rel[TypeSymbol, TypeSymbol] subtypes
		// subtypes of any() are array(), scalar() and object()
		= { < subType, \any() > | subType <- { arrayType(\any()), scalarType(), callableType() } }
	
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
		// TODO, add null subtype of all types?

	return subtypes;
}
private rel[TypeSymbol, TypeSymbol] invertedSubtypes = invert(getSubtypesMock());

// duplicate code (because it the implementation is tightly coupled with the context)
TypeSet solveSubtypes(TypeSet ts) {
		return innermost visit(ts) {
			case Subtypes(Set({TypeSymbol s, *rest })) => Union({Single(s), Set(reach(invertedSubtypes, {s})), Subtypes(Set(rest))}) 
		}
}

// recursive loop bug. this test should prevent this from happening
private void assertIntersectionBug()
{
	//iprintln(Subtypes(Set({objectType()})));
	assert Subtypes(Set({objectType()})) == Set({
		objectType(),
		classType(|php+class:///parent|),
		classType(|php+class:///childless|),
		classType(|php+class:///child1|),
		classType(|php+class:///child2|),
		classType(|php+class:///grandchild|)
	}) : "<Subtypes(Set({objectType()}))> == <Set({objectType(),classType(|php+class:///parent|),classType(|php+class:///childless|),classType(|php+class:///child1|),classType(|php+class:///child2|),classType(|php+class:///grandchild|)})>";
	
	assert Intersection({Set({classType(|php+class:///childless|)}),Subtypes(Set({objectType()}))}) == Set({classType(|php+class:///childless|)})
		: "<Intersection({Set({classType(|php+class:///childless|)}),Subtypes(Set({objectType()}))})> == <Set({classType(|php+class:///childless|)})>";
}