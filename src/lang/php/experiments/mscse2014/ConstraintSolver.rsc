module lang::php::experiments::mscse2014::ConstraintSolver


import lang::php::ast::AbstractSyntax;

import lang::php::m3::Core;
import lang::php::m3::Containment;
import lang::php::ast::System;
//import lang::php::ast::Scopes;

import lang::php::types::TypeSymbol;
import lang::php::types::TypeConstraints;
import lang::php::types::core::Constants;
import lang::php::types::core::Variables;


import lang::php::util::Utils;

import IO; // for debuggin
import String; // for toLowerCase
import Set; // for isEmpty
import Map; // for size
import Relation; // for domain
import ListRelation; // for domain

// start of solving constraints (move this stuff somewhere else)

public map[TypeOf var, TypeSet possibles] solveConstraints(set[Constraint] constraints, map[loc file, lrel[loc decl, loc location] vars] varMap, M3 m3, System system)
{
	// change (eq|subtyp) TypeOf, TypeSymbol 
	//     to (eq|subtyp) TypeOf, typeOf(TypeSymbol)
	// this is easier than rewiting all code
	constraints = visit(constraints) {
		case       eq(TypeOf a, TypeSymbol ts) =>       eq(a, typeSymbol(ts))
		case   subtyp(TypeOf a, TypeSymbol ts) =>   subtyp(a, typeSymbol(ts))
		case supertyp(TypeOf a, TypeSymbol ts) => supertyp(a, typeSymbol(ts))
 	};
  
  	subtypes = getSubTypes(m3, system);
	estimates = initialEstimates(constraints, subtypes);

	// subtypes methods
	//public TypeSet getSubTypes(TypeSet ts) = ts;
	
	iprintln("Initial results:");	
	for (to:typeOf(est) <- estimates) {
		println("<toStr(to)> :: <estimates[to]>");
	}
	
	rel[loc decl, loc TypeOf] varUses = { <d,t> | <d,t> <- invert(m3@uses + invert(m3@declarations)), isVariable(d) };

	solve (estimates) {
		solve (estimates) {
    		for (l:typeOf(v) <- estimates, eq(typeOf(v), r:typeOf(t)) <- constraints) {
    			println("\>\>\>\> Start");
    			//println("Merge 1: <readFile(v.ident)> && <readFile(t.ident)>");
    			println("Merge 1: <toStr(l)> && <toStr(r)>");
    			//println(estimates[v]);
    			//println(estimates[t]);
    			//println(estimates[v]);
    			iprintln("<estimates[l]> && <estimates[r]>");
     			estimates[l] = Intersection({estimates[l], estimates[r]});
    			iprintln("<toStr(l)> == <estimates[l]>");
    			println("\<\<\<\< End");
     		}
    		for (typeOf(v) <- estimates, subtyp(t, v) <- constraints) {
    			println("\>\>\>\> Start");
    			println("Merge 1: <readFile(v.ident)> && <readFile(t.ident)>");
    			println("Merge 1: <toStr(v)> && <toStr(t)>");
    			//println(estimates[v]);
    			//println(estimates[t]);
    			//println(estimates[v]);
    			iprintln("<estimates[v]> && <estimates[t]>");
     			estimates[v] = Intersection({estimates[v], estimates[t]});
    			iprintln("<toStr(v)> == <estimates[v]>");
    			println("\<\<\<\< End");
     		}
    		for (typeOf(v) <- estimates, s:subtyp(tov:typeOf(v), tot:typeOf(t)) <- constraints) {
    			println("\>\>\>\> Start");
    			println("Merge 2: <readFile(v)> && <readFile(t)>");
    			println("Merge 2: <toStr(tov)> && <toStr(tot)>");
    			//println("Merge 2: <readFile(v.ident)> && <readFile(t.ident)>");
    			//println(estimates[v]);
    			//println(estimates[t]);
    			println(toStr(s));
    			iprintln("<Subtypes(estimates[tov])> && <estimates[tot]>");
     			estimates[tov] = Intersection({Subtypes(estimates[tov]), estimates[tot]});
    			iprintln("<toStr(tov)> == <estimates[tov]>");
    			println("\<\<\<\< End");
     		}
     		// handle disjunctions:
     		
    		//for (v <- estimates, eq(v, typeOf(TypeSymbol t)) <- constraints) {
     		//	estimates[v] = estimates[v] & {t};
    		//}
    	}
    	
    	// handle disjunctions
    	visit (constraints) {
    	    case disjunction(set[Constraint] cs): {
    	    	// all LHS:
    	    	for (lhs <- { l | eq(l,_) <- cs } + { l | subtype(l,_) <- cs } + { l | supertyp(l,_) <- cs }) {
	    	   		estimates[lhs] = 
	    	   			Union( 
	    	   				{ estimates[r]				|       eq(lhs,r) <- cs } +
	    	   				{ Subtypes(estimates[r])	|   sybtyp(lhs,r) <- cs } +
	    	   				{ Supertypes(estimates[r])	| sypertyp(lhs,r) <- cs }
	    	   			);
    	    	}
    	    }
    	}
    
    	// try to determine the types of the variables:
    	
    	for (mapId <- varMap) {
    		m = varMap[mapId];
    		for (varDecl <- toSet(domain(m))) {
    			set[TypeSet] ts = { estimates[typeOf(id)] | id <- m[varDecl] };
    			//println({ typeOf(id) | id <- m[varDecl]});
    			//println({ id | id <- m[varDecl]});
    			varLCA = LCA(ts);
    			println(varLCA);
    			exit();
    			//varType = LCA(ts);
    			//varType = LUB({ estimates[typeOf(id)] | id <- m[varDecl]});
    			for (id <- m[varDecl])
    			{
    				estimates[typeOf(id)] = varLCA;
    			}
    		}
    	}
    	
    	// LEAST UPPER BOUND CHECK (least common ancestor) 
    	//// for each variable decl, check the types
    	//for (decl <- varUses.decl) { // for all declarations
    	//	// try to resolve variable types...
    	//	possibleTypes = {};
    	//	for (t <- varUses[decl]) {
   		//	    // check if it is not universe
    	//		if (estimates[typeOf(t)] != Universe()) {
    	//			possibleTypes = estimates[typeOf(t)];
    	//		}
    	//	}
    	//	
    	//	if (possibleTypes != {}) {
	    //		for (t <- varUses[decl]) {
	    //			estimates[typeOf(t)] = possibleTypes;
    	//		}
    	//	} else {
    	//		println("types, could not be resolved for <decl>");	
    	//	}
    	//}
 	}

	iprintln("After solve:");	
	for (to:typeOf(est) <- estimates) {
		println("<toStr(to)> :: <estimates[to]>");
	}

		// replace all resolved TypeSymbol.	
		//println(estimates); 
 		//estimates = innermost visit(estimates) {
 		//	case Subtypes(Set({s , set[Type] rest })) => Union({Single(s ), Set ( subtypes [s ]), Subtypes(Set({ rest }))}) 
 		//};
 	
 		
 	return estimates;
}

public map[TypeOf, TypeSet] initialEstimates (set[Constraint] constraints, rel[TypeSymbol, TypeSymbol] subtypes) 
{
 	map[TypeOf, TypeSet] result = ();
 	
 	visit (constraints) {
 		case        eq(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Single(ts)); 
 		case   subtype(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Subtypes(Set({ts}))); 
 		case supertype(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Supertypes(Set({ts}))); 
 		case                     TypeOf t:typeOf(loc ident): result = addToMap(result, t, Universe());
 		case                     TypeOf t:   var(loc  decl): result = addToMap(result, t, Universe());
 	};
 	
 	return result;
}

public set[TypeSymbol]   getSubTypes(rel[TypeSymbol, TypeSymbol] subtypes, set[TypeSymbol] ts) = domain(rangeR(subtypes*, ts));
public set[TypeSymbol] getSuperTypes(rel[TypeSymbol, TypeSymbol] subtypes, set[TypeSymbol] ts) = domain(rangeR(invert(subtypes*), ts));

// Stupid wrapper to add or take the intersection of values
public map[TypeOf, TypeSet] addToMap(map[TypeOf, TypeSet] m, TypeOf k, TypeSet ts)
{
	if (m[k]?) {
		m[k] = Intersection({m[k], ts});	
	} else {
		m[k] = ts;	
	}
	
	return m;
}

public rel[TypeSymbol, TypeSymbol] getSubTypes(M3 m3, System system) 
{
	rel[TypeSymbol, TypeSymbol] subtypes
		// subtypes of any() are array(), scalar() and object()
		= { < subType, \any() > | subType <- { arrayType(), scalarType(), objectType() } }
		
		// subtypes of scalar() are resource, string() and null()
		+ { < subType, scalarType() > | subType <- { resourceType(), stringType(), nullType() } }
		// subtypes of string() are boolean() and number()
		+ { < subType, scalarType() > | subType <- { booleanType(), numberType() } }
		// subtypes of number() are integer() and float()
		+ { < subType, numberType() > | subType <- { integerType(), floatType() } }
		
		// class(c) is a subtype of the extended class of c
		// we use the extends relation from M3
		+ { < classType(c), classType(e) > | <c,e> <- m3@extends }
		// class(c) without an extending class is a subtype of object()
		+ { < classType(c@decl), objectType() > | l <- system, /c:class(n,_,noName(),_,_) <- system[l] };
		
		// TODO, add subtypes for arrays
		
	// compute reflexive transitive closure and return the result 
	// do not do this, or else we cannot find the Lowest_common_ancestor
	//subtypes = subtypes*;

	return subtypes;
}

// end of solving constraints (move this stuff somewhere else)