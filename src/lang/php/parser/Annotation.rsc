module lang::php::parser::Annotation

// Due to the inconsistent nature of the docblocks, I will use regex to find annotations

import lang::php::ast::AbstractSyntax;
import lang::php::m3::Core;
import lang::php::m3::Containment;
import lang::php::types::TypeSymbol;

import IO;
import List;
import Relation;
import Set;
import String;

// The parsing of @param is performed as follows:
//
// If      `@param ___ $___` is found, only try to match this structure
// Then if `@param $___ ___` is found, only try to match this structure
// Then if `@param ___` is found, only try to match this structure
//
// This means that mixing up different styles within one code block can lead to partly results.
//
// Note: This file needs some reformatting...
//
public M3 addAnnotationsForNode(&T <: node relatedNode, M3 m3)
{
	str phpdoc = relatedNode@phpdoc;
	
	m3@annotations += parseAnnotations(phpdoc, relatedNode, m3);
	
	return m3;
}

private rel[loc decl, Annotation annotation] parseAnnotations(str input, &T <: node relatedNode, M3 m3)
{
	rel[loc decl, Annotation annotation] annotations = {};

	// for methods and functions:
	// read @param type $paramName
	// read @return type
	if (method(_,_,_,list[Param] params,_) := relatedNode || function(_,_,list[Param] params,_) := relatedNode) {
		// read @param annotation
		annotations += getParamAnnotations(input, relatedNode, m3, params);
			
		// return type should always look like: @return types
		if (/@return\s+<types:[^\s]+>/ := input) {
			annotations = { <relatedNode@decl, returnType(parseTypes(types, relatedNode, m3))> };
		}
		
	} else {
		// read @(var|type) annotations for var(_) and property(_,_)
		 
		if (var(_) := relatedNode || property(_,_) := relatedNode) {
			annotations += getVarAnnotations(input, relatedNode, m3);
		} elseif (ClassDef := relatedNode) {
			; // ignore class annotations
		} else {
			throw "Annotation on unsupported node :: <relatedNode>";	
		}
	}	
	
	
	return annotations;	
}

private rel[loc decl, Annotation annotation] getParamAnnotations(str input, &T <: node relatedNode, M3 m3, list[Param] params) {
	rel[loc decl, Annotation annotation] annotations = {};
	
	// Only read one of the 3 variation of the @param annotation:
	
	// #1 match `@param type $var` 
	if (/@param\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
		for (/@param\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
			if (/p:param(varName,_,_,_) := params) {
				annotations += { <p@decl, parameterType(parseTypes(types, relatedNode, m3))> };
			}
		}
		
	// #2 match `@param $var type` 
	} elseif (/@param\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
		for (/@param\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
			if (/p:param(varName,_,_,_) := params) {
				annotations += { <p@decl, parameterType(parseTypes(types, relatedNode, m3))> };
			}
		}
		
	// #3 match `@param type` 
	} elseif (/@param\s+<types:[^\$\s]+><varName:>/i := input) {
		// no parameter names are provided. Use an iterator to determain the type of the parameters
		// for instance, method `method($first, $second, $third)` and annotations matches:
		// @param int		// $first.decl = int
		// @param string	// $second.decl = string
		//					// $third will be ignored
		// 
		for (/@param\s+<types:[^\$\s]+><varName:>/i := input) {
			if (!isEmpty(params)) {
				<p,params> = pop(params);
				annotations += { <p@decl, parameterType(parseTypes(types, relatedNode, m3))> };
			}
		}
	}
	
	return annotations;
}

private rel[loc decl, Annotation annotation] getVarAnnotations(str input, &T <: node relatedNode, M3 m3) 
{
		//if (var(_) := relatedNode || property(_,_)) {
		//	annotations += getVarAnnotations(input, relatedNode, m3);
		//	// somehow: var(name(name(str name))) is not allowed...
		//	if (v.name? && v.name.name?) 
		//		annotations += getVarAnnotations(input, v@decl, v.name.name, relatedNode, m3);
		//} elseif (property(_, list[Property] ps) := relatedNode) {
		//	for (p:property(name,_) <- ps) {
		//		annotations += getVarAnnotations(input, p@decl, name, relatedNode, m3);
		//	}		
		//} elseif (ClassDef := relatedNode) {
		//	; // ignore class annotations
		//} else {
		//	throw "Annotation on unsupported node :: <relatedNode>";	
		//}
	rel[loc decl, Annotation annotation] annotations = {};
	
	 //#1 match `@(var|type) type $var` 
	if (/@(var|type)\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
		if (v:var(name:name(name(_))) := relatedNode) { // var(name(name(str name))) results in: Expected Expr, but got ClassItem
			// relatedNode is a variable
			if (/@(var|type)\s+<types:[^\$\s]+>\s+\$<varName>/i := input) {
				annotations += { <v@decl, varType(parseTypes(types, relatedNode, m3))> };
			}
		} elseif (property(_,list[Property] ps) := relatedNode) {
			// Try to match the fields with the name
			for (/@(var|type)\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
				if (/p:Property::property(varName,_) := ps) {
					annotations += { <p@decl, varType(parseTypes(types, relatedNode, m3))> };
				}
			}
		}
			//iprintln(annotations);
		
	// #2 match `@(var|type) $var type` 
	} elseif (/@(var|type)\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
		if (v:var(_) := relatedNode && v.name? && v.name.name?) { // var(name(name(str name))) results in: Expected Expr, but got ClassItem
			// relatedNode is a variable
			if (/@(var|type)\s+<types:[^\$\s]+>\s+\$<varName>/i := input) {
				annotations += { <v@decl, varType(parseTypes(types, relatedNode, m3))> };
			}
		} elseif (property(_,list[Property] ps) := relatedNode) {
			// Try to match the fields with the name
			for (/@(var|type)\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
				if (/p:Property::property(varName,_) := ps) {
					annotations += { <p@decl, varType(parseTypes(types, relatedNode, m3))> };
				}
			}
		}
		
	// #3 match `@(var|type) type` 
	} elseif (/@(var|type)\s+<types:[^\$\s]+>/i := input) {
		if (v:var(_) := relatedNode && v.name? && v.name.name?) { // var(name(name(str name))) results in: Expected Expr, but got ClassItem
			// relatedNode is a variable
			annotations += { <v@decl, varType(parseTypes(types, relatedNode, m3))> };
		} elseif (property(_,list[Property] ps) := relatedNode) {
			// Iterate over the class fields
			for (/@(var|type)\s+<types:[^\$\s]+><varName:>/i := input) {
				if (!isEmpty(ps)) {
					<p,ps> = pop(ps);
					annotations += { <p@decl, varType(parseTypes(types, relatedNode, m3))> };
				}
			}
		}
	}
	
	return annotations;
}

private set[TypeSymbol] parseTypes(str typeString, &T <: node relatedNode, M3 m3) {
	set[TypeSymbol] types = {};
	
	for (part <- split("|", typeString)) {
		types += parseType(part, relatedNode, m3);
	}
	
	return types;
}

private set[TypeSymbol] parseType(str typeString, &T <: node relatedNode, M3 m3) {
	set[TypeSymbol] typeSymbol = {};

	// check if we have an array type
	if (/\[\]$/ := typeString) {
		// syntax: T[]
		typeSymbol = { arrayType(t) | t <- parseTypeRaw(typeString[..-2], relatedNode, m3) };
	} else if (/^array\<<t:.*>\>$/ := typeString) {
		// syntax: array<T>
		typeSymbol = { arrayType(aType) | aType <- parseTypeRaw(t, relatedNode, m3) };
	} else {
		// other cases
		typeSymbol = parseTypeRaw(typeString, relatedNode, m3);
	}
	
	return typeSymbol;	
}	

private set[TypeSymbol] parseTypeRaw(str typeString, &T <: node relatedNode, M3 m3) {
	set[TypeSymbol] typeSymbol = {};

	// if type ends with '()', remove '()'
	if (/\(\)$/ := typeString) {
		typeString = typeString[..-2];
	}
	
	// check predefined types
	switch (typeString) {
		case /^(mixed|\*)$/i:
			typeSymbol = { \any() };
		
		case /^array$/i: 
			typeSymbol = { arrayType(\any()) };
			
		case /^(bool|boolean)$/i: 
			typeSymbol = { booleanType() };
			
		case /^(double|float|real)$/i:
			typeSymbol = { floatType() };
			
		case /^(int|integer)$/i:
			typeSymbol = { integerType() };
			
		case /^(null|void)$/i:
			typeSymbol = { nullType() };
			
		case /^object$/i:
			typeSymbol = { objectType() };
			
		case /^resource$/i:
			typeSymbol = { resourceType() };
			
		case /^string$/i:
			typeSymbol = { stringType() };
			
		case /^callable$/i:
			typeSymbol = { callableType() };
			
		case /^(self|\$this)$/i:
			typeSymbol = { classType(getClassTraitOrInterface(m3@containment, relatedNode@scope)) };
			
		case /^(static|parent)$/i:
			typeSymbol = { objectType() }; 
			
		case /^<name:[a-zA-Z]+>$/i: {
			if (!isEmpty(m3@uses[|php+class:///<name>|])) {
				pritnln(m3@uses); 	
				throw "implement me";
			} else if (!isEmpty(m3@uses[|php+interface:///<name>|])) {
				pritnln(m3@uses); 	
				throw "implement me";
			} else {
				typeSymbol = { classType(|php+<\type>:///<name>|) | \type <- ["class", "interface"] };
			}
		}
	}
	
	return typeSymbol;
}