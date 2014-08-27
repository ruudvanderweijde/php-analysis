module tests::lang::php::types::TypeConstraintsTests
extend lang::php::types::TypeConstraints;

import List;
import Set;

public void main()
{
	int iterationsPerTest = 250; 
	testRewriteRules(iterationsPerTest);
}

private void testRewriteRules(int n)
{
	assertUnionRules(n);
	assertIntersectionRules(n);
	assertLCARules(n);
	assertMixes(n);
}

private set[TypeSymbol] types = {
	arrayType(),
	booleanType(),
	classType(|file:///x|),
	classType(|file:///y|),
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

private set[TypeSet] getMixed() 
	= { getOneFrom(singles) | x <- [getOneFrom([0..2])..getOneFrom([1..5])] }
	+ { Universe() | x <- [1..getOneFrom([0..2])] }
	+ { EmptySet() | x <- [1..getOneFrom([0..2])] }
	;

private TypeSet getUnion()  = Union(getMixed());
private TypeSet getUnions() = Union({ Union({getUnion()}), Union({getUnion()}) });
private TypeSet getIntersection()  = Intersection(getMixed());
private TypeSet getIntersections() = Intersection({ Intersection({getIntersection()}), Intersection({getIntersection()}) });
private TypeSet getMix1() = Union({ getIntersection(), getIntersections(), getUnion(), getUnions() });
private TypeSet getMix2() = Intersection({ Union({ getIntersection() }), getUnion(), getUnions() });
	
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
		elseif ({Set(_) ,_*} := input) assert Set(({*s | Set(s) <- input} | it & s | Set(s) <- input)) == res : "<input> :: <res>";
		elseif ({Universe()} := input) assert Universe() == res : "<input> :: <res>";
		else 						   assert Set({}) == res : "<input> :: <res>";
	}
}

private void assertLCARules(int n)
{
	// include subtypes
}

private void assertMixes(int n)
{
	bool testM(TypeSet m) = 
		EmptySet() := m ||	
		Universe() := m || 
		Set(set[TypeSymbol] _) := m;
		
	// use the methods getMix1 and getMix2, 
	// The result should always EmptySet, Universe, or Set(literaltyps)
	for (x <- [0..n]) {
		TypeSet m1 = getMix1();
		assert testM(m1): "testM failed for: <m1>";
		TypeSet m2 = getMix2();
		assert testM(m2);
	}
}