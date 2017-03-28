module lang::ofg::ast::PHP2OFG

import DateTime;
import Exception;
import IO;
import List;
import Map;
import Relation;
import Set;
import String;
import Traversal;
import ValueIO;

import lang::ofg::ast::FlowGraphsAndClassDiagrams;
import lang::ofg::ast::FlowLanguage;

import lang::php::util::Utils;
import lang::php::util::Corpus;
import lang::php::ast::System;
import lang::php::ast::AbstractSyntax;
import lang::php::util::Config;
import lang::php::m3::FillM3;
import lang::php::m3::Declarations;
import lang::php::m3::Containment;
import lang::php::pp::PrettyPrinter;

import lang::php::analysis::cfg::BuildCFG;
import lang::php::analysis::cfg::Visualize;
import lang::php::analysis::NamePaths;

//
// Create an OFG from a location
//
// location to System
// Sytem to Program
// Program to OFG

//loc projectLocation = |file:///Users/ruud/git/php-analysis/src/tests/resources/OFL|;
//loc projectLocation = |file:///Users/ruud/Projects/Smarty-3.1.16|;
//loc projectLocation = |file:///Users/ruud/Projects/Smarty-3.1.16/libs/sysplugins/|;
//loc projectLocation = |file:///Users/ruud/git/werkspot/api4/src/Werkspot/ApiBundle/Entity/Manager|;
//loc projectLocation = |file:///Users/ruud/git/werkspot/website/web/wsCorePlugin|;
//loc projectLocation = |file:///Users/ruud/git/werkspot/website/plugins/wsCorePlugin/modules|;
//loc projectLocation = |file:///Users/ruud/git/werkspot/website/|;
//loc projectLocation = |file:///Users/ruud/mini-test|;
//loc projectLocation = |file:///Users/ruud/Eclipse/workspace/eLibPartlyPHP/|;
//loc projectLocation = |file:///Users/ruud/test|;
//loc projectLocation = |file:///PHPAnalysis/systems/WerkspotNoTests/WerkspotNoTests-oldWebsiteNoTests|;
loc projectLocation = |file:///PHPAnalysis/systems/WerkspotNoTests/WerkspotNoTests-oldWebsiteNoTests/plugins/wsCorePlugin/modules/craftsman/lib|;

OFG prop() = prop(true);
OFG prop(bool useCache) {
	Program p = getProgram(useCache); 
	//prettyPrintProgram(p);
	
	//OFG edges = buildGraph(p);
	//iprintln(edges);
	//visualize(edges);
	
	//return prop(edges, generators(p), generators54(p), false);
}

OFG buildGraph() = buildGraph(getProgram(true));

public Program getProgram(bool useCache) {
	
	System system = getSystem(projectLocation, useCache);
	system = discardErrorScripts(system);

	M3Collection m3s = getM3CollectionForSystem(system, projectLocation);
	M3 globalM3 = M3CollectionToM3(m3s, projectLocation);

	globalM3 = calculateAfterM3Creation(globalM3, system);
	globalM3 = addPredefinedDeclarations(globalM3);
	
	//iprintln(globalM3);
	exit();	

	// todo: remove `m3s` if possible
	return systemToProgram(system, m3s, globalM3);
}

// temp function to check the control flow graph
//public void cfgTest()
//{
//	throw "this was just a test";
//	loc l = |file:///Users/ruud/git/werkspot/api4/src/Werkspot/ApiBundle/Entity/Manager|;
//	for (scr <- range(discardErrorScripts(getSystem(l, false))))
//	{
//		// Build control-flow graphs for the entire script 
//		//< lscr, cfgs > = buildCFGsAndScript(scr);
//		//println(buildCFGsAndScript(scr));
//		//iprintln(buildCFGs(scr));
//	
//		cfgs = buildCFGs(scr);
//		for (c <- cfgs)
//		{
//			str name = "out_<printNamePath(cfgs[c][0])>.dot";
//			println("writing <name>");
//			renderCFGAsDot(cfgs[c], l+name);
//		}
//	}
//}

@doc {
declarations are:
	Class:
	- attributes
	- methods
	- constructors

Statements are:
	Class:
	- new Assign	->  x =  new Y(A1,..,Ak);
	- assign		->  x =  y
	- call			-> [x =] y.m(A1,..,Ak);

}
public Program systemToProgram(System system, M3Collection m3s, M3 m3) {
	logMessage("Resolving declarations",2);
	set[Decl] decls = {*getDeclarationsForScript(propagateDeclToScope(system[scriptLoc]), m3) | scriptLoc <- system};
	logMessage("Resolved <size(decls)> declaration(s)", 2);
	//iprintln(decls);
	
	logMessage("Resolving statements",2);
	set[Stm]  stmts = {*getStatementsForScript(propagateDeclToScope(system[scriptLoc]), m3s[scriptLoc], m3) | scriptLoc <- system};
	logMessage("Resolved <size(stmts)> statement(s)", 2);
	//iprintln(stmts);

	return program(decls, stmts);
}

@doc { 
declarations are:
- class attributes
- class methods 
- functions 
}
public set[Decl] getDeclarationsForScript(Script script, M3 m3) {
	set[Decl] decls = {};
	
	visit(script) {
		// precondition for ClassItem: must be an item of a class, no interface
		case ClassItem classItem:
			if (isClassItem(getTraversalContextNodes()))
				fail classItem; // classItem is part of a class, continue the visit
		
		case ClassItem::property(_, list[Property] props): 
			for (prop <- props) 
				decls += Decl::attribute(prop@decl);
				
		case m:ClassItem::method(name,_,_,param,_): 
			if (isConstructor(m@decl, name, m3))
				decls += Decl::constructor(m@decl, [p@decl | p<-param]);
			else
				decls += Decl::method(m@decl, [p@decl | p<-param]);
			
		case f:Stmt::function(name,_,param,_): 
			decls += Decl::function(f@decl, [p@decl | p<-param]);
	}
	
	// add implicit constructors for all classes without explicit contructors
	decls += { Decl::constructor((c@decl)[scheme="php+method"] + "__construct", []) | /c:class(name, _, _, _, b) <- script, !(method(/^(<name>|__construct)$/i, _, _, _, _) <- b)};

	return decls;
}

private bool isClassItem(list[node] nodeList) 
{
	tuple[node head, list[node] rest] nodes = pop(nodeList);
	
	solve(nodes) {
		if (ClassDef := nodes.head) {
			return true;
		}
		
		if (!isEmpty(nodes.rest)) {
			nodes = pop(nodes.rest);
		}
	}

	// no class is resolved.	
	return false;
}

@doc { 
statemetns are:
- newAssign 
- assign 
- call
}
public set[Stm] getStatementsForScript(Script script, M3 scriptM3, M3 globalM3) {
	set[Stm] stms = {}; 
	loc defaultCast = emptyId; 

	visit(script) {
		// new assign: $lhs = new RHS();
		case a:assign(Expr lhs, /Expr rhs:new(c,ps)):	
		{
			set[loc] lhsDecls = getLhsDecls(lhs, globalM3);
			set[loc] rhsStmts = getRhsStmts(rhs, globalM3);
			
			list[loc] params = [ *globalM3@uses[p@at] | p <- ps ];
			params = [ p | p <- params, isVariable(p) ];
			
			stms += { Stm::newAssign(l, r, r[scheme="php+method"]+"__construct", params) | l <- lhsDecls, r <- rhsStmts };
			if (name(name(n)) := c) { // add possible constructor (same name as the classname)
				stms += { Stm::newAssign(l, r, r[scheme="php+method"]+toLowerCase(n), params) | l <- lhsDecls, r <- rhsStmts };
			}
		}
	
		// assign: $lhs = $rhs;	
		case assign(Expr lhs, Expr rhs):	
		{
			set[loc] lhsDecls = getLhsDecls(lhs, globalM3);
			set[loc] rhsStmts = getRhsStmts(rhs, globalM3);
			loc cast = defaultCast;
			stms += { Stm::assign(l, cast, r) | l <- lhsDecls, r <- rhsStmts };
		}
		
		// assign with operator: $lhs += $rhs;	
		case assignWOp(Expr lhs, Expr rhs, Op operation):	
		{
			set[loc] lhsDecls = getLhsDecls(lhs, globalM3);
			set[loc] rhsDecls = getRhsStmts(rhs, globalM3);
			loc cast = getCastForOperation(operation);
			stms += { Stm::assign(l, cast, r) | l <- lhsDecls, r <- rhsDecls };
		}
		
		// assign with reference: $lhs =& $rhs;	
		case a:refAssign(Expr lhs, Expr rhs):
		{
			set[loc] lhsDecls = getLhsDecls(lhs, globalM3);
			set[loc] rhsStmts = getRhsStmts(rhs, globalM3);
			loc cast = defaultCast;
			
			stms += { Stm::assign(l, cast, r) | l <- lhsDecls, r <- rhsStmts };
		}
	
		// method call: $lhs->rhs();	
		case c:methodCall(Expr target, NameOrExpr methodName, list[ActualParameter] parameters):	
		{
			set[loc] lhsVars = { emptyId }; // no assignment of the result of the method call
			
			if (n <- getTraversalContextNodes(), e:Expr::assign(assignLhs,_) := n, c@scope == e@scope) 	{
				bool lhsHasDecl = "decl" in getAnnotations(assignLhs);
				lhsVars = lhsHasDecl ? { assignLhs@decl } : *globalM3@uses[assignLhs@at];
			}
			
			//println("method Call: <pp(c)>:: <readFile(target@at)>"); // todo remove this line
			set[loc] lhsDecls = { t | t <- globalM3@uses[target@at] , !(isClass(t) || isInterface(t)) };
			loc cast = defaultCast; // calls have no case operations, maybe annotations can be used to get more info here.
			set[loc] rhsStmts = { t | t <- globalM3@uses[methodName@at], isMethod(t) };	
			list[loc] params = [ *globalM3@uses[p@at] | p <- parameters ];
			params = [ p | p <- params, isMethodParam(p) ];
			
			// TODO: emptyId is the lhs variable, when this method call is inside an assign expr	
			stms += { Stm::call(lhsVar, cast, l, r, params) | lhsVar <- lhsVars, l <- lhsDecls, r <- rhsStmts };
		}
		
		// static method call: LHS::rhs();	
		// maybe add this later??!
		case c:staticCall(NameOrExpr staticTarget, NameOrExpr methodName, list[ActualParameter] parameters):	
		{
			//println("static method Call: <pp(c)>");
			set[loc] lhsDecls = globalM3@uses[staticTarget@at];
			loc cast = defaultCast; // todo resolve this
			set[loc] rhsStmts = { t | t <- globalM3@uses[methodName@at], isMethod(t) };	
			list[loc] params = [ *globalM3@uses[p@at] | p <- parameters ];
			
			stms += { Stm::call(emptyId, cast, l, r, [p|p<-params,isMethodParam(p)]) | l <- lhsDecls, r <- rhsStmts };
		}
		
		// add function calls
	}
	return stms;
}

private loc getCastForOperation(Op operation) {
	switch(operation) {
		// todo: return the corret case types	
		case bitwiseAnd(): return emptyId; 
		case bitwiseOr(): return emptyId; 
		case bitwiseXor(): return emptyId;
		case concat(): return emptyId;
		case div(): return emptyId;
		case minus(): return emptyId;
		case \mod(): return emptyId;
		case mul(): return emptyId;
		case plus(): return emptyId;
		case rightShift(): return emptyId;
		case leftShift(): return emptyId;
		case booleanAnd(): return emptyId;
		case booleanOr(): return emptyId;
		case booleanNot(): return emptyId;
		case bitwiseNot(): return emptyId;
		case gt(): return emptyId;
		case geq(): return emptyId;
		case logicalAnd(): return emptyId;
		case logicalOr(): return emptyId;
		case logicalXor(): return emptyId;
		case notEqual(): return emptyId;
		case notIdentical(): return emptyId;
		case postDec(): return emptyId;
		case preDec(): return emptyId;
		case postInc(): return emptyId;
		case preInc(): return emptyId;
		case lt(): return emptyId;
		case leq(): return emptyId;
		case unaryPlus(): return emptyId;
		case unaryMinus(): return emptyId;
		case equal(): return emptyId;
		case identical(): return emptyId;
	}
}
private set[loc] getLhsDecls(Expr lhs, M3 globalM3) {
	set[loc] decls = {};

	switch(lhs) { 
		case var(_): 
		{
			if ("decl" in getAnnotations(lhs)) 
				decls += lhs@decl; 
			else
				logMessage("Possible problem: var has no decl: " + pp(lhs), 2);
		}
		
		case /fetchArrayDim(Expr var,_):
		{
			return getLhsDecls(var, globalM3);
		}
		
		// todo: handle list stmts better, now you will assign
		// example list($a, $b) = array("a", "bee");
		
		case listExpr([*exprs]): 
		{
			for (someExpr(e) <- exprs)
			{
				decls += getLhsDecls(var, globalM3);
			}
			return decls;
		}
				
		case p:propertyFetch(_,propertyName):
		{
			decls += { *globalM3@uses[propertyName@at] };
			assert(!isEmpty(decls)) : "Property could not be resolved :: `<pp(p)>` :: <p@at>";
		}
		
		// static calls
		case p:staticPropertyFetch(_,propertyName):
		{
			decls += { *globalM3@uses[propertyName@at] };
			assert(!isEmpty(decls)) : "Property could not be resolved :: `<pp(p)>` :: <p@at>";
		}
			
		
		//case listExpr(list[OptionExpr] listExprs): ; // todo: example list($a, $b) = array("a", "bee");
		case x:_:
			println("Implement unsupported node: `<pp(x)>` :: <x>");	
	}

	//assert !isEmpty(decls) : "No declarations found for: <lhs>"; // post condition	

	return decls;
}

private set[loc] getRhsStmts(Expr rhs, globalM3) {
	set[loc] stmts = {};
	
	switch(rhs) { // use switch for now. indirect stuff will not be supported
		case /var(_): // add all variables
			stmts += { *globalM3@uses[rhs@at] };
			
		case new(NameOrExpr className, list[ActualParameter] parameters): 
			stmts += { *globalM3@uses[className@at] };
		
		case propertyFetch(_,propertyName):
			stmts += { *globalM3@uses[propertyName@at] };
			
		// ignore these, they can be removed later	
		case noExpr(): ;
		case Scalar: ;
		case x:_:
			throw("Implement unsupported node: <x>");	
	}
	
	//assert !isEmpty(stmts) : "No statements found for: <rhs>"; // post condition	
	
	return stmts;	
}
@doc {
	Check if a method is the constructor:
	
	Rules for class in a namespace:
		- `__construct` is the only possible constructor
	
	Rules for class in the global namespace:
		- `__construct` is the constructor
		- when `__construct` is not defined, a method with the name of the class is the constructor
		- no other method can be the constructor
}
private bool isConstructor(loc methodDecl, str methodName, M3 scriptM3) {
	if (methodName == "__construct") 
		return true; // __construct is always a constructor

	// if a class is in a global namespace, the constructor can be the name of the class (but only if __construct does not exist);		
	if (globalNamespace == getNamespace(scriptM3@containment, methodDecl)) 
	{
		loc classDecl = getClassTraitOrInterface(scriptM3@containment, methodDecl);
		set[str] classMethods = { elm.file | elm <- elements(scriptM3, classDecl), isMethod(elm) };
		if ("__construct" in classMethods) 
		{
			return false; // this method is not the constructor because __construct is.
		}
		else if (toLowerCase(methodName) == toLowerCase(classDecl.file)) 
		{
			return true; // __construct does not exist and this method has the same name as the class.	
		}
	}
	// the class of the method is not in global namespace and is not called "__construct"	
	return false; 
}







// diagram


public void drawDiagram(M3 m) {
  classFigures = [box(text("<cl.path[1..]>"), id("<cl>")) | cl <- classes(m)]; 
  edges = [edge("<to>", "<from>") | <from,to> <- m@extends ];  
  
  render(graph(classFigures, edges, hint("layered"), std(gap(10)), std(font("Bitstream Vera Sans")), std(fontSize(8))));
}
 
public str dotDiagram(M3 m) {
  return "digraph classes {
         '  fontname = \"Bitstream Vera Sans\"
         '  fontsize = 8
         '  node [ fontname = \"Bitstream Vera Sans\" fontsize = 8 shape = \"record\" ]
         '  edge [ fontname = \"Bitstream Vera Sans\" fontsize = 8 ]
         '
         '  <for (cl <- classes(m)) { /* a for loop in a string template, just like PHP */>
         ' \"N<cl>\" [label=\"{<cl.path[1..] /* a Rascal expression between < > brackets is spliced into the string */>||}\"]
         '  <} /* this is the end of the for loop */>
         '
         '  <for (<from, to> <- m@extends) {>
         '  \"N<to>\" -\> \"N<from>\" [arrowhead=\"empty\"]<}>
         '}";
}
 
public void showDot(M3 m) = showDot(m, |home:///<m.id.authority>.dot|);
 
public void showDot(M3 m, loc out) {
  writeFile(out, dotDiagram(m));
}
