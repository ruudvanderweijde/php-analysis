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
 	
 	// this line is not needed
	//rel[loc decl, loc TypeOf] varUses = { <d,t> | <d,t> <- invert(m3@uses + invert(m3@declarations)), isVariable(d) };
	// replace all var use location
	for (fileLocation <- varMap, <decl,location> <- varMap[fileLocation]) {
		constraints = visit(constraints) {
			case typeOf(location) => var(decl)
		}
	}
  
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
  	
  	solve (estimates) {
    	
    	//// propagate the constraints
    	//Constraint propagate(Constraint constraint) { 
    	//	println("-------------- CONSTRAINT");
    	//	iprintln(constraint);
    	//	println("-------------- ESTIMATES");
    	//	iprintln(estimates);
    	//	println("--------------");
    	//	for(estimate <- estimates) {
    	//	println(estimate);
    	//	println(estimates[estimate]);
    	//	println("--------------");
	    //	return subtype(estimates[estimate], constraint);
	    //		switch(constraint) {
	    //			case subtype(estimate, x): return subtype(estimates[estimate], constraint);
	    //		}
    	//	}
    	//}
    	//constraints = mapper(constraints, propagate);
    	
		solve (estimates) {	// solve constraints
    		println("-----------------\nNEW ROUND!\n-----------------");
    		iprintln(estimates);
   
    		// Subtype relation
    		for (v <- estimates, c:subtyp(v, r:typeOf(t)) <- constraints) {
     			//estimates[v] = Intersection({ estimates[v], Subtypes(estimates[r]) });
         		println("-----------------\nFIRST HIT!\n-----------------\n");
         		println("constraint:\n<c>\n-----------------");
         		println("<v>\n<r>\n-----------------");
         		println("<estimates[v]>\n<estimates[r]>\n-----------------");
     			estimates[v] = Intersection({ estimates[v], estimates[r] });
	    		iprintln(estimates);
     		}
     		
    		for (v <- estimates, c:subtyp(l:typeOf(t), v) <- constraints) {;
         		println("-----------------\nSECOND HIT!\n-----------------\n");
         		println("constraint:\n<c>\n-----------------");
         		println("<v>\n<l>\n-----------------");
         		println("<estimates[v]>\n<estimates[l]>\n-----------------");
     			estimates[v] = Intersection({ estimates[v], estimates[l] });
	    		iprintln(estimates);
     			//estimates[v] = Intersection({ estimates[v], Supertypes(estimates[l]) });
     			//estimates[v] = Intersection({ estimates[v], Set(reach(subtypes, estimates[l])) });
     		}
     		
    		for (v <- estimates, c:eq(v, r:typeOf(t)) <- constraints) {;
         		println("-----------------\nTHIRD HIT!\n-----------------\n");
         		println("constraint:\n<c>\n-----------------");
         		println("<v>\n<r>\n-----------------");
         		println("<estimates[v]>\n<estimates[r]>\n-----------------");
     			estimates[v] = Intersection({ estimates[v], estimates[r] });
	    		iprintln(estimates);
     			//estimates[v] = Intersection({ estimates[v], Supertypes(estimates[l]) });
     			//estimates[v] = Intersection({ estimates[v], Set(reach(subtypes, estimates[l])) });
     		}
     		
    		for (v <- estimates, c:eq(l:typeOf(t), v) <- constraints) {;
         		println("-----------------\nFOURTH HIT!\n-----------------\n");
         		println("constraint:\n<c>\n-----------------");
         		println("<v>\n<l>\n-----------------");
         		println("<estimates[v]>\n<estimates[l]>\n-----------------");
     			estimates[v] = Intersection({ estimates[v], estimates[l] });
	    		iprintln(estimates);
     			//estimates[v] = Intersection({ estimates[v], Supertypes(estimates[l]) });
     			//estimates[v] = Intersection({ estimates[v], Set(reach(subtypes, estimates[l])) });
     		}
     		
    		//for (v <- estimates, subtyp(l:typeOf(t), v) <- constraints) {
    			// l is a subtypes of 
    			//println("#1: <toStr(v)> = <estimates[v]>");
    			//println("#1: <toStr(l)> = <estimates[l]>");
     		//	println("Intersection({ <estimates[v]>, Supertypes(<estimates[l]>)) })");
     		//	println(v);
     		//	iprintln(estimates);
     			//TypeSet intersection = Intersection({ estimates[v], Supertypes(estimates[l]) });
     			//println(intersection);
     			//if (TypeOf !:= estimates) { 
     			//	println("estimates");
     			//}
     			//if (TypeSet !:= intersection) { 
     			//	println("intersection");
     			//}
     			//estimates[v] = Intersection({ estimates[v], Supertypes(estimates[l]) });
    		//	//println("#2: <toStr(v)> = <estimates[v]>");
    		//	//println("#2: <toStr(l)> = <estimates[l]>");
    		//}
    		
    		//for (v <- estimates, supertyp(v, r:typeOf(t)) <- constraints) {
    		//	println("#3: <toStr(v)> = <estimates[v]>");
    		//	println("#3: <toStr(r)> = <estimates[r]>");
     	//		println("Intersection({ <estimates[v]>, Supertypes(<estimates[r]>) })");
     	//		estimates[v] = Intersection({ estimates[v], Supertypes(estimates[r]) });
    		//	println("#4: <toStr(v)> = <estimates[v]>");
    		//	println("#4: <toStr(r)> = <estimates[r]>");
    		//}
    		//for (v <- estimates, supertyp(r:typeSymbol(t), v) <- constraints) {
    		//	println("MATCH 2 :: <v> :: <r>");	
    		//}
    		//for (v <- estimates, subtyp(r:typeSymbol(t), v) <- constraints) {
    		//	println("MATCH 2 :: <v> :: <r>");	
    		//}
    		//for (typeOf(v) <- estimates, s:subtyp(tov:typeOf(v), tot:typeOf(t)) <- constraints) {
    		//	println("MATCH 3 :: <s>");	
    		//
    		//}
    		//for (v <- estimates, eq(v, r:typeOf(t)) <- constraints) {
    		//	;
    		//}
    		//for (v <- estimates, subtyp(v, r:typeSymbol(t)) <- constraints) {
    		//	println("\>\>\>\> Start");
    		//	println(v);
    		//	//println(v);
     	//		println(estimates[v]);
     	//		println(t);
     	//		println(Subtypes(Single(t)));
     	//		println("Intersection(<estimates[v]>, Subtypes(Single(<t>)));");
     	//		estimates[v] = Intersection({ estimates[v], Subtypes(Single(t)) });
     	//		println(estimates[v]);
    		//	println("\<\<\<\< End");
    		//;
    		//}
    		//for (v <- estimates, subtyp(l:v, r:typeOf(t)) <- constraints) {
    		//	//println("\>\>\>\> Start");
    		//	//println("Merge 1: <readFile(v.ident)> && <readFile(t.ident)>");
    		//	//println("Merge 1: <toStr(v)> && <toStr(t)>");
    		//	//println(estimates[v]);
    		//	//println(estimates[t]);
    		//	//println(estimates[v]);
    		//	iprintln("<estimates[l]> && <estimates[r]>");
     	//		estimates[l] = Intersection({estimates[l], Subtypes(estimates[r])});
    		//	
    		//	iprintln("<toStr(v)> == <estimates[v]>");
    		//	//println("\<\<\<\< End");
     	//	}
    		//for (typeOf(v) <- estimates, s:subtyp(tov:typeOf(v), tot:typeOf(t)) <- constraints) {
    		//	//println("\>\>\>\> Start");
    		//	//println("Merge 2: <readFile(v)> && <readFile(t)>");
    		//	//println("Merge 2: <toStr(tov)> && <toStr(tot)>");
    		//	//println("Merge 2: <readFile(v.ident)> && <readFile(t.ident)>");
    		//	//println(estimates[v]);
    		//	//println(estimates[t]);
    		//	//println(toStr(s));
    		//	//iprintln("<Subtypes(estimates[tov])> && <estimates[tot]>");
     	//		estimates[tov] = Intersection({Subtypes(estimates[tov]), estimates[tot]});
    		//	//iprintln("<toStr(tov)> == <estimates[tov]>");
    		//	//println("\<\<\<\< End");
     	//	}
    	}
    	
    	// handle disjunctions 
    	// TODO handle them properly, they can be inside conjunctions, conditionals etc...
    	top-down-break visit (constraints) { // top-down-break because we do not want to go into conditionals here
    	    case conditional(_,_): ; // ignore these
    	    case disjunction(set[Constraint] cs): {
     			println("2 DISJUNCTION!!");
     		    iprintln(cs);
    	    	// all LHS:
    	    	for (lhs <- { l | eq(l,_) <- cs } + { l | subtype(l,_) <- cs } + { l | supertyp(l,_) <- cs }) {
	    	   		estimates[lhs] = 
	    	   			Union( 
	    	   				{ estimates[r]				|       eq(lhs,r) <- cs } +
	    	   				{ Subtypes(estimates[r])	|   sybtyp(lhs,r) <- cs } +
	    	   				{ Supertypes(estimates[r])	| sypertyp(lhs,r) <- cs }
	    	   			);
    	    	}
    	    	// all RHS:
    	    	for (rhs <- { r | eq(_,r) <- cs } + { r | subtype(_,r) <- cs } + { r | supertyp(_,r) <- cs }) {
	    	   		estimates[rhs] = 
	    	   			Union( 
	    	   				{ estimates[l]				|       eq(l,rhs) <- cs } +
	    	   				{ Subtypes(estimates[l])	|   sybtyp(l,lhs) <- cs } +
	    	   				{ Supertypes(estimates[l])	| sypeltyp(l,lhs) <- cs }
	    	   			);
    	    	}
    	    }
    	}
    
    //    println("-----------------VARMAP");
    //    iprintln(varMap);
    //
    //    println("----------------_/` now try to determine the types of the variables");
    //
    	// try to determine the types of the variables:
    	//for (mapId <- varMap) { // loop over the scopes
    	//	m = varMap[mapId];
    	//	
    	//	for (varDecl <- toSet(domain(m))) { // loop over the variable declarations
    	//		println("STARTING ANAYLYSIS FOR: <varDecl>");
    	//		set[TypeSet] ts = { estimates[typeOf(varDeclId)] | varDeclId <- m[varDecl] };
    	//		println("STARTING ANAYLYSIS FOR: <ts>");
    	//		iprintln(ts);
    	//		// we leave Universe() out, because this has not been resolved (yet)
    	//		//println("#1 :: <ts>");
    	//		
    	//		// this step is not needed because we take the intersection
    	//		//ts = { t | t <- ts, Universe() !:= t };
    	//		//println("#2 :: <ts>");
    	//	
    	//		if (!isEmpty(ts)) {
    	//			TypeSet newVarType = Intersection(ts);
    	//			if (newVarType == EmptySet()) {
    	//				newVarType = LCA(ts);
    	//			}
    	//			for (vId <- m[varDecl]) {
    	//				// apply intersection.. if that fails, try widening by taking the LUB.
    	//				println("NEW VAR TYPE");
    	//				println(newVarType);
    	//				println(estimates[typeOf(vId)]);
    	//				estimates[typeOf(vId)] = newVarType; 
    	//				println(estimates[typeOf(vId)]);
    	//				//estimates[typeOf(varId)] = Union(ts); 
    	//				// maybe change this to LCA
			  //  		// LEAST UPPER BOUND CHECK (least common ancestor) 
			  //  	}
			  //  }
    	//	}
    	//}
    	
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
	iprintln(estimates); 
	estimates = innermost visit(estimates) {
		case Subtypes(Set({TypeSymbol s, *rest })) => Union({Single(s), Set(reach(invertedSubtypes, {s})), Subtypes(Set(rest))}) 
	};
 
 	
 		
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