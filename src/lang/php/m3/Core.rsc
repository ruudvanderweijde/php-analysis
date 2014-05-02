@doc{
Synopsis: extends the M3 [$analysis/m3/Core] with Php specific concepts 

Description: 

For a quick start, go find [createM3FromEclipseProject].
}
module lang::php::m3::Core
extend analysis::m3::Core;

import lang::php::m3::AST;

import analysis::graphs::Graph;
import analysis::m3::Registry;

import lang::php::ast::AbstractSyntax;
import lang::php::ast::System;
import lang::php::util::Config;
import lang::php::util::Utils;

import Prelude;

alias M3Collection = map[loc fileloc, M3 model];

anno rel[loc from, loc to] M3@extends;      // classes extending classes and interfaces extending interfaces
anno rel[loc from, loc to] M3@implements;   // classes implementing interfaces
// suggestion: rename to traitUses
anno rel[loc from, loc to] M3@usesTrait;    // classes using traits and traits using traits
anno rel[loc from, loc to] M3@aliases;      // class name aliases (new name -> old name)
anno rel[loc pos, str phpDoc] M3@phpDoc;    // Multiline php comments /** ... */

alias M3Collection = map[loc fileloc, M3 model];

public loc globalNamespace = |php+namespace:///|;

public M3 composePhpM3(loc id, set[M3] models) {
  m = composeM3(id, models);
  
  m@extends 	= {*model@extends       | model <- models};
  m@implements 	= {*model@implements    | model <- models};
  m@usesTrait 	= {*model@usesTrait 	| model <- models};
  m@aliases 	= {*model@aliases	 	| model <- models};
  m@phpDoc 		= {*model@phpDoc 		| model <- models};
  
  return m;
}

public M3 createEmptyM3(loc file) = composePhpM3(file, {});

public bool isNamespace(loc entity) = entity.scheme == "php+namespace";
public bool isClass(loc entity) = entity.scheme == "php+class";
public bool isInterface(loc entity) = entity.scheme == "php+interface";
public bool isTrait(loc entity) = entity.scheme == "php+trait";
public bool isMethod(loc entity) = entity.scheme == "php+method";
public bool isFunction(loc entity) = entity.scheme == "php+function";
public bool isParameter(loc entity) = entity.scheme == "php+functionParam" || entity.scheme == "php+methodParam";
public bool isVariable(loc entity) = entity.scheme == "php+globalVar" || entity.scheme == "php+functionVar" || entity.scheme == "php+methodVar";
public bool isField(loc entity) = entity.scheme == "php+field";
public bool isConstant(loc entity) = entity.scheme == "php+constant";
public bool isClassConstant(loc entity) = entity.scheme == "php+classConstant";

@memo public set[loc] namespaces(M3 m) = {e | e <- m@declarations<name>, isNamespace(e)};
@memo public set[loc] classes(M3 m) =  {e | e <- m@declarations<name>, isClass(e)};
@memo public set[loc] interfaces(M3 m) =  {e | e <- m@declarations<name>, isInterface(e)};
@memo public set[loc] traits(M3 m) = {e | e <- m@declarations<name>, isTrait(e)};
@memo public set[loc] functions(M3 m)  = {e | e <- m@declarations<name>, isFunction(e)};
@memo public set[loc] variables(M3 m) = {e | e <- m@declarations<name>, isVariable(e)};
@memo public set[loc] methods(M3 m) = {e | e <- m@declarations<name>, isMethod(e)};
@memo public set[loc] parameters(M3 m)  = {e | e <- m@declarations<name>, isParameter(e)};
@memo public set[loc] fields(M3 m) = {e | e <- m@declarations<name>, isField(e)};
@memo public set[loc] constants(M3 m) =  {e | e <- m@declarations<name>, isconstant(e)};
@memo public set[loc] classConstants(M3 m) =  {e | e <- m@declarations<name>, isClassConstant(e)};

public set[loc] elements(M3 m, loc parent) = { e | <parent, e> <- m@containment };

@memo public set[loc] fields(M3 m, loc class) = { e | e <- elements(m, class), isField(e) };
@memo public set[loc] methods(M3 m, loc class) = { e | e <- elements(m, class), isMethod(e) };


public str normalizeName(str phpName, str \type)
{
	str name = replaceAll(phpName, "\\", "/");

	if (\type in ["namespace", "class", "interface", "trait"])
	{
		name = toLowerCase(name);
	}
	
	return name;
}


public loc nameToLoc(str phpName, str \type)
{
	str name = normalizeName(phpName, \type);

	if (/^\/.*$/ !:= name)
	{
		name = "/" + name;
	}
	return |php+<\type>://<name>|;
}


public loc addNameToNamespace(str phpName, str \type, loc namespace)
{
	str name = normalizeName(phpName, \type);

	return |php+<\type>://<namespace.path>/<name>|;
}
