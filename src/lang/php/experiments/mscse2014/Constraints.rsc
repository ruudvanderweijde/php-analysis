module lang::php::experiments::mscse2014::Constraints

import lang::php::ast::AbstractSyntax;

import lang::php::m3::Core;
import lang::php::ast::System;

import lang::php::types::TypeSymbol;
import lang::php::types::TypeConstraints;
import lang::php::types::core::Constants;
import lang::php::types::core::Variables;

import IO; // for debuggin
import String; // for toLowerCase

private set[Constraint] constraints = {};

// only callable method (from another file)
public set[Constraint] getConstraints(System system, M3 m3) 
{
	// reset the constraints of previous runs
	constraints = {};
	
	for(s <- system) {
		addConstraints(system[s], m3);
	}	
	
	// add constraints for all declarations?
	// eq(@decl = @at)
	
	return constraints;
}

private void addConstraints(Script script, M3 m3)
{ 
	for (stmt <- script.body) {
		addConstraints(stmt, m3);
	}
}

// Wrappers for OptionExpr
private void addConstraints(OptionExpr::noExpr(), M3 m3) {}
private void addConstraints(OptionExpr::someExpr(Expr e), M3 m3) { addConstraints(e, m3); }

// Wrappers for OptionElse
private void addConstraints(OptionElse::noElse(), M3 m3) {}
private void addConstraints(OptionElse::someElse(\else(list[Stmt] body)), M3 m3) { addConstraints(body, m3); }

// Wrappers for list[Expr|Stmt]
private void addConstraints(list[Expr] exprs, M3 m3)    { for (e <- exprs) addConstraints(e, m3); }
private void addConstraints(list[Stmt] stmts, M3 m3)    { for (s <- stmts) addConstraints(s, m3); }


private void addConstraints(Stmt statement, M3 m3)
{
	top-down-break visit (statement) { 
		case classDef(c:class(_, _, _, _, list[ClassItem] members)): {
			addDeclarationConstraint(c);	
			for (m <- members) addConstraints(m, c, m3);
		}
		case interfaceDef(i:interface(_, _, list[ClassItem] members)): {
			addDeclarationConstraint(i);	
			for (m <- members) addConstraints(m, i, m3);
		}
		
		// Control structures:
		// They do not much more than revisting the tree 
		
		// Ignored: Continue | Declare | Break. These are not needed to visit.
		// \continue(OptionExpr continueExpr): ; 
		// declare(list[Declaration] decls, list[Stmt] body) // visit handles this
		// \break(OptionExpr breakExpr) // > php5.4 $num=4 is not allowed
		
		case \if(Expr cond, list[Stmt] body, list[ElseIf] elseIfs, OptionElse elseClause): {
			addConstraints(cond, m3);
			addConstraints(body, m3);
			addConstraints([ *ei.cond | ei <- elseIfs ], m3) ;
			addConstraints([ *ei.body | ei <- elseIfs ], m3) ;
			addConstraints(elseClause, m3);
		}
		
		case \while(Expr cond, list[Stmt] body): {
			addConstraints(cond, m3);
			addConstraints(body, m3);
		}
		
		case do(Expr cond, list[Stmt] body): {
			addConstraints(cond, m3);
			addConstraints(body, m3);
		}
		
		case \for(list[Expr] inits, list[Expr] conds, list[Expr] exprs, list[Stmt] body): {
			addConstraints(inits, m3);
			addConstraints(conds, m3);
			addConstraints(exprs, m3);
			addConstraints(body, m3);
		}
		
		case foreach(Expr arrayExpr, OptionExpr keyvar, bool byRef, Expr asVar, list[Stmt] body): {
			addConstraints(arrayExpr, m3);
			addConstraints(keyvar, m3);
			addConstraints(asVar, m3);
			addConstraints(body, m3);
		}
		
		case \switch(Expr cond, list[Case] cases): {
			addConstraints(cond, m3);
			for (Case c <- cases) {
				addConstraints(c.cond, m3);
				addConstraints(c.body, m3);
			}
		}
		
		case \return(OptionExpr returnExpr):	addConstraints(returnExpr, m3);	
		case exprstmt(Expr expr): 				addConstraints(expr, m3);
		
		case f:function(str name, bool byRef, list[Param] params, list[Stmt] body): {
			addDeclarationConstraint(f);
			addConstraintsOnAllVarsWithinScope(f);
			addConstraintsOnAllReturnStatementsWithinScope(f);
			
			addConstraints(body, m3);
			// todo add parameters
		}
		
		// These items can be ignored, as they have no constraints or already visited
		// - emptyStmt() 
		// - label(str labelName) 
		// - goto(Name gotoName) 
		// - block(list[Stmt] body)
		// - namespace(OptionName nsName, list[Stmt] body)
		// - namespaceHeader(Name namespaceName)
		// - use(list[Use] uses) 
		// - haltCompiler(str remainingText)
		// - tryCatch(list[Stmt] body, list[Catch] catches)
		// - tryCatchFinally(list[Stmt] body, list[Catch] catches, list[Stmt] finallyBody)
		// - inlineHTML(str htmlText)
		
// TODO :: (items below)
//	| const(list[Const] consts)
//	| echo(list[Expr] exprs)
//	| global(list[Expr] exprs)
//	| traitDef(TraitDef traitDef)
//	| static(list[StaticVar] vars)
//	| \throw(Expr expr)
//	| unset(list[Expr] unsetVars)
	}	
}

private void addConstraints(ClassItem ci, &T <: node parentNode, M3 m3) 
{
	// Precondition: cit = class/interface/trait
	assert
		class(_,_,_,_,_) := parentNode || interface(_,_,_) := parentNode || trait(_,_) := parentNode: 
		"Precondition failed. parentNode must be [classDef|interfaceDef|traitDef]";
		
	// handle special keywords $this | static | parent: // are already provided in m3
	// TODO
	
	top-down-break visit (ci) {
		case property(set[Modifier] modifiers, list[Property] prop): {
			for (p:property(str propertyName, OptionExpr defaultValue) <- prop) {
				constraints += { eq(typeOf(p@decl), typeOf(p@at)) };
				
				if (someExpr(e) := defaultValue) {
					addConstraints(e, m3);
					constraints += { eq(typeOf(p@at), typeOf(e@at)) };
				}
			}
		}
		
		case constCI(list[Const] consts): {
			for (const:const(str name, Expr constValue) <- consts) {
				constraints += {
					eq(typeOf(const@decl), typeOf(const@at)),
					eq(typeOf(const@at), typeOf(constValue@at))
				};
				addConstraints(constValue, m3);
			}
					
		}
		
		case m:method(str name, set[Modifier] modifiers, bool byRef, list[Param] params, list[Stmt] body): {
			addDeclarationConstraint(m);
			addConstraintsOnAllVarsWithinScope(m);
			addConstraintsOnAllReturnStatementsWithinScope(m);
			
			for (stmt <- body) addConstraints(stmt, m3);
			// todo params
		}
	//| traitUse(list[Name] traits, list[Adaptation] adaptations)
	}
}

private void addConstraints(Expr e, M3 m3)
{
	top-down-break visit (e) {
		case a:array(list[ArrayElement] items): {
			constraints += { eq(typeOf(a@at), arrayType({ typeOf(i.val@at) | i <- items })) };
			for (arrayElement(OptionExpr key, Expr val, bool byRef) <- items) {
				addConstraints(val, m3);
			}
		}
		case f:fetchArrayDim(Expr var, OptionExpr dim): {
			// add constraints for var: var is subtype of array(xxx)
			constraints += { subtyp(typeOf(var@at), array(\any())) };
			addConstraints(var, m3);
				
			constraints += { subtyp(typeOf(f@at), \any()) }; // type of the array fetch...
			constraints += { 
				negation(
					subtyp(typeOf(var@at), object()) 
				)
			};
			
			addConstraints(dim, m3);
		}
		
		case a:assign(Expr assignTo, Expr assignExpr): {
			// add direct constraints
			constraints += { subtyp(typeOf(assignExpr@at), typeOf(assignTo@at)) }; 
			constraints += { subtyp(typeOf(assignTo@at), typeOf(a@at)) };
			// add indirect constraints
			addConstraints(assignTo, m3);
			addConstraints(assignExpr, m3);
		}
		
		case a:assignWOp(Expr assignTo, Expr assignExpr, Op operation): {
			addConstraints(assignTo, m3);
			addConstraints(assignExpr, m3);
			
			switch(operation) {
				case bitwiseAnd():	constraints += { eq(typeOf(assignTo@at), integer()) }; 
				case bitwiseOr():	constraints += { eq(typeOf(assignTo@at), integer()) }; 
				case bitwiseXor():	constraints += { eq(typeOf(assignTo@at), integer()) }; 
				case leftShift():	constraints += { eq(typeOf(assignTo@at), integer()) }; 
				case rightShift():	constraints += { eq(typeOf(assignTo@at), integer()) }; 
				case \mod():		constraints += { eq(typeOf(assignTo@at), integer()) };
				case mul(): 		constraints += { subtyp(typeOf(assignTo@at), float()) };
				case plus(): 		constraints += { subtyp(typeOf(assignTo@at), float()) };
				
				case div(): 
					constraints += { 
						eq(typeOf(assignTo@at), integer()), // LHS is int
						negation(subtyp(typeOf(assignExpr@at), array(\any()))) // RHS is not an array
					};
				
				case minus():
					constraints += { 
						eq(typeOf(assignTo@at), integer()), // LHS is int
						negation(subtyp(typeOf(assignExpr@at), array(\any()))) // RHS is not an array
					};
				
				case concat():		
					constraints += { 
						eq(typeOf(assignTo@at), string()),
						conditional(
							subtyp(typeOf(assignExpr@at), object()),
							hasMethod(typeOf(assignExpr@at), "__tostring")
						)
					};
			}
		}
		
		case op:binaryOperation(Expr left, Expr right, Op operation): {
			addConstraints(left, m3);	
			addConstraints(right, m3);	
			
			switch (operation) {
				case plus():
					constraints += {
						// if left AND right are array: results is array
						conditional(
							conjunction({
								subtyp(typeOf(left@at), array(\any())),
								subtyp(typeOf(right@at), array(\any()))
							}),
							subtyp(typeOf(op@at), array(\any()))
						),
						
						// if left or right is NOT array: result is subytpe of float 
						conditional(
							disjunction({
								negation(subtyp(typeOf(left@at), array(\any()))),
								negation(subtyp(typeOf(right@at), array(\any())))
							}),
							subtyp(typeOf(op@at), float())
						),
						// unconditional: result = array | double | int
						disjunction({
							subtyp(typeOf(op@at), array(\any())),
							subtyp(typeOf(op@at), float()) 
						})
						// todo ?
						// if (left XOR right = double) -> double
						// in all other cases: int
					};
					
				case minus():
					constraints += {
						negation(subtyp(typeOf(left@at),  array(\any()))), // LHS != array
						negation(subtyp(typeOf(right@at), array(\any()))), // RHS != array
						subtyp(typeOf(op@at), float()) // result is subtype of float
						// todo ?
						// if (left XOR right = double) -> double
						// in all other cases: int
					};
					
				case mul(): // refactor: same as minus()
					constraints += {
						negation(subtyp(typeOf(left@at),  array(\any()))), // LHS != array
						negation(subtyp(typeOf(right@at), array(\any()))), // RHS != array
						subtyp(typeOf(op@at), float()) // result is subtype of float
						// todo ?
						// if (left XOR right = double) -> double
						// in all other cases: int
					};
					
				case div(): // refactor: same as minus()
					constraints += {
						negation(subtyp(typeOf(left@at),  array(\any()))), // LHS != array
						negation(subtyp(typeOf(right@at), array(\any()))), // RHS != array
						subtyp(typeOf(op@at), float()) // result is subtype of float
						// todo ?
						// if (left XOR right = double) -> double
						// in all other cases: int
					};
				
				case \mod(): 		constraints += { eq(typeOf(op@at), integer()) }; // [E] = int
				case leftShift():	constraints += { eq(typeOf(op@at), integer()) }; // [E] = int
				case rightShift():	constraints += { eq(typeOf(op@at), integer()) }; // [E] = int
				
				case bitwiseAnd():
					constraints += {
						conditional( // if [L] and [R] are string, then [E] is string
							conjunction({
								eq(typeOf(left@at), string()),
								eq(typeOf(right@at), string())
							}),
							eq(typeOf(op@at), string())
						),
						conditional( // if [L] or [R] is not string, then [E] is int
							disjunction({
								negation(eq(typeOf(left@at), string())), 
								negation(eq(typeOf(right@at), string())) 
							}),
							eq(typeOf(op@at), integer())
						),
						disjunction({ // [E] = int|string 
							eq(typeOf(op@at), string()),
							eq(typeOf(op@at), integer())
						})
					
					};
					
				case bitwiseOr(): // refactor: duplicate of bitwise And
					constraints += {
						conditional( // if [L] and [R] are string, then [E] is string
							conjunction({
								eq(typeOf(left@at), string()),
								eq(typeOf(right@at), string())
							}),
							eq(typeOf(op@at), string())
						),
						conditional( // if [L] or [R] is not string, then [E] is int
							disjunction({
								negation(eq(typeOf(left@at), string())), 
								negation(eq(typeOf(right@at), string())) 
							}),
							eq(typeOf(op@at), integer())
						),
						disjunction({ // [E] = int|string 
							eq(typeOf(op@at), string()),
							eq(typeOf(op@at), integer())
						})
					
					};
					
				case bitwiseXor(): // refactor: duplicate of bitwise And
					constraints += {
						conditional( // if [L] and [R] are string, then [E] is string
							conjunction({
								eq(typeOf(left@at), string()),
								eq(typeOf(right@at), string())
							}),
							eq(typeOf(op@at), string())
						),
						conditional( // if [L] or [R] is not string, then [E] is int
							disjunction({
								negation(eq(typeOf(left@at), string())), 
								negation(eq(typeOf(right@at), string())) 
							}),
							eq(typeOf(op@at), integer())
						),
						disjunction({ // [E] = int|string 
							eq(typeOf(op@at), string()),
							eq(typeOf(op@at), integer())
						})
					
					};
				
				// comparison operators, all result in booleans
				case lt(): 			 constraints += { eq(typeOf(op@at), boolean()) };
				case leq():			 constraints += { eq(typeOf(op@at), boolean()) };
				case gt():			 constraints += { eq(typeOf(op@at), boolean()) };
				case geq():			 constraints += { eq(typeOf(op@at), boolean()) };
				case equal():		 constraints += { eq(typeOf(op@at), boolean()) };
				case identical():	 constraints += { eq(typeOf(op@at), boolean()) };
				case notEqual():	 constraints += { eq(typeOf(op@at), boolean()) };
				case notIdentical(): constraints += { eq(typeOf(op@at), boolean()) };
				// logical operators, all result in booleans
				case logicalAnd():	 constraints += { eq(typeOf(op@at), boolean()) };
				case logicalOr():	 constraints += { eq(typeOf(op@at), boolean()) };
				case logicalXor():	 constraints += { eq(typeOf(op@at), boolean()) };
				case booleanAnd():	 constraints += { eq(typeOf(op@at), boolean()) };
				case booleanOr():	 constraints += { eq(typeOf(op@at), boolean()) };
			}
		}
	
		case expr:unaryOperation(Expr operand, Op operation): {
			addConstraints(operand, m3);	
			
			switch (operation) {
				case unaryPlus():
					constraints += { 
						subtyp(typeOf(expr@at), float()), // type of whole expression is int or float
						negation(subtyp(typeOf(operand@at), array(\any()))) // type of the expression is not an array
						// todo ?
						// in: float -> out: float
						// in: str 	 -> out: int|float
						// in: _	 -> out: int
					};
										
				case unaryMinus():		
					constraints += { 
							subtyp(typeOf(expr@at), float()), // type of whole expression is int or float
							negation(subtyp(typeOf(operand@at), array(\any()))) // type of the expression is not an array
							// todo
							// in: float -> out: float
							// in: str 	 -> out: int|float
							// in: _	 -> out: int
						};
				
				case booleanNot():		constraints += { eq(typeOf(expr@at), boolean()) }; // type of whole expression is bool
				
				case bitwiseNot():		
					constraints += { 
						disjunction({ // the sub expression is int, float or string (rest results in fatal error)
							eq(typeOf(operand@at), integer()),  
							eq(typeOf(operand@at), float()),
							eq(typeOf(operand@at), string()) 
						}),
						disjunction({ // the whole expression is always a int or string
							eq(typeOf(expr@at), integer()),  
							eq(typeOf(expr@at), string()) 
						})
						// todo:
						// in: int 	  -> out: int
						// in: float  -> out: int
						// in: string -> out: string
					}; 
				
				case postInc():
					constraints += {
						conditional( //"if([E] = array(any())) then ([E++] = array(any()))",
							subtyp(typeOf(operand@at), array(\any())),
							subtyp(typeOf(expr@at), array(\any()))
						),
						conditional( //"if([E] = bool()) then ([E++] = bool())",
							eq(typeOf(operand@at), boolean()),
							eq(typeOf(expr@at), boolean())
						),
						conditional( //"if([E] = float()) then ([E++] = float())",
							eq(typeOf(operand@at), float()),
							eq(typeOf(expr@at), float())
						),
						conditional( //"if([E] = int()) then ([E++] = int())",
							eq(typeOf(operand@at), integer()),
							eq(typeOf(expr@at), integer())
						),
						conditional( //"if([E] = null()) then (or([E++] = null(), [E++] = int()))",
							eq(typeOf(operand@at), null()),
							disjunction({eq(typeOf(expr@at), null()), eq(typeOf(expr@at), integer())})
						),
						conditional( //"if([E] = object()) then ([E++] = object())",
							subtyp(typeOf(operand@at), \object()),
							subtyp(typeOf(expr@at), \object())
						),
						conditional( //"if([E] = resource()) then ([E++] = resource())",
							eq(typeOf(operand@at), resource()),
							eq(typeOf(expr@at), resource())
						),
						conditional( //"if([E] = string()) then (or([E++] = float(), [E++] = int(), [E++] = string())",
							eq(typeOf(operand@at), \string()),
							disjunction({eq(typeOf(expr@at), \float()), eq(typeOf(expr@at), integer()), eq(typeOf(expr@at), \string())})
						)
					};
										
				case postDec():
					constraints += {
						conditional( //"if([E] = array(any())) then ([E--] = array(any()))",
							subtyp(typeOf(operand@at), array(\any())),
							subtyp(typeOf(expr@at), array(\any()))
						),
						conditional( //"if([E] = bool()) then ([E--] = bool())",
							eq(typeOf(operand@at), boolean()),
							eq(typeOf(expr@at), boolean())
						),
						conditional( //"if([E] = float()) then ([E--] = float())",
							eq(typeOf(operand@at), float()),
							eq(typeOf(expr@at), float())
						),
						conditional( //"if([E] = int()) then ([E--] = int())",
							eq(typeOf(operand@at), integer()),
							eq(typeOf(expr@at), integer())
						),
						conditional( //"if([E] = null()) then (or([E--] = null(), [E++] = int()))",
							eq(typeOf(operand@at), null()),
							disjunction({eq(typeOf(expr@at), null()), eq(typeOf(expr@at), integer())})
						),
						conditional( //"if([E] = object()) then ([E--] = object())",
							subtyp(typeOf(operand@at), \object()),
							subtyp(typeOf(expr@at), \object())
						),
						conditional( //"if([E] = resource()) then ([E--] = resource())",
							eq(typeOf(operand@at), resource()),
							eq(typeOf(expr@at), resource())
						),
						conditional( //"if([E] = string()) then (or([E--] = float(), [E--] = int(), [E--] = string())",
							eq(typeOf(operand@at), \string()),
							disjunction({eq(typeOf(expr@at), \float()), eq(typeOf(expr@at), integer()), eq(typeOf(expr@at), \string())})
						)
					};
										
				case preInc():
					constraints += {
						conditional( //"if([E] = array(any())) then ([E++] = array(any()))",
							subtyp(typeOf(operand@at), array(\any())),
							subtyp(typeOf(expr@at), array(\any()))
						),
						conditional( //"if([E] = bool()) then ([E++] = bool())",
							eq(typeOf(operand@at), boolean()),
							eq(typeOf(expr@at), boolean())
						),
						conditional( //"if([E] = float()) then ([E++] = float())",
							eq(typeOf(operand@at), float()),
							eq(typeOf(expr@at), float())
						),
						conditional( //"if([E] = int()) then ([E++] = int())",
							eq(typeOf(operand@at), integer()),
							eq(typeOf(expr@at), integer())
						),
						conditional( //"if([E] = null()) then (or([E++] = null(), [E++] = int()))",
							eq(typeOf(operand@at), null()),
							eq(typeOf(expr@at), integer())
						),
						conditional( //"if([E] = object()) then ([E++] = object())",
							subtyp(typeOf(operand@at), \object()),
							subtyp(typeOf(expr@at), \object())
						),
						conditional( //"if([E] = resource()) then ([E++] = resource())",
							eq(typeOf(operand@at), resource()),
							eq(typeOf(expr@at), resource())
						),
						conditional( //"if([E] = string()) then (or([E++] = float(), [E++] = int(), [E++] = string())",
							eq(typeOf(operand@at), \string()),
							disjunction({eq(typeOf(expr@at), \float()), eq(typeOf(expr@at), integer()), eq(typeOf(expr@at), \string())})
						)
					};
										
				case preDec():
					constraints += {
						conditional( //"if([E] = array(any())) then ([E--] = array(any()))",
							subtyp(typeOf(operand@at), array(\any())),
							subtyp(typeOf(expr@at), array(\any()))
						),
						conditional( //"if([E] = bool()) then ([E--] = bool())",
							eq(typeOf(operand@at), boolean()),
							eq(typeOf(expr@at), boolean())
						),
						conditional( //"if([E] = float()) then ([E--] = float())",
							eq(typeOf(operand@at), float()),
							eq(typeOf(expr@at), float())
						),
						conditional( //"if([E] = int()) then ([E--] = int())",
							eq(typeOf(operand@at), integer()),
							eq(typeOf(expr@at), integer())
						),
						conditional( //"if([E] = null()) then (or([E--] = null(), [E++] = int()))",
							eq(typeOf(operand@at), null()),
							eq(typeOf(expr@at), integer())
						),
						conditional( //"if([E] = object()) then ([E--] = object())",
							subtyp(typeOf(operand@at), \object()),
							subtyp(typeOf(expr@at), \object())
						),
						conditional( //"if([E] = resource()) then ([E--] = resource())",
							eq(typeOf(operand@at), resource()),
							eq(typeOf(expr@at), resource())
						),
						conditional( //"if([E] = string()) then (or([E--] = float(), [E--] = int(), [E--] = string())",
							eq(typeOf(operand@at), \string()),
							disjunction({eq(typeOf(expr@at), \float()), eq(typeOf(expr@at), integer()), eq(typeOf(expr@at), \string())})
						)
					};
			}
		
		}
		
		case n:new(NameOrExpr className, list[ActualParameter] parameters): {
			if (name(nameNode:name(_)) := className) {
				// literal class instantiation
				constraints += { eq(typeOf(n@at), class(u)) | u <- m3@uses[nameNode@at] };
			} else {
				// variable class instantiation:
				addConstraints(className.expr, m3);	
				constraints += { subtyp(typeOf(n@at), object()) };
			}	
			// todo: parameters
		}
		
		case c:cast(CastType castType, Expr expr): {
			addConstraints(expr, m3);	
			
			switch(castType) {
				case \int() :	constraints += { eq(typeOf(c@at), integer()) };
				case \bool() :	constraints += { eq(typeOf(c@at), boolean()) };
				case float() :	constraints += { eq(typeOf(c@at), float()) };
				case array() :	constraints += { subtyp(typeOf(c@at), array(\any())) };
				case object() :	constraints += { subtyp(typeOf(c@at), object()) };
				case unset():	constraints += { eq(typeOf(c@at), null()) };
				
				// special case for string, when [expr] <: object, the class of the object needs to have method "__toString"
				case string() :	
					constraints += { 
						eq(typeOf(c@at), string()),
						conditional(
							subtyp(typeOf(expr@at), object()),
							hasMethod(typeOf(expr@at), "__tostring")
						)
					};
			}
		}
		
		case c:clone(Expr expr): {
			addConstraints(expr, m3);	
			// expression and result are of type clone
			constraints += { subtyp(typeOf(expr@at), object()) };	
			constraints += { subtyp(typeOf(c@at), object()) };	
		}
		
	
		case fc:fetchConst(name(name)): {
			if (/true/i := name || /false/i := name) {
				constraints += { eq(typeOf(fc@at), boolean()) };
			} else if (/null/i := name) {
				constraints += { eq(typeOf(fc@at), null()) };
			} else if (name in predefinedConstants) {
				constraints += { eq(typeOf(fc@at), predefinedConstants[name]) };
			} else {
				constraints += { subtyp(typeOf(fc@at), \any()) };
			}
		}
		
		// ternary: E1?E2:E3 == E => [E] = [E2] V [E3]
		case t:ternary(Expr cond, someExpr(Expr ifBranch), Expr elseBranch): {
			addConstraints(cond, m3);
			addConstraints(ifBranch, m3);
			addConstraints(elseBranch, m3);
			constraints += { 
				disjunction({
					subtyp(typeOf(t@at), typeOf(ifBranch@at)),
					subtyp(typeOf(t@at), typeOf(elseBranch@at))
				})
			};
		}
		// ternary: E1?:E3 == E => [E] = [E1] V [E3]
		case t:ternary(Expr cond, noExpr(), Expr elseBranch): {
			addConstraints(cond, m3);
			addConstraints(elseBranch, m3);
			constraints += { 
				disjunction({
					subtyp(typeOf(t@at), typeOf(cond@at)),
					subtyp(typeOf(t@at), typeOf(elseBranch@at))
				})
			};
		}
		
		//scalar(Scalar scalarVal)
		case s:scalar(Scalar scalarVal): {
			switch(scalarVal) {
				case classConstant():		constraints += { eq(typeOf(s@at), string()) };
				case dirConstant():			constraints += { eq(typeOf(s@at), string()) };
				case fileConstant():		constraints += { eq(typeOf(s@at), string()) };
				case funcConstant():		constraints += { eq(typeOf(s@at), string()) };
				case lineConstant():		constraints += { eq(typeOf(s@at), integer()) };
				case methodConstant():		constraints += { eq(typeOf(s@at), string()) };
				case namespaceConstant():	constraints += { eq(typeOf(s@at), string()) };
				case traitConstant():		constraints += { eq(typeOf(s@at), string()) };
				
				case float(_):				constraints += { eq(typeOf(s@at), float()) };
				case integer(_):			constraints += { eq(typeOf(s@at), integer()) };
				case string(_):				constraints += { eq(typeOf(s@at), string()) };
				case encapsed(list[Expr] parts): {
					for (p <- parts, scalar(_) !:= p) addConstraints(p, m3);
					constraints += { eq(typeOf(s@at), string()) };
				}
			}
		}
		
		// normal variable and variable variable (can be combined)
		case v:var(name(name(name))): {
			if (name in predefinedVariables) {
				if (array(\any()) := predefinedVariables[name]) {
					constraints += { subtyp(typeOf(v@at), predefinedVariables[name]) };
				} else {
					constraints += { eq(typeOf(v@at), predefinedVariables[name]) };
				}
			} else {
				constraints += { subtyp(typeOf(v@at), \any()) };
			}
		}
		case v:var(expr(e)): { constraints += { subtyp(typeOf(v@at), \any()) }; }
		
		case c:call(NameOrExpr funName, list[ActualParameter] parameters): {
			if (name(Name name) := funName) {
				// literal name is resolved in uses and can be found in @uses
				// get all locations for the function decl
				constraints += { subtyp(typeOf(c@at), typeOf(funcDecl)) | funcDecl <- (m3@uses o m3@declarations)[name@at] };
			} else if (expr(Expr expr) := funName) {
				// method call on an expression:
				// type of this expression is either a string, or an object with the method __invoke()
				addConstraintsForCallableExpression(expr);
				constraints += { subtyp(typeOf(c@at), \any()) };
			}
			// todo: params
		}
	
	//| fetchClassConst(NameOrExpr className, Name constantName)
	
	//| propertyFetch(Expr target, NameOrExpr propertyName)
	//| staticPropertyFetch(NameOrExpr className, NameOrExpr propertyName)
	
	//| methodCall(Expr target, NameOrExpr methodName, list[ActualParameter] parameters)
	case sc:staticCall(NameOrExpr staticTarget, NameOrExpr methodName, list[ActualParameter] parameters): {
		// handle class names
		constraints += { subtyp(typeOf(staticTarget@at), object()) };
		
		bool inClass = inClassOrInterface(m3@containment, sc@scope);
		set[Constraint] inClassConstraints = {};
	
		// first add constraints for when this call is performed from within a class
		if (inClass) {		
			loc currentClass = getClassOrInterface(m3@containment, sc@scope);
			set[loc] parentClasses = range(domainR(m3@extends+, {currentClass}));
		
			switch (staticTarget) // borrowed this structure of Uses.rsc
			{
				// refers to the class itself
				case name(name(/self/i)): 
				{
					constraints += { eq(typeOf(staticTarget@at), class(currentClass)) };
				}
				
				// refers to all parents
				case name(name(/parent/i)): 
				{	
					constraints += {
						disjunction({
							eq(typeOf(staticTarget@at), class(p)) | p <- parentClasses
						})
					};
		       	}
		       	 
				// refers to the instance 
				case name(name(/static/i)): 
				{
					constraints += {
						disjunction({
							eq(typeOf(staticTarget@at), class(p)) | p <- {currentClass} + parentClasses
						})
					};
				}
				
				// staticTarget is a literal name
				case name(lhsName): 
				{
					// when called from within a class add:
					// - [E1] = this class hasMethod(E2.name, !static)
					// - [E1] = parent class hasMethod(E2.name, (public or protected) AND !static) 
					
					// RHS == literal string
					if (name(rhsName) := methodName) {
						inClassConstraints += {
							conditional( // if LHS is same as the current class,
								eq(typeOf(staticTarget@at), class(currentClass)),
								hasProperty(typeOf(staticTarget@at), rhsName.name, { notAllowed(static()) })
							);	
						}
					}
				}
				
				case expr(expr): // staticTarget is an expression, resolve to all classes 
				{
					;
				}
			}
		}			

		switch (staticTarget) // borrowed this structure of Uses.rsc
		{
			case name(name): 
			{
				// staticTarget is a literal name, which means that we can directly add the class
				constraints += { subtyp(typeOf(staticTarget@at), typeOf(classLoc)) | classLoc <- (m3@uses o m3@declarations)[staticTarget@at] };
				
				// PRECONDITION: RHS = literal name, add if statement
				if (name(rhsName) := methodName) {
					// methodName resolves to the method itself...
					constraints += { isMethodName(typeOf(methodName@at), rhsName.name) };
					// type of whole expression is the return type of the invoked method;
					constraints += { subtyp(typeOf(sc@at), typeOf(methodName@at)) };
					
				;
					//if (inClass) {
						//set[Constraint] inClassConstraints = {};
					//}
					// rules:
					// - [E1] = this class hasMethod(E2.name, !static)
					// - [E1] = parent class hasMethod(E2.name, (public or protected) AND !static) 
					// - [E1] = any class hasMethod(E2.name, public AND !static)
					
					//constraints += {
					//	disjunction({
					//		hasMethod(typeOf(staticTarget@at), rhsName.name, { required({ static() }) })
					//		//,
					//		//parentHas(hasMethod(typeOf(staticTarget@at), name.name, { required({ static() }) }))
					//	})
					//};
				} else {
					println("Variable call not supported (yet), please implement!!");	
				}
				
				//public data Modifier = \public() | \private() | protected() | static() | abstract() | final();
			}
			
			case expr(expr): // staticTarget is an expression, resolve to all classes 
			{
				addConstraints(expr, m3);
				constraints += { subtyp(typeOf(expr@at), object()); };
				// todo
				//m3@uses += { <staticTarget@at, t> | t <- classes(m3) + interfaces(m3) };
			}
		}
		//if (name(name) := staticTarget) {
		//	println(m3@uses[name@at]);
		//}
		//println(m3@uses[methodName@at]);
		//constraints += { subtyp(typeOf(sc@at), typeOf(funcDecl)) | funcDecl <- m3@uses[name@at] };
			
		;
	}

	//
	// Not supported:
	//
	// closure(list[Stmt] statements, list[Param] params, list[ClosureUse] closureUses, bool byRef, bool static)
	// yield(OptionExpr keyExpr, OptionExpr valueExpr)
	// eval(Expr expr)
	// include(Expr expr, IncludeType includeType)
	
	//
	// Not implemented (yet):
	//	
	//| listAssign(list[OptionExpr] assignsTo, Expr assignExpr)
	//| refAssign(Expr assignTo, Expr assignExpr)
	//| listExpr(list[OptionExpr] listExprs
	//| empty(Expr expr)
	//| suppress(Expr expr)
	//| exit(OptionExpr exitExpr)
	//| instanceOf(Expr expr, NameOrExpr toCompare)
	//| isSet(list[Expr] exprs)
	//| print(Expr expr)
	//| shellExec(list[Expr] parts)
	
	}
}

public void addConstraintsOnAllVarsWithinScope(&T <: node t) 
{
	// get all vars that have @decl annotations (which means that they are writable vars)
	constraints += { eq(typeOf(v@decl), typeOf(v@at)) | /v:var(_) <- t, v@decl? && v@scope == t@decl };
}

public void addConstraintsOnAllReturnStatementsWithinScope(&T <: node t) 
{
	// get all return statements within a certain scope
	set[OptionExpr] returnStmts = { expr | /\return(expr) <- t, expr@scope == t@decl };
	
	if (!isEmpty(returnStmts)) {
		// if there are return statements, the disjunction of them is the return value of the function
		constraints += { 
			disjunction(
				{ eq(typeOf(t@at), typeOf(e@at)) | rs <- returnStmts, someExpr(e) := rs }
				+ { eq(typeOf(t@at), null()) | rs <- returnStmts, noExpr() := rs }
			)};
	} else {
		// no return methods means that the function will always return null (unless an expception is thrown)
		constraints += { eq(typeOf(t@at), null()) }; 
	}
}

public void addDeclarationConstraint(&T <: node t)
{
	// instead of adding these constraints we can add all declarations...
	// constraints += { eq(typeOf(t@decl), typeOf(t@at)) };
}

public void addConstraintsForCallableExpression(Expr expr)
{
	constraints += {
		disjunction({
			eq(typeOf(expr@at), string()),
			subtyp(typeOf(expr@at), object())
		}),
		conditional(
			subtyp(typeOf(expr@at), object()),
			hasMethod(typeOf(expr@at), "__invoke")
		)
	};
}