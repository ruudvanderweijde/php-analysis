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

// pretty print
import lang::php::pp::ConstraintPrettyPrinter;

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
import List;

import analysis::graphs::Graph;

// start of solving constraints (move this stuff somewhere else)

public map[TypeOf var, TypeSet possibles] solveConstraints(set[Constraint] constraintSet, map[loc file, lrel[loc decl, loc location] vars] varMap, M3 m3, System system)
{
	// change (eq|subtyp) TypeOf, TypeSymbol 
	//     to (eq|subtyp) TypeOf, typeOf(TypeSymbol)
	// this is easier than rewiting all code
	constraints = visit(constraintSet) {
		case       eq(TypeOf a, TypeSymbol ts) =>       eq(a, typeSymbol(ts))
		case   subtyp(TypeOf a, TypeSymbol ts) =>   subtyp(a, typeSymbol(ts))
		case supertyp(TypeOf a, TypeSymbol ts) => supertyp(a, typeSymbol(ts))
 	};
  
  	// set the subtype relation
  	setSubTypes(m3, system);
  	
  	// initialEstimates resolves everything to Universe, unless there is concrete information already
	estimates = initialEstimates(constraints);

	// display some debug info
	//debugPrintInitialResults(constraints, estimates);
		
	solve (constraintSet, estimates) { // solve constraints and variable mapping
		constraintSet = constraintSet + deriveMore(constraintSet, estimates, m3);
  		estimates = propagateEstimates(constraintSet, estimates, m3);
  		constraintSet = propagateConstraints(constraintSet, estimates, m3);
  	}
  	
  	return estimates;
}

public set[Constraint] deriveMore(set[Constraint] constraints, map[TypeOf, TypeSet] estimates, M3 m3)
{
	set[Constraint] derivedConstraints = {};
	
    for (v <- estimates) {
    	top-down-break visit (constraints) {
    		// todo: implement me
    		case isAFunction() :; 
    		case hasName(TypeOf a, str name) :;
    		case isMethodOfClass(TypeOf a, TypeOf t, str name) :;
    		case hasMethod(TypeOf a, str name) :
    		{
    			// query M3 for all classes with the method with the given name //or "__call" (out of scope)
    			derivedConstraints += disjunction({ subtyp(a, classType(c)) | <c,m> <- m3@containment, isMethod(m), m.file == toLowerCase(name) /*|| m.file == "__call"*/ });
    		}
    		case hasMethod(TypeOf a, str name, set[ModifierConstraint] modifiers) :;
    		case conditional(Constraint preCondition, Constraint result) :
    		{
    			;
    			//println("conditional");
    			//if (isValidPrecondition(preCondition, estimates)) {
    			//	derivedConstraints += result;
    			//}
    		}
    		case disjunction({constraint}): derivedConstraints += constraint; // disjunction of 1 item
    		case disjunction(set[Constraint] constraints) :;
    		
    		case exclusiveDisjunction({constraint}): derivedConstraints += constraint; // excl disjunction of 1 item
    		case exclusiveDisjunction(set[Constraint] constraints) :;
    		
    		case conjunction(set[Constraint] constraints): derivedConstraints += constraint; // conjunction of 1 item
    		case conjunction(set[Constraint] constraints) :;
    		case negation(Constraint constraint) :;
    	}
    }
	
	//logMessage("Derived <size(derivedConstraints)> Constraints", 2);
	//iprintln(toStr(derivedConstraints));
	return derivedConstraints;
} 

// for all resolved estimates, add new constraints
public set[Constraint] propagateConstraints (set[Constraint] constraints, map[TypeOf, TypeSet] estimates, M3 m3)
{
	// do nothing for now...
	return constraints;
	
	// THIS IS NOT BEING USED NOW!!!!
	set[Constraint] extraConstraints = {};
	
	for (identifier <- estimates) {
		typeSet = estimates[identifier];
		
		// change this to: Universe() !in typeSet
		if (Universe() := typeSet) {
			continue; // skip universe, we only want to propagate 'solved' estimates
		}
	
		if (Set({TypeSymbol ts}) := typeSet) { // for now only single resolve types are supported
			
			resolvedType = typeSymbol(ts);
    		
    		// add constraints for resolved types
    		visit (constraints) {
       			case e:eq(l, identifier): extraConstraints += { eq(l, resolvedType) };
       			case e:eq(identifier, r): extraConstraints += { eq(resolvedType, r) };
       			case e:subtyp(l, identifier): extraConstraints += { subtyp(l, resolvedType) };
       			case e:subtyp(identifier, r): extraConstraints += { supertyp(resolvedType, r) };
    		} 
		}
	}
   	
	//logMessage("Propagated <size(extraConstraints)> Constraints", 2);
	return extraConstraints + constraints;
}

public map[TypeOf, TypeSet] propagateEstimates (set[Constraint] constraints, map[TypeOf, TypeSet] estimates, M3 m3)
{
	for (identifier <- estimates) {
		typeSet = estimates[identifier];
		
		// change this to: Universe() !in typeSet
		if (Universe() := typeSet) {
			//println("Skipped for being universe... <toStr(identifier)>");
			continue; // skip universe, we only want to propagate 'solved' estimates
		}
		
		// top-down-break stops at all matches, not just in depth??
		// for now a switch will work with the stuff i want to achieve
    	//top-down-break visit (constraints) {
    	top-down-break visit (constraints) {
    		// do nothing, just stop visiting; 
    		case isAFunction() :; 
    		case hasName(TypeOf a, str name) :;
			case isMethodOfClass(TypeOf expr, TypeOf classVariable, str name):
			{
				// get the possible class types
				possibleClassTypes = estimates[classVariable];
				
				// check if the object is (a bit) resolved already
				if (Set(ts) := possibleClassTypes) {
					// the type of the function is the union of all possible types
					set[loc] possibleClasses = { classLoc | classType(classLoc) <- ts }; // ts is the actual set in the Set({});
					// methods of the possible classes
					set[loc] possibleMethods = { *getDeclarationLocs(m3, m) | <c,m> <- m3@containment, c in possibleClasses, isMethod(m), m.file == toLowerCase(name) };
					// union of all possible methods
	    			estimates[expr] = Union({ estimates[typeOf(methodLoc)] | methodLoc <- possibleMethods });
				}
			}
    		case hasMethod(TypeOf a, str name) :;
    		case hasMethod(TypeOf a, str name, set[ModifierConstraint] modifiers) :;
    		case conditional(Constraint preCondition, Constraint result) :;
    		case disjunction(set[Constraint] constraints) :;
    		case exclusiveDisjunction(set[Constraint] constraints) :;
    		case conjunction(set[Constraint] constraints) :;
    		case negation(Constraint constraint) :;
    		
    		
			case e:subtyp(lhs:typeOf(_), identifier): {
				//println("---------[ LHS subtype | propagateEstimates ]------------");
				//println(" - identifier :: <toStr(identifier)> :: <identifier>");
				//println(" - lhs :: <toStr(lhs)> :: <lhs>");
				//println(" - constraint :: <toStr(e)> :: <e>");
		    	estimates[lhs] = getIntersectionResult(Subtypes(estimates[identifier]), estimates[lhs]);
		    }
			case e:subtyp(identifier, rhs:typeOf(_)): { // type of rhs is union(supertyp(estimates[rhs], esitmates[identifier]))
				//println("---------[ RHS subtype | propagateEstimates ]------------");
				//println(" - identifier :: <toStr(identifier)> :: <identifier>");
				//println(" - rhs :: <toStr(rhs)> :: <rhs>");
				//println(" - constraint :: <toStr(e)> :: <e>");
		    	estimates[rhs] = getIntersectionResult(Supertypes(estimates[identifier]), estimates[rhs]);
		    }
			
    		case e:eq(lhs:typeOf(_), identifier): {
				//println("---------[ LHS eq | propagateEstimates ]------------");
				//println(" - identifier :: <toStr(identifier)> :: <identifier>");
				//println(" - lhs :: <toStr(lhs)> :: <lhs>");
				//println(" - constraint :: <toStr(e)> :: <e>");
    		
    			estimates[lhs] = getIntersectionResult(estimates[lhs], estimates[identifier]);
    			estimates[identifier] = getIntersectionResult(estimates[lhs], estimates[identifier]);
    		}
    		case e:eq(identifier, rhs:typeOf(_)): {
				//println("---------[ RHS eq | propagateEstimates ]------------");
				//println(" - identifier :: <toStr(identifier)> :: <identifier>");
				//println(" - rhs :: <toStr(rhs)> :: <rhs>");
				//println(" - constraint :: <toStr(e)> :: <e>");
    		
    			estimates[rhs] = getIntersectionResult(estimates[rhs], estimates[identifier]);
    			estimates[identifier] = getIntersectionResult(estimates[rhs], estimates[identifier]);
    		}
		}
    }
   
	return estimates;
}

@doc { do intersections }
private TypeSet getIntersectionResult(TypeSet ts1, TypeSet ts2)
{
	//println("getIntersectionResult - intersection( <ts1>, <ts2> )."); // debug
   	result = Intersection({ ts1, ts2 });
   	
	//println("Results: <result>"); // debug
   	return result;
}

@doc { do union }
private TypeSet getUnionResult(TypeSet ts1, TypeSet ts2)
{
	//println("getUnionResult - union( <ts1>, <ts2> )."); // debug
   	result = Union({ ts1, ts2 });
   	
	//println("Results: <result>"); // debug
   	return result;
}

public bool isValidPrecondition(Constraint precondition, map[TypeOf, TypeSet] estimates)
{
	//println("checking precondition <precondition>");
	for (v <- estimates) {
		//println("estimate: <v> :: <estimates[v]>");
		if (subtyp(v, typeToMatch) := precondition) {
			//println("MATCH!!!: <typeToMatch>");
			if (Set(set[TypeSymbol] resolvedTypes) := estimates[v]) {
				if (typeToMatch in resolvedTypes) {
					return true;
				}
			}
		}
	}
	return false;
	//for (v <- estimates)	{
	//	e = estimates[v];
	//	if (subtyp(l, r) := precondition) {
	//		;
	//	}
	//}
	//return false;
}

@doc { initial type estimates for all typeable objects; like (|php+foo:///bar|: integerType()) }
public map[TypeOf, TypeSet] initialEstimates (set[Constraint] constraints) 
{
 	map[TypeOf, TypeSet] result = ();
 	
 	// add Universe() for all typeOfs
 	visit (constraints) {
 		case                     TypeOf t:typeOf(loc ident): result = addToMap(result, t, Universe());
 		case                     TypeOf t:   var(loc  decl): result = addToMap(result, t, Universe());
 	};
 	
 	// add resovled types for all non-conditional constraints
 	top-down-break visit (constraints) {
        // do nothing, just stop visiting; should still be implemented
        case isAFunction() :; 
        case hasName(TypeOf a, str name) :;
        case isMethodOfClass(TypeOf a, TypeOf t, str name) :;
        case hasMethod(TypeOf a, str name) :;
        case hasMethod(TypeOf a, str name, set[ModifierConstraint] modifiers) :;
        case conditional(Constraint preCondition, Constraint result) :;
        case disjunction(set[Constraint] constraints) :;
        case exclusiveDisjunction(set[Constraint] constraints) :;
        case conjunction(set[Constraint] constraints) :;
        case negation(Constraint constraint) :;
            
 		case       eq(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Single(ts)); 
 		case       eq(typeSymbol(TypeSymbol ts), TypeOf t): result = addToMap(result, t, Single(ts)); 
 		case   subtyp(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Subtypes(Set({ts}))); 
 		case   subtyp(typeSymbol(TypeSymbol ts), TypeOf t): result = addToMap(result, t, Supertypes(Set({ts}))); 
 		case supertyp(TypeOf t, typeSymbol(TypeSymbol ts)): result = addToMap(result, t, Supertypes(Set({ts}))); 
 		case supertyp(typeSymbol(TypeSymbol ts), TypeOf t): result = addToMap(result, t, Subtypes(Set({ts}))); 
 	};
 	
 	return result;
}

@doc{ Stupid wrapper to add or take the intersection of values. Only used for initialEstimates }
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
public rel[TypeSymbol, TypeSymbol] setSubTypes(M3 m3, System system) 
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
	
	// used in types/TypeConstraints.rsc
	setSubTypeRelation(subtypes);
	
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
	println("-----------------\nAll constraints pretty printed!\n-----------------");
	for (c <- constraints) {
		println("<toStr(c)>");
	}
	
	println("-----------------\nInitial estimates results!\n-----------------");
	for (to:typeOf(est) <- estimates) {
		println("<toStr(to)> :: <estimates[to]>");
	}
}

// Pretty Print the constraints
private str toStr(set[Constraint] cs)					= "{\n  <intercalate(",\n  ", sort([ toStr(c) | c <- sort(toList(cs))]))>\n}";
private str toStr(eq(TypeOf t1, TypeOf t2)) 			= "<toStr(t1)> = <toStr(t2)>";
private str toStr(eq(TypeOf t1, TypeSymbol ts)) 		= "<toStr(t1)> = <toStr(ts)>";
private str toStr(subtyp(TypeOf t1, TypeOf t2)) 		= "<toStr(t1)> \<: <toStr(t2)>";
private str toStr(subtyp(TypeOf t1, TypeSymbol ts)) 	= "<toStr(t1)> \<: <toStr(ts)>";
private str toStr(supertyp(TypeOf t1, TypeOf t2)) 		= "<toStr(t1)> :\> <toStr(t2)>";
private str toStr(supertyp(TypeOf t1, TypeSymbol ts)) 	= "<toStr(t1)> :\> <toStr(ts)>";
private str toStr(disjunction(set[Constraint] cs))		= "or(<intercalate(", ", sort([ toStr(c) | c <- sort(toList(cs))]))>)";
private str toStr(exclusiveDisjunction(set[Constraint] cs))	= "xor(<intercalate(", ", sort([ toStr(c) | c <- sort(toList(cs))]))>)";
private str toStr(conjunction(set[Constraint] cs))		= "and(<intercalate(", ", sort([ toStr(c) | c <- sort(toList(cs))]))>)";
private str toStr(negation(Constraint c)) 				= "neg(<toStr(c)>)";
private str toStr(conditional(Constraint c, Constraint res)) = "if (<toStr(c)>) then (<toStr(res)>)";
private str toStr(isAFunction(TypeOf t))				= "<toStr(t)> = someFunction";
private str toStr(isMethodOfClass(TypeOf t, TypeOf t2, str name))	= "isMethodOfClass(<toStr(t)>, <toStr(t2)>, <name>)";
private str toStr(hasMethod(TypeOf t, str n))			= "hasMethod(<toStr(t)>, <n>)";
private str toStr(hasMethod(TypeOf t, str n, set[ModifierConstraint] mcs))	= "hasMethod(<toStr(t)>, <n>, { <intercalate(", ", sort([ toStr(mc) | mc <- sort(toList(mcs))]))> })";
private str toStr(required(set[Modifier] mfs))			= "<intercalate(", ", sort([ toStr(mf) | mf <- sort(toList(mfs))]))>";
private str toStr(notAllowed(set[Modifier] mfs))		= "<intercalate(", ", sort([ "!"+toStr(mf) | mf <- sort(toList(mfs))]))>";
default str toStr(Constraint c) { throw "Please implement toStr for node :: <c>"; }

private str toStr(typeOf(loc i)) 						= isFile(i) ? "["+readFile(i)+"]" : "[<i>]";
private str toStr(typeOf(TypeSymbol ts))				= "<toStr(ts)>";
private str toStr(TypeOf::arrayType(set[TypeOf] expr))	= "arrayType(<intercalate(", ", sort([ toStr(e) | e <- sort(toList(expr))]))>)";
private str toStr(TypeSymbol t) 						= "<t>";
private str toStr(Modifier m) 							= "<m>";
default str toStr(TypeOf::typeSymbol(TypeSymbol ts)) 	= "<toStr(ts)>";
default str toStr(TypeOf::var(loc ts)) 					= "$<ts.file>";

private str toStr(set[TypeSymbol] ts)					= "{ <intercalate(", ", sort([ toStr(t) | t <- sort(toList(ts))]))> }";
// deprecated
private str toStr(TypeSet::Universe())							= "{ any() }";
private str toStr(TypeSet::EmptySet())							= "{}";
//private str toStr(TypeSet::Root())								= "{ any() }";
private str toStr(TypeSet::Single(TypeSymbol t))				= "<toStr(t)>";
private str toStr(TypeSet::Set(set[TypeSymbol] ts))				= "{ <intercalate(", ", sort([ toStr(t) | t <- sort(toList(ts))]))> }";
private str toStr(TypeSet::Subtypes(TypeSet subs))				= "sub(<toStr(subs)>)";
private str toStr(TypeSet::Supertypes(TypeSet supers))			= "super(<toStr(supers)>)";
private str toStr(TypeSet::Union(set[TypeSet] args))			= "<intercalate(", ", sort([ toStr(s) | s <- sort(toList(args))]))>";
private str toStr(TypeSet::Intersection(set[TypeSet] args))		= "<intercalate(", ", sort([ toStr(s) | s <- sort(toList(args))]))>";

default str toStr(TypeOf to) { throw "Please implement toStr for node :: <to>"; }