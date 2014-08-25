module tests::lang::php::parser::AnnotationTest
extend lang::php::parser::Annotation;

import IO;
import Node;
import Set;
import ValueIO;

// use these decls in the tests
private loc methodDecl = |php+method:///cl/name|;
private loc paramDecl = |php+methodParam:///cl/name/param1|;
private loc paramDecl1 = |php+methodParam:///cl/name/param1|;
private loc paramDecl2 = |php+methodParam:///cl/name/param2|;
private loc propDecl = |php+field:///cl/name/param1|;

private rel[str literalType, TypeSymbol typeSymbol] phpTypes = 
{
	<"array", arrayType()>,
	<"mixed", \any()>, 
	<"bool", booleanType()>, 
	<"booL", booleanType()>, 
	<"boolean", booleanType()>, 
	<"Boolean", booleanType()>, 
	<"int", integerType()>, 
	<"integer", integerType()>, 
	<"float", floatType()>, 
	<"double", floatType()>, 
	<"real", floatType()>, 
	<"string", stringType()>, 
	<"resource", resourceType()>
};
private rel[str literalType, set[TypeSymbol] typeSymbols] otherTypes = 
{
	<"callable", { callableType() }>, 
	//<"self", { classType(|php+class:///T|) }>, 
	<"static", { objectType() }>, 
	//<"$this", { classType(|php+class:///T|) }>, 
	<"void", { nullType() }>,
	<"array\<T\>", { arrayType(classType(|php+class:///T|)), arrayType(classType(|php+interface:///T|)) }>,
	<"T[]", { arrayType(classType(|php+class:///T|)), arrayType(classType(|php+interface:///T|)) }>
};
private list[str] variables = [ "$var", "$object", "$OBJ", "$_OBJ", "$_OBJ_o", "$_OBJ_ÿ", "$_{$O_ÿ}", "$a_b_c", "$randomName" ];
private list[str] classNames = [ "C", "ClassName", "Object" , "OldStyleClasses", "Old_Style_Classes", "class_lowercased", "\\ClassName", "\\Package\\ClassName", "\\Package\\SubPackage\\ClassName" ];
private list[str] descriptions = [ "var", "object", "OBJ", "_OBJ", "_OBJ_o", "_OBJ_ÿ", "_{$OB_ÿ}", "$var", "a_b_c", "random text", " random text ", "This is some random comment", "  This is some random comment  " ];

public void main() {
	// run tests
	assertOneType();
	assertMultipleTypes();
	asssertReturnAnnotation();
	assertParamAnnotation();
	assertVarAnnotation();
}

// test single types, like: string, int, double, callable, int[]
public void assertOneType() 
{
	// test predifined php types
    for (phpType <- phpTypes) {
	    assert parseTypes(phpType.literalType) == { phpType.typeSymbol } 
	    	: "Failed to parse phpType: <phpType> (result: <parseTypes(phpType.literalType)>)";
    }
    
	// test predifined php types with postfix () and []
    for (phpType <- phpTypes) {
	    assert parseTypes(phpType.literalType + "()") == { phpType.typeSymbol } 
	    	: "Failed to parse phpType: <phpType> (result: <parseTypes(phpType.literalType)>)";
	    assert parseTypes(phpType.literalType + "[]") == { arrayType(phpType.typeSymbol) } 
	    	: "Failed to parse phpType: <phpType> (result: <parseTypes(phpType.literalType)>)";
    }

	// test other types
    for (phpType <- otherTypes) {
	    assert parseTypes(phpType.literalType) == phpType.typeSymbols 
	    	: "Failed to parse phpType: <phpType> (result: <parseTypes(phpType.literalType)>)";
    }
}

// test multiple types, devided by `|`: like: int|string, SomeClass|null
public void assertMultipleTypes()
{
	// concat type1|type2
    for (phpType1 <- phpTypes, phpType2 <- phpTypes) {
    	str typeStr = phpType1.literalType + "|" + phpType2.literalType;
    	set[TypeSymbol] expectedTypes = { phpType1.typeSymbol, phpType2.typeSymbol };
    	
	    assert parseTypes(typeStr) == expectedTypes 
	    	: "Failed to parse phpType: <phpType1> and <phpType2> \ninput: `<typeStr>` expected: `<expectedTypes>` result: `<parseTypes(typeStr)>`)";
    }
}

// test @return 
public void asssertReturnAnnotation()
{
	// match `@return type` in the phpdoc
    for (phpType <- phpTypes) {
	    assert parseMethodAnnotationsOneParam("@return " + phpType.literalType) == { <methodDecl, returnType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> 
	    	result: <parseMethodAnnotationsOneParam("@return " + phpType.literalType)>)";
    }
}

// test @param
public void assertParamAnnotation()
{
	// #1 match `@param type $var` 
	// #2 match `@param $var type` 
	// #3 match `@param type` 
    for (phpType <- phpTypes) 
    {
		// #1 match `@param type $var` 
		str test1 = "@param " + phpType.literalType + " $param1";
	    assert parseMethodAnnotationsOneParam(test1) == { <paramDecl, parameterType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parseMethodAnnotationsOneParam(test1)>)";
	    	
		// #2 match `@param $var type` 
		str test2 = "@param $param1 " + phpType.literalType;
	    assert parseMethodAnnotationsOneParam(test2) == { <paramDecl, parameterType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parseMethodAnnotationsOneParam(test2)>)";
	    	
		// #3 match `@param type` 
		str test3 = "@param " + phpType.literalType;
	    assert parseMethodAnnotationsOneParam(test3) == { <paramDecl, parameterType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parseMethodAnnotationsOneParam(test3)>)";
	}	    	

    // Node with two params:
    for (phpType1 <- phpTypes, phpType2 <- phpTypes) 
    {
		// #1 match `@param type $var` 
		str test1 = "@param " + phpType1.literalType + " $param1 description" + "\n" + "@param " + phpType2.literalType + " $param2";
	    assert parseMethodAnnotationsTwoParams(test1) == { 
	    	<paramDecl1, parameterType({ phpType1.typeSymbol })>,
	    	<paramDecl2, parameterType({ phpType2.typeSymbol })> 
	    } : "Failed to parse phpType: `<phpType1>` && `<phpType2>` (result: <parseMethodAnnotationsTwoParams(test1)>)";
	    
		// #2 match `@param $var type` 
		str test2 = "@param $param1 " + phpType1.literalType + " description" + "\n" + "@param $param2 " + phpType2.literalType;
	    assert parseMethodAnnotationsTwoParams(test2) == { 
	    	<paramDecl1, parameterType({ phpType1.typeSymbol })>,
	    	<paramDecl2, parameterType({ phpType2.typeSymbol })> 
	    } : "Failed to parse phpType: `<phpType1>` && `<phpType2>` (result: <parseMethodAnnotationsTwoParams(test2)>)";
	    	
		// #3 match `@param type` 
		str test3 = "@param " + phpType1.literalType + " description" + "\n" + "@param " + phpType2.literalType;
	    assert parseMethodAnnotationsTwoParams(test3) == { 
	    	<paramDecl1, parameterType({ phpType1.typeSymbol })>,
	    	<paramDecl2, parameterType({ phpType2.typeSymbol })> 
	    } : "Failed to parse phpType: `<phpType1>` && `<phpType2>` (result: <parseMethodAnnotationsTwoParams(test3)>)";
    }
}

public void assertVarAnnotation()
{
	// #1 match `@(var|type) type $var` 
	// #2 match `@(var|type) $var type` 
	// #3 match `@(var|type) type` 
    for (phpType <- phpTypes) 
    {
		// #1 match `@(var|type) type $var` 
		str test1 = "@var " + phpType.literalType + " $param1";
	    assert parsePropertyNodeAnnotations(test1) == { <propDecl, varType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parsePropertyNodeAnnotations(test1)>)";
	    	
		// #2 match `@(var|type) $var type` 
		str test2 = "@var $param1 " + phpType.literalType;
	    assert parsePropertyNodeAnnotations(test2) == { <propDecl, varType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parsePropertyNodeAnnotations(test2)>)";
	    	
		// #3 match `@(var|type) type` 
		str test3 = "@var " + phpType.literalType;
	    assert parsePropertyNodeAnnotations(test3) == { <propDecl, varType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parsePropertyNodeAnnotations(test3)>)";
	}	    	
}
// kind of mocked function
private set[TypeSymbol] parseTypes(str input) 
	= parseTypes(input, makeNode(""), createEmptyM3(|file:///|));

private rel[loc, Annotation] parseMethodAnnotationsOneParam(str input) = parseAnnotations(input, makeMethodNodeWithOneParam(), createEmptyM3(|file:///|));
private rel[loc, Annotation] parseMethodAnnotationsTwoParams(str input) = parseAnnotations(input, makeMethodNodeWithTwoParams(), createEmptyM3(|file:///|));
private rel[loc, Annotation] parsePropertyNodeAnnotations(str input) = parseAnnotations(input, makePropertyNode(), createEmptyM3(|file:///|));
	
private ClassItem makeMethodNodeWithOneParam() 
	// method(str name, set[Modifier] modifiers, bool byRef, list[Param] params, list[Stmt] body)
	= readTextValueString(#ClassItem, "method(\"name\", {}, false, [param(\"param1\", noExpr(), noName(), false)[@decl=<paramDecl>]], [])[@decl=<methodDecl>]");	
	
private ClassItem makeMethodNodeWithTwoParams() 
	// method(str name, set[Modifier] modifiers, bool byRef, list[Param] params, list[Stmt] body)
	= readTextValueString(#ClassItem, "method(\"name\", {}, false, [param(\"param1\", noExpr(), noName(), false)[@decl=<paramDecl1>],param(\"param2\", noExpr(), noName(), false)[@decl=<paramDecl2>]], [])[@decl=<methodDecl>]");

private ClassItem makePropertyNode() 
	// property(set[Modifier] modifiers, list[Property] prop)
	// property(str propertyName, OptionExpr defaultValue);
	= readTextValueString(#ClassItem, "property({}, [property(\"param1\", noExpr())[@decl=<propDecl>]])");