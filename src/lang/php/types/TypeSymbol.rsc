module lang::php::types::TypeSymbol
extend analysis::m3::TypeSymbol;

// type `mixed()` is omitted, `\any()` will be used

data TypeSymbol
  = arrayType(TypeSymbol arrayType) // array of type X, can be nested
  | booleanType()					// boolean value
  | callableType()					// (name of) method or function
  | classType(loc decl)				// a specific class
  | floatType()						// float, double or real
  | integerType()					// integer numbers
  | interfaceType(loc decl)			// a specific interface
  | numberType()					// a float or integer
  | nullType()						// empty or undefined value
  | objectType()					// any class type
  | resourceType()					// a build-in type
  | scalarType()					// any number, string, resource or 
  | stringType()					// text values
  ; 
 
//default bool subtyp(TypeSymbol s, TypeSymbol t) = s == t;

//default TypeSymbol lub(TypeSymbol s, TypeSymbol t) = s == t ? s : \any();

public set[TypeSymbol] allTypes = {  arrayType(\any()), booleanType(), floatType(), integerType(), nullType(), objectType(), resourceType(), stringType() }; 
