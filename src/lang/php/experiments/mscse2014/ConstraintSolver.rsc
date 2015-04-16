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
 	
 	// this line is not needed because we use varMap now
	//rel[loc decl, loc TypeOf] varUses = { <d,t> | <d,t> <- invert(m3@uses + invert(m3@declarations)), isVariable(d) };
  
  	subtypes = getSubTypes(m3, system);
  	//writeBinaryValueFile(|tmp:///subtypes.bin|, subtypes);
  	invertedSubtypes = invert(subtypes);
  	// initialEstimates resolves everything to Universe, unless there is concrete information already
	estimates = initialEstimates(constraints, subtypes);

	
	// subtype relations 
	public TypeSet getSubTypes(TypeSet ts) = ts;
	
	println("-----------------\nAll constraints!\n-----------------");
	iprintln(constraints);
	
	println("-----------------\nInitial estimates results!\n-----------------");
	for (to:typeOf(est) <- estimates) {
		println("<toStr(to)> :: <estimates[to]>");
	}
	
// TODO: subtype is ignored, they are handled like 'normal' types
	solve (constraintSet, estimates) { // solve constraints and variable mapping
		constraintSet = constraintSet + deriveMore(constraintSet, estimates);
  		constraintSet = propagateConstraints(constraintSet, estimates);
  		estimates = propagateEstimates(constraintSet, estimates);
  	}
  	
  	return estimates;
}

public set[Constraint] deriveMore (set[Constraint] constraints, map[TypeOf, TypeSet] estimates)
{
	set[Constraint] derivedConstraints = {};
	
	logMessage("Derived <size(derivedConstraints)> Constraints", 2);
	return derivedConstraints;
} 

public set[Constraint] propagateConstraints (set[Constraint] constraints, map[TypeOf, TypeSet] estimates)
{
//    		// Subtype relation
//    		for (v <- estimates, c:subtyp(v, r:typeOf(t)) <- constraints) {
//     			//estimates[v] = Intersection({ estimates[v], Subtypes(estimates[r]) });
//         		println("-----------------\nFIRST HIT!\n-----------------\n");
//         		println("constraint:\n<c>\n-----------------");
//         		println("<v>\n<r>\n-----------------");
//         		println("<estimates[v]>\n<estimates[r]>\n-----------------");
//     			estimates[v] = Intersection({ estimates[v], estimates[r] });
//	    		iprintln(estimates);
//     		}
//    	// handle disjunctions 
//    	// TODO handle them properly, they can be inside conjunctions, conditionals etc...
//    	top-down-break visit (constraints) { // top-down-break because we do not want to go into conditionals here
//    	    case conditional(_,_): ; // ignore these
//    	    case disjunction(set[Constraint] cs): {
//     			println("2 DISJUNCTION!!");
//     		    iprintln(cs);
//    	    	// all LHS:
//    	    	for (lhs <- { l | eq(l,_) <- cs } + { l | subtype(l,_) <- cs } + { l | supertyp(l,_) <- cs }) {
//	    	   		estimates[lhs] = 
//	    	   			Union( 
//	    	   				{ estimates[r]				|       eq(lhs,r) <- cs } +
//	    	   				{ Subtypes(estimates[r])	|   sybtyp(lhs,r) <- cs } +
//	    	   				{ Supertypes(estimates[r])	| sypertyp(lhs,r) <- cs }
//	    	   			);
//    	    	}
//    	    	// all RHS:
//    	    	for (rhs <- { r | eq(_,r) <- cs } + { r | subtype(_,r) <- cs } + { r | supertyp(_,r) <- cs }) {
//	    	   		estimates[rhs] = 
//	    	   			Union( 
//	    	   				{ estimates[l]				|       eq(l,rhs) <- cs } +
//	    	   				{ Subtypes(estimates[l])	|   sybtyp(l,lhs) <- cs } +
//	    	   				{ Supertypes(estimates[l])	| sypeltyp(l,lhs) <- cs }
//	    	   			);
//    	    	}
//    	    }
//    	}
	return constraints;
}

public map[TypeOf, TypeSet] propagateEstimates (set[Constraint] constraints, map[TypeOf, TypeSet] estimates)
{
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
		= { < subType, \any() > | subType <- { arrayType(), scalarType(), callableType() } }
	
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