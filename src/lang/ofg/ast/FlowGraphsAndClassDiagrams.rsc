module lang::ofg::ast::FlowGraphsAndClassDiagrams

import lang::ofg::ast::FlowLanguage;
import lang::ofg::ast::Java2OFG;
import List;
import Relation;
import lang::java::m3::Core;

import IO;
import vis::Figure; 
import vis::Render;

alias OFG = rel[loc from, loc to];

OFG buildGraph() = buildGraph(getProgram());
OFG buildGraph(loc l) {
	p = createOFG(l);
	g = buildGraph(p);
	gen = generators(p);
	//visualize(gen);
	//visualize(g+gen);
	gen54 = generators54(p);
	visualize(g );
	//visualize(g + gen + gen54);
	
	iprintln(g);
	//visualize(gen54);
	//visualize(g+gen54);
	
	//return prop(g, gen54, gen, false);
}

OFG buildGraph(Program p) 
  = { <as[i], fps[i]> | newAssign(x, cl, c, as) <- p.statements, constructor(c, fps) <- p.decls, i <- index(as) }
  + { <cl + "this", x> | newAssign(x, cl, _, _) <- p.statements }
  + { <y, x> | assign(x, _, y) <- p.statements}
  + { <as[i], fps[i]> | call(x, _, y, m, as) <- p.statements, method(m, fps) <- p.decls, i <- index(as) }   
  + { <y, m + "this"> | call(_, _, y, m, _) <- p.statements }
  + { <m + "return", x> | call(x, _, _, m, _) <- p.statements, x != emptyId}
  ;
  
rel[loc,loc] generators(Program p) 
  = { <cl + "this", c > | newAssign(_, cl, c, _) <- p.statements };

rel[loc,loc] generators54(Program p) 
  = { <y, c > | assign(_, c, y) <- p.statements }
  + { <m + "return", c> |  call(_, c, _, m, _) <- p.statements}
  ;
   
public OFG prop(OFG g, rel[loc,loc] gen, rel[loc,loc] kill, bool back) {
  OFG IN = { };
  OFG OUT = gen + (IN - kill);
  gi = g<to,from>;
  set[loc] pred(loc n) = gi[n];
  set[loc] succ(loc n) = g[n];
  
  solve (IN, OUT) {
    IN = { <n,\o> | n <- carrier(g), p <- (back ? pred(n) : succ(n)), \o <- OUT[p] };
    OUT = gen + (IN - kill);
  }
  
  return OUT;
}

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

public void prettyPrintProgram(Program p)
{
	println("Declarations:");
	visit(p.decls) {
		case attribute(loc id): println("Attribute: <id>");
	}
	visit(p.decls) {
		case method(loc id, list[loc] formalParameters): println("Method: <id>");
	}
	visit(p.decls) {
		case constructor(loc id, list[loc] formalParameters): println("Constructor: <id>");
	}
	visit(p.decls) {
		case function(loc id, list[loc] formalParameters): println("Function: <id>");
	}
	
	println("Statements:");
	visit(p.statements) {
		case newAssign(loc target, loc class, loc ctor, list[loc] actualParameters): println("NewAssign: <target> :: <class> :: <ctor> :: <actualParameters>");
	}
	visit(p.statements) {
		case assign(loc target, loc cast, loc source): println("Assign: <target> :: <cast> :: <source>");
	}
	visit(p.statements) {
		case call(loc target, loc cast, loc receiver, loc method, list[loc] actualParameters): println("Call: <target> :: <method>");
	}
}

public void visualize(OFG g) 
{
	n = [ box(text("<n.path[0..]>"), id("<n>")) | n <- (range(g) + domain(g)) ];
	e = [ edge("<a>", "<b>") | <a,b> <- g ];
	render(graph(n, e, hint("layered"), gap(100)));
}