module lang::php::parser::Annotation

// Due to the inconsistent nature of the docblocks, I will use regex to find annotations

import lang::php::ast::AbstractSyntax;
import lang::php::m3::Core;
import lang::php::m3::Containment;
import lang::php::types::TypeSymbol;

import List;
import Relation;
import Set;
import String;

public M3 addAnnotationsForNode(&T <: node relatedNode, M3 m3)
{
	str phpdoc = relatedNode@phpdoc;
	
	return parseAnnotations(phpdoc, relatedNode, m3);
}

private rel[loc decl, Annotation annotation] parseAnnotations(str input, &T <: node relatedNode, M3 m3)
{
	rel[loc decl, Annotation annotation] annotations = {};

	println("entering parseAnnotations with str: <input>");	
	println("entering parseAnnotations with relatedNode: <relatedNode>");	
	// for methods and functions:
	// read @param type $paramName
	// read @return type
	if (n:method(_,_,_,list[Param] params,_) := relatedNode || n:function(_,_,list[Param] params,_) := relatedNode) {
	
		// Only read one of the 3 variation of the @param annotation:
		
		// #1 match `@param type $var` 
		if (/@param\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
			for (/@param\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
				if (/p:param(varName,_,_,_) := params) {
					annotations += { <p@decl, parameterType(parseTypes(types))> };
				}
			}
			
		// #2 match `@param $var type` 
		} elseif (/@param\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
			for (/@param\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
				if (/p:param(varName,_,_,_) := params) {
					annotations += { <p@decl, parameterType(parseTypes(types))> };
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
					annotations += { <p@decl, parameterType(parseTypes(types))> };
				}
			}
		}
		
		// return type should always look like: @return types
		if (/@return\s+<types:[^\s]+>/ := input) {
			annotations = { <n@decl, returnType(parseTypes(types))> };
		}
		
	} else {
		// for all nodes:	
		// read @var types $varName
		// read @type types $varName
		
		// #1 match `@(var|type) type $var` 
		if (/@(var|type)\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
			for (/@(var|type)\s+<types:[^\$\s]+>\s+\$<varName:[^\s]+>/i := input) {
				println("Matches #1:");
				println(types);
				println(varName);
				//if (/p:param(varName,_,_,_) := params) {
				//	annotations += { <p@decl, parameterType(parseTypes(types))> };
				//}
			}
			
		// #2 match `@(var|type) $var type` 
		} elseif (/@(var|type)\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
			for (/@(var|type)\s+\$<varName:[^\s]+>\s+<types:[^\$\s]+>/m := input) {
				println("Matches #2:");
				println(types);
				println(varName);
				//if (/p:param(varName,_,_,_) := params) {
				//	annotations += { <p@decl, parameterType(parseTypes(types))> };
				//}
			}
			
		// #3 match `@param type` 
		} elseif (/@(var|type)\s+<types:[^\$\s]+><varName:>/i := input) {
				println("Matches #3:");
				println(types);
				println(varName);
			// no parameter names are provided. Use an iterator to determain the type of the parameters
			// for instance, method `method($first, $second, $third)` and annotations matches:
			// @param int		// $first.decl = int
			// @param string	// $second.decl = string
			//					// $third will be ignored
			// 
			//for (/@param\s+<types:[^\$\s]+><varName:>/i := input) {
			//	if (!isEmpty(params)) {
			//		<p,params> = pop(params);
			//		annotations += { <p@decl, parameterType(parseTypes(types))> };
			//	}
			//}
		}
	
        //if (preg_match_all('/@var\s+\$([^\s]+)\s+([^\s]+)/i', $doc, $matches)) {
        //;
        //}
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
			typeSymbol = { arrayType() };
			
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
			typeSymbol = { class(c) | c <- getClassTraitOrInterface(m3@containment, relatedNode@scope) };
			
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