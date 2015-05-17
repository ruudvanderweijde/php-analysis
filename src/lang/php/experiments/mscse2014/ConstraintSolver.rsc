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

// for visualizing
import vis::Figure;
import vis::Render;

import lang::php::util::Utils;

import IO; // for debuggin
import String; // for toLowerCase
import Set; // for isEmpty
import Map; // for size
import Relation; // for domain
import ListRelation; // for domain

import analysis::graphs::Graph;

// start of solving constraints (move this stuff somewhere else)

public map[TypeOf var, TypeSet possibles] solveConstraints(set[Constraint] constraintSet, map[loc file, lrel[loc decl, loc location] vars] varMap, M3 m3, System system)
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
  	invertedSubtypes = invert(subtypes);
  	
  	// initialEstimates resolves everything to Universe, unless there is concrete information already
	estimates = initialEstimates(constraints, subtypes);

	
	// subtype relations 
	public TypeSet getSubTypes(TypeSet ts) = ts;
	
	// display some debug info
	debugPrintInitialResults(constraints, estimates);
		
// TODO: subtype is ignored, they are handled like 'normal' types
	solve (constraintSet, estimates) { // solve constraints and variable mapping
		constraintSet = constraintSet + deriveMore(constraintSet, estimates);
  		estimates = propagateEstimates(constraintSet, estimates);
  		constraintSet = propagateConstraints(constraintSet, estimates);
  	}
  	
  	return estimates;
}

public set[Constraint] deriveMore (set[Constraint] constraints, map[TypeOf, TypeSet] estimates)
{
	set[Constraint] derivedConstraints = {};
	
    for (v <- estimates) {
    	top-down-break visit (constraints) {
    		// todo: implement me
    		case isAFunction() :; 
    		case isAMethod(TypeOf a) :;
    		case hasName(TypeOf a, str name) :;
    		case isItemOfClass(TypeOf a, TypeOf t) :;
    		case hasMethod(TypeOf a, str name) :;
    		case hasMethod(TypeOf a, str name, set[ModifierConstraint] modifiers) :;
    		case conditional(Constraint preCondition, Constraint result) :;
    		
    		case disjunction({constraint}): derivedConstraints += constraint; // disjunction of 1 item
    		case disjunction(set[Constraint] constraints) :;
    		
    		case exclusiveDisjunction({constraint}): derivedConstraints += constraint; // excl disjunction of 1 item
    		case exclusiveDisjunction(set[Constraint] constraints) :;
    		
    		case conjunction(set[Constraint] constraints): derivedConstraints += constraint; // conjunction of 1 item
    		case conjunction(set[Constraint] constraints) :;
    		case negation(Constraint constraint) :;
    	}
    }
	
	logMessage("Derived <size(derivedConstraints)> Constraints", 2);
	return derivedConstraints;
} 

// for all resolved estimates, add new constraints
public set[Constraint] propagateConstraints (set[Constraint] constraints, map[TypeOf, TypeSet] estimates)
{
	set[Constraint] extraConstraints = {};
	
	for (identifier <- estimates) {
		typeSet = estimates[identifier];
		
		if (Universe() := typeSet) {
			continue; // skip universe, we only want to propagate 'solved' estimates
		}
	
		if (Set({TypeSymbol ts}) := typeSet) { // for now only single resolve types are supported
			
			resolvedType = typeSymbol(ts);
    		
    		// add constraints for resolved types
    		visit (constraints) {
       			case e:eq(l, identifier): extraConstraints += { eq(l, resolvedType) };
       			case e:eq(identifier, r): extraConstraints += { eq(resolvedType, r) };
       			case e:subtype(l, identifier): extraConstraints += { subtype(l, resolvedType) };
       			case e:subtype(identifier, r): extraConstraints += { subtype(resolvedType, r) };
    		} 
		}
	}
   	
	logMessage("Propagated <size(extraConstraints)> Constraints", 2);
	return extraConstraints + constraints;
}

public map[TypeOf, TypeSet] propagateEstimates (set[Constraint] constraints, map[TypeOf, TypeSet] estimates)
{
    for (v <- estimates) {
    	top-down-break visit (constraints) {
    		// do nothing, just stop visiting; should still be implemented
    		case isAFunction() :; 
    		case isAMethod(TypeOf a) :;
    		case hasName(TypeOf a, str name) :;
    		case isItemOfClass(TypeOf a, TypeOf t) :;
    		case hasMethod(TypeOf a, str name) :;
    		case hasMethod(TypeOf a, str name, set[ModifierConstraint] modifiers) :;
    		case conditional(Constraint preCondition, Constraint result) :;
    		case disjunction(set[Constraint] constraints) :;
    		case exclusiveDisjunction(set[Constraint] constraints) :;
    		case conjunction(set[Constraint] constraints) :;
    		case negation(Constraint constraint) :;
    		
			// solve subtyp(_,_)
    		case c:subtyp(v, r:typeOf(t)): {
		    	estimates[v] = getIntersectionResult(estimates[v], estimates[r]);
		    	
		    }
		   	case c:subtyp(l:typeOf(t), v):
    			estimates[v] = getIntersectionResult(estimates[v], estimates[l]);

		    // solve eq(_,_) 
    		case c:eq(l:typeOf(t), v):
    			estimates[v] = getIntersectionResult(estimates[v], estimates[l]);
    		case c:eq(v, r:typeOf(t)):
    			estimates[v] = getIntersectionResult(estimates[v], estimates[r]);
		}
    }
   
	return estimates;
}

@doc { do intersections, if no results, do Union (would be nice to have the LCA here) }
private TypeSet getIntersectionResult(TypeSet ts1, TypeSet ts2)
{
	println("getIntersectionResult - intersection( <ts1>, <ts2> )."); // debug
   	result = Intersection({ ts1, ts2 });
   	if (result == EmptySet()) {
		result = Universe();
   		//result = Union({ ts1, ts2 });
   	}
   	
	println("Results: <result>"); // debug
   	return result;
}

@doc { initial type estimates for all typeable objects; like (|php+foo:///bar|: integerType()) }
public map[TypeOf, TypeSet] initialEstimates (set[Constraint] constraints, rel[TypeSymbol, TypeSymbol] subtypes) 
{
 	map[TypeOf, TypeSet] result = ();
 	
 	visit (constraints) {
 		case        eq(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Single(ts)); 
 		case        eq(typeSymbol(TypeSymbol ts), TypeOf t): result = addToMap(result, t, Single(ts)); 
 		case   subtype(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Subtypes(Set({ts}))); 
 		case   subtype(typeSymbol(TypeSymbol ts), TypeOf t): result = addToMap(result, t, Subtypes(Set({ts}))); 
 		case supertype(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Supertypes(Set({ts}))); 
 		case supertype(typeSymbol(TypeSymbol ts), TypeOf t): result = addToMap(result, t, Supertypes(Set({ts}))); 
 		case                     TypeOf t:typeOf(loc ident): result = addToMap(result, t, Universe());
 		case                     TypeOf t:   var(loc  decl): result = addToMap(result, t, Universe());
 	};
 	
 	return result;
}

public set[TypeSymbol]   getSubTypes(rel[TypeSymbol, TypeSymbol] subtypes, set[TypeSymbol] ts) = domain(rangeR(subtypes*, ts));
public set[TypeSymbol] getSuperTypes(rel[TypeSymbol, TypeSymbol] subtypes, set[TypeSymbol] ts) = domain(rangeR(invert(subtypes*), ts));

// Stupid wrapper to add or take the intersection of values. Only used for initialEstimates
public map[TypeOf, TypeSet] addToMap(map[TypeOf, TypeSet] m, TypeOf k, TypeSet ts)
{
	if (m[k]?) {
		m[k] = Intersection({m[k], ts});	
	} else {
		m[k] = ts;	
	}
	
	return m;
}

// this sub type relation should match the sub type relation defined in the thesis
public rel[TypeSymbol, TypeSymbol] getSubTypes(M3 m3, System system) 
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
		
		// class(c) is a subtype of the extended class of c
		// we use the extends relation from M3
		+ { <     classType(c), classType(e)     > | <c,e> <- m3@extends, isClass(c) }
		+ { < interfaceType(i), interfaceType(e) > | <i,e> <- m3@extends, isInterface(i) }
		// add implements interfaces
		+ { < interfaceType(i), classType(c) > | <c,i> <- m3@implements }
		// class(c) without an extending class is a subtype of object()
		+ { < classType(c@decl), objectType() > | l <- system, /c:class(n,_,noName(),_,_) <- system[l] };
	
		// TODO, add subtypes for arrays
		// TODO, null is a subtype of all types	
	
	return subtypes;
}

// end of solving constraints (move this stuff somewhere else)

public void displaySubTypes(rel[TypeSymbol, TypeSymbol] s) {
	// init nodes and edges
	Figures nodes = [box(text("<b>"), id("<b>")) | b <- (domain(s)+range(s))];
	list[Edge] edges = [edge("<r>", "<l>") | <l,r> <- s];

	// display the subtype relations	
	render(graph(nodes, edges, hint("layered"), gap(50)));
}


//
// DEBUG STUFF
//
public void debugPrintInitialResults(set[Constraint] constraints, map[TypeOf, TypeSet] estimates)
{
	println("-----------------\nAll constraints!\n-----------------");
	iprintln(constraints);
	
	println("-----------------\nInitial estimates results!\n-----------------");
	for (to:typeOf(est) <- estimates) {
		println("<toStr(to)> :: <estimates[to]>");
	}
}