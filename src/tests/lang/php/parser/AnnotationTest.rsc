module tests::lang::php::parser::AnnotationTest
extend lang::php::parser::Annotation;

import IO;
import Node;
import Set;
import ValueIO;

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
	//assertVarAnnotation();
}

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

public void asssertReturnAnnotation()
{
	// match `@return type` in the phpdoc
    for (phpType <- phpTypes) {
    	loc methodDecl = |php+method:///cl/name|;
    	loc paramDecl = |php+methodParam:///cl/name/param1|;
	    assert parseAnnotations("@return " + phpType.literalType, methodDecl, paramDecl) == { <methodDecl, returnType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> 
	    	result: <parseAnnotations("@return " + phpType.literalType, methoDecl, paramDecl)>)";
    }
}

public void assertParamAnnotation()
{
	// #1 match `@param type $var` 
	// #2 match `@param $var type` 
	// #3 match `@param type` 
    for (phpType <- phpTypes) 
    {
    	loc methodDecl = |php+method:///cl/name|;
    	loc paramDecl = |php+methodParam:///cl/name/param1|;
    	
		// #1 match `@param type $var` 
		str test1 = "@param " + phpType.literalType + " $param1";
	    assert parseAnnotations(test1, methodDecl, paramDecl) == { <paramDecl, parameterType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parseAnnotations(test1, methodDecl, paramDecl)>)";
	    	
		// #2 match `@param $var type` 
		str test2 = "@param $param1 " + phpType.literalType;
	    assert parseAnnotations(test2, methodDecl, paramDecl) == { <paramDecl, parameterType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parseAnnotations(test2, methodDecl, paramDecl)>)";
	    	
		// #3 match `@param type` 
		str test3 = "@param " + phpType.literalType;
	    assert parseAnnotations(test3, methodDecl, paramDecl) == { <paramDecl, parameterType({ phpType.typeSymbol })> } 
	    	: "Failed to parse phpType: <phpType> (result: <parseAnnotations(test3, methodDecl, paramDecl)>)";
	}	    	

    // Node with two params:
    for (phpType1 <- phpTypes, phpType2 <- phpTypes) 
    {
    	loc methodDecl = |php+method:///cl/name|;
    	loc paramDecl1 = |php+methodParam:///cl/name/param1|;
    	loc paramDecl2 = |php+methodParam:///cl/name/param2|;
    	
		// #1 match `@param type $var` 
		str test1 = "@param " + phpType1.literalType + " $param1 description" + "\n" + "@param " + phpType2.literalType + " $param2";
	    assert parseAnnotations(test1, methodDecl, paramDecl1, paramDecl2) == { 
	    	<paramDecl1, parameterType({ phpType1.typeSymbol })>,
	    	<paramDecl2, parameterType({ phpType2.typeSymbol })> 
	    } : "Failed to parse phpType: `<phpType1>` && `<phpType2>` (result: <parseAnnotations(test1, methodDecl, paramDecl1, paramDecl2)>)";
	    
		// #2 match `@param $var type` 
		str test2 = "@param $param1 " + phpType1.literalType + " description" + "\n" + "@param $param2 " + phpType2.literalType;
	    assert parseAnnotations(test2, methodDecl, paramDecl1, paramDecl2) == { 
	    	<paramDecl1, parameterType({ phpType1.typeSymbol })>,
	    	<paramDecl2, parameterType({ phpType2.typeSymbol })> 
	    } : "Failed to parse phpType: `<phpType1>` && `<phpType2>` (result: <parseAnnotations(test2, methodDecl, paramDecl1, paramDecl2)>)";
	    	
		// #3 match `@param type` 
		str test3 = "@param " + phpType1.literalType + " description" + "\n" + "@param " + phpType2.literalType;
	    assert parseAnnotations(test3, methodDecl, paramDecl1, paramDecl2) == { 
	    	<paramDecl1, parameterType({ phpType1.typeSymbol })>,
	    	<paramDecl2, parameterType({ phpType2.typeSymbol })> 
	    } : "Failed to parse phpType: `<phpType1>` && `<phpType2>` (result: <parseAnnotations(test3, methodDecl, paramDecl1, paramDecl2)>)";
    }
}

// kind of mocked function
private set[TypeSymbol] parseTypes(str input) 
	= parseTypes(input, makeNode(""), createEmptyM3(|file:///|));

private rel[loc, Annotation] parseAnnotations(str input, loc methodDecl, loc paramDecl) 
	= parseAnnotations(input, makeMethodNode(methodDecl, paramDecl), createEmptyM3(|file:///|));
	
private rel[loc, Annotation] parseAnnotations(str input, loc methodDecl, loc paramDecl1, loc paramDecl2) 
	= parseAnnotations(input, makeMethodNode(methodDecl, paramDecl1, paramDecl2), createEmptyM3(|file:///|));
	
private ClassItem makeMethodNode(loc methodDecl, loc paramDecl) 
	// | method(str name, set[Modifier] modifiers, bool byRef, list[Param] params, list[Stmt] body)
	= readTextValueString(#ClassItem, "method(\"name\", {}, false, [param(\"param1\", noExpr(), noName(), false)[@decl=<paramDecl>]], [])[@decl=<methodDecl>]");	
	
private ClassItem makeMethodNode(loc methodDecl, loc paramDecl1, loc paramDecl2) 
	// | method(str name, set[Modifier] modifiers, bool byRef, list[Param] params, list[Stmt] body)
	= readTextValueString(#ClassItem, "method(\"name\", {}, false, [param(\"param1\", noExpr(), noName(), false)[@decl=<paramDecl1>],param(\"param2\", noExpr(), noName(), false)[@decl=<paramDecl2>]], [])[@decl=<methodDecl>]");

private node getParams()
	// str paramName, OptionExpr paramDefault, OptionName paramType, bool byRef);
	= [ makeNode("param", "$param1", makeNode("noExpr"), makeNode("noName"), false) ]
	+ [ makeNode("param", "$param2", makeNode("noExpr"), makeNode("noName"), false) ];