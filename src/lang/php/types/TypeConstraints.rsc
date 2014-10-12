module lang::php::types::TypeConstraints

import lang::php::ast::AbstractSyntax;
import lang::php::types::TypeSymbol;

data TypeOf
	= typeOf(loc ident)
	| typeSymbol(TypeSymbol ts)
	| function(loc ident)
	| var(loc decl)
	| arrayType(set[TypeOf] expressions)
	;

data Constraint 
	= eq(TypeOf a, TypeOf t)
	| eq(TypeOf a, TypeSymbol ts) // are rewritten to typeSymbol(ts)
	//| lub(TypeOf a, TypeOf t)
    | subtyp(TypeOf a, TypeOf t)
    | subtyp(TypeOf a, TypeSymbol ts)
    | supertyp(TypeOf a, TypeOf t)
    | supertyp(TypeOf a, TypeSymbol ts)
 
 	// kind of like 'typeEnvironment' 
  	//| varDecl(rel[loc declaration, loc location] decl)
  	
   	// query the m3 to solve these 
    | isAFunction(TypeOf a)
    | isAMethod(TypeOf a)
    | hasName(TypeOf a, str name)
    
    | isItemOfClass(TypeOf a, TypeOf t)
    | hasMethod(TypeOf a, str name)
    | hasMethod(TypeOf a, str name, set[ModifierConstraint] modifiers)
    //| parentHasMethod(TypeOf a, str name)
    //| parentHasMethod(TypeOf a, str name, set[ModifierConstraint] modifiers)
    
    | conditional(Constraint preCondition, Constraint result)
    | disjunction(set[Constraint] constraints)
    | exclusiveDisjunction(set[Constraint] constraints)
    | conjunction(set[Constraint] constraints) 
    | negation(Constraint constraint) 
    ;
    
data ModifierConstraint
	= required(set[Modifier] modifiers)
	| notAllowed(set[Modifier] modifiers)
	;

alias TypeEnv = map[TypeOf, TypeSet];
alias TypeHierarchy = rel[TypeSymbol, TypeSymbol];

data TypeSet
	= Universe()
	| EmptySet()
	| Root()
	| Single(TypeSymbol T)
	| Set(set[TypeSymbol] Ts)
	| Subtypes(TypeSet subs)
	| Supertypes(TypeSet supers)
	| Union(set[TypeSet] args)
	| Intersection(set[TypeSet] args)
	| LCA(set[TypeSet] args) // actually least common ancestor
	;
	
TypeSet Set({\any()})        = Root();
TypeSet Set({})              = EmptySet();
TypeSet Single(TypeSymbol T) = Set({T});

TypeSet Subtypes(Root())	          = Universe();
TypeSet Subtypes(EmptySet())          = EmptySet();
TypeSet Subtypes(Universe())          = Universe();
TypeSet Subtypes(Subtypes(TypeSet x)) = Subtypes(x);

TypeSet Supertypes(Root())	            = Single(\any());
TypeSet Supertypes(EmptySet())          = EmptySet();
TypeSet Supertypes(Universe())          = Universe();
TypeSet Supertypes(Supertypes(TypeSet x)) = Supertypes(x);
TypeSet Supertypes(TypeSet x) 			= Supertypes(x);

TypeSet Intersection({})               = EmptySet();
TypeSet Intersection({x})              = x;
TypeSet Intersection({Universe(), *x}) = Intersection(x);
TypeSet Intersection({EmptySet(), _*}) = EmptySet();
//TypeSet Intersection({(), _*}) = EmptySet();
TypeSet Intersection({Set(set[TypeSymbol] t1), Root()}) = Intersection({Set(t1 & { \any() } )});
TypeSet Intersection({Set(set[TypeSymbol] t1), Set(set[TypeSymbol] t2), rest*}) =
	Intersection({Set(t1 & t2), *rest});	

TypeSet Union({})                  = EmptySet();
TypeSet Union({x})                 = x;
TypeSet Union({Universe(), _*})    = Universe();
TypeSet Union({EmptySet(), *x})    = Union(x);
TypeSet Union({Set(set[TypeSymbol] t1), Root()}) = Union({Set(t1 + { \any() })});
TypeSet Union({Set(set[TypeSymbol] t1), Set(set[TypeSymbol] t2), rest*}) =
	Union({Set(t1 + t2), *rest});	

// LCA DOES NOT WORK PROPERLY YET!
TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, {})                  = EmptySet();
TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, {Universe(), *x})    = LCA(subtypes, x);
TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, {EmptySet(), *x})    = LCA(subtypes, x);
TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, {Set(set[TypeSymbol] t1), Root()}) = LCA(subtypes, {Set(t1 + { \any() })});
//TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, {Set(set[TypeSymbol] t1)}) = LCA(subtypes, {Set({shortestPathPair(subtypes, t1, \any())[0]})});	
//list[TypeSymbol] LCA({ rel[TypeSymbol, TypeSymbol] subtypes, TypeSet t1, *rest }) 
//{
//println("b");
//	type1 = [];
//	for (t <- t1) {
//		type1 += shortestPathPair(subtypes, t, \any());	
//	}
//	return type1;
//	//return LCA(subtypes, {Set({type1[0]})});	
//}
//list[TypeSymbol] LCA(rel[TypeSymbol, TypeSymbol] subtypes, Set(set[TypeSymbol] t1)) 
//{
//println("c");
//	type1 = [];
//	for (t <- t1) {
//		type1 += shortestPathPair(subtypes, t, \any());	
//	}
//	return type1;
//	//return LCA(subtypes, {Set({type1[0]})});	
//}
//TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, Set(set[TypeSymbol] t1), *rest) 
//{
//	type1 = [];
//	for (t <- t1) {
//		type1 += shortestPathPair(subtypes, t, \any());	
//	}
//	if (!isEmpty(rest)) 
//		return LCA(subtypes, {Set({( type1 & LCA(subtypes, rest))[0]})});	
//	else 
//		return LCA(subtypes, {Set({type1[0]})});	
//}
////TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, {Set(set[TypeSymbol] t1), rest*}) = LCA(subtypes, {Set({(shortestPathPair(subtypes, t1, \any()) & LCA(subtypes, rest))[0]})});	
//
//list[TypeSymbol] LCA(rel[TypeSymbol, TypeSymbol] subtypes, { TypeSymbol t1 }) = shortestPathPair(subtypes, t1, \any());
//list[TypeSymbol] LCA(rel[TypeSymbol, TypeSymbol] subtypes, { TypeSymbol t1, *rest }) = shortestPathPair(subtypes, t1, \any()) + LCA(subtypes, rest);	
////TypeSet LCA(rel[TypeSymbol, TypeSymbol] subtypes, TypeSet x)                 = x;

//TypeSet LCA({x}) = x;
//TypeSet LCA({Universe(), Set(x)}) = LCA({x});
//TypeSet LCA({EmptySet(), Set(x)}) = LCA({x});
//TypeSet LCA({Set(t1), Set(t2)})   = LCA({Set(t1 + t2)});	
//TypeSet LCA({t1, t2, rest})       = LCA({ LCA({t1,t2}), rest});	

//public TypeHierarchy subtypes = {};
//
//@memo
//public TypeHierarchy getSubTypes() {
//	if (isEmpty(subtypes)) throw "please initalize subtype relation first";
//
//	return subtypes;
//}