module lang::php::experiments::mscse2014::ConstraintExtractorAndSolverTest

extend lang::php::experiments::mscse2014::ConstraintExtractor;
extend lang::php::experiments::mscse2014::ConstraintSolver;
extend lang::php::experiments::mscse2014::mscse2014;

import lang::php::types::TypeConstraints;
import lang::php::util::Config;
import lang::php::pp::PrettyPrinter;

import Set; // toList
import List; // sort
import ValueIO; // readTextValueFile
import Message;

loc getFileLocation(str name) = analysisLoc + "/src/tests/resources/experiments/mscse2014/<name>/";
//loc getFileLocationFull(str name) = getFileLocation(name) + "/<name>.php";

// Test constraint extraction and constraint solving
public void main()
{

	assert true == testIssues();
	// trigger all tests
	assert true == testVariables();
	assert true == testNormalAssign();
	assert true == testScalars();
	assert true == testPredefinedConstants(); // no constraint solving here
	assert true == testPredefinedVariables(); // no constraint solving here
	assert true == testOpAssign();
	assert true == testUnaryOp();
	assert true == testBinaryOp();
	assert true == testTernary();
	assert true == testComparisonOp();
	assert true == testLogicalOp();
	assert true == testCasts();
	//assert true == testarrayType();
	//assert true == testVarious();
	//assert true == testControlStructures();
	//assert true == testFunction();
	//assert true == testClassMethod();
	//assert true == testClassConstant();
	//assert true == testClassProperty();
	//assert true == testMethodCallStatic();
	//assert true == testClassKeywords();
	//assert true == testMethodCall();
}

public test bool testIssues() {
	list[str] expectedConstraints = [
		"[$a] \<: any()",
	    "[|php+globalVar:///a|] = [$a]",
		"[(array)$a] \<: arrayType(any())"
	];
	list[str] expectedTypes = [
		"[$a] = { any() }", 
		"[|php+globalVar:///a|] = { any() }",
		"[(array)$a] = sub({ arrayType(any()) })"
	];
	
	return testConstraints("issue1", expectedConstraints, expectedTypes);

}

public test bool testVariables() {
	return testVariable1() 
		&& testVariable2() 
		&& testVariable3()
		;
}
@doc { $a = "string"; }
public test bool testVariable1() {
	list[str] expectedConstraints = [
		"[$a] \<: any()",
	    "[|php+globalVar:///a|] = [$a]",
		"[$a] = [$a = \"string\"]", 
		"[\"string\"] = stringType()", 
		"[\"string\"] \<: [$a]"
	];
	list[str] expectedTypes = [
		"[$a] = { stringType() }", 
		"[\"string\"] = { stringType() }", 
		"[$a = \"string\"] = { stringType() }",
		"[|php+globalVar:///a|] = { stringType() }"
	];
	
	return testConstraints("variable1", expectedConstraints, expectedTypes);
}
@doc { $a = "string"; $a = 100; }
public test bool testVariable2() {
	list[str] expectedConstraints = [
		// all $a variables
	    "[|php+globalVar:///a|] = [$a]",
	    "[|php+globalVar:///a|] = [$a]",
		// $a = "string";
		"[$a] = [$a = \"string\"]",
		"[\"string\"] = stringType()",
		"[\"string\"] \<: [$a]",
		// $a = 100;
		"[$a] = [$a = 100]",
		"[100] = integerType()",
		"[100] \<: [$a]",
		// variable (2x)
		"[$a] \<: any()",
		"[$a] \<: any()"
	];
	list[str] expectedTypes = [
		"[$a] = { stringType() }", 
		"[$a] = { integerType() }", 
		"[|php+globalVar:///a|] = { any() }", 
		"[100] = { integerType() }",
		"[\"string\"] = { stringType() }",
		"[$a = 100] = { integerType() }",
		"[$a = \"string\"] = { stringType() }"
	];
	return testConstraints("variable2", expectedConstraints, expectedTypes);
}
public test bool testVariable3() {
	// $a = "string";
	// $b = 100;
	// $c = true ? $a : $b;
	list[str] expectedConstraints = [
		"[$a] = [$a = \"string\"]",
		"[\"string\"] = stringType()",
		"[\"string\"] \<: [$a]",
		"[$b] = [$b = 100]",
		"[100] \<: [$b]",
		"[$c] = [$c = true ? $a : $b]",
		"[true ? $a : $b] \<: [$c]",
		"[100] = integerType()" ,
		"[true] = booleanType()",
		"or([true ? $a : $b] \<: [$a], [true ? $a : $b] \<: [$b])",
		"[$a] \<: any()",
		"[$a] \<: any()",
		"[$b] \<: any()",
		"[$b] \<: any()",
		"[$c] \<: any()",
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///b|] = [$b]",
		"[|php+globalVar:///b|] = [$b]",
		"[|php+globalVar:///c|] = [$c]"
	];
	list[str] expectedTypes = [
		// 2 variable $a
		"[$a = \"string\"] = { stringType() }",
		"[|php+globalVar:///a|] = { stringType() }",
		"[$a] = { stringType() }",
		"[$a] = { stringType() }",
		// 2 variable $b
		"[$b = 100] = { integerType() }",
		"[|php+globalVar:///b|] = { integerType() }",
		"[$b] = { integerType() }",
		"[$b] = { integerType() }",
		// 3 constants
		"[100] = { integerType() }", "[\"string\"] = { stringType() }", "[true] = { booleanType() }", 
		// ternary solutions 
		"[true ? $a : $b] = { any() }", 
		"[$c = true ? $a : $b] = { any() }",
		"[|php+globalVar:///c|] = { any() }",
		"[$c] = { any() }"
	];
	// if exptectedTypes are empty, they are not evaluated/tested
	return testConstraints("variable3", expectedConstraints, expectedTypes);
}
@doc { $a = 2; $b = $a; $c = $d = $b }
public test bool testNormalAssign() {
	list[str] expectedConstraints = [
		// $a = 2; 
		"[2] \<: [$a]", 
		"[$a] = [$a = 2]", 
		"[2] = integerType()", // assign of int
		"[$a] \<: any()",
		"[|php+globalVar:///a|] = [$a]",
		
		// $b = $a; 
		"[$a] \<: [$b]", // assign assign of vars
		"[$b] = [$b = $a]", // type of full expr is the type of the assignment
		"[$a] \<: any()",
		"[|php+globalVar:///a|] = [$a]",
		"[$b] \<: any()",
		"[|php+globalVar:///b|] = [$b]",
		
		// $c = $d = $b; 
		"[$b] \<: [$d]", 
		"[$d = $b] \<: [$c]", 
		"[$d] = [$d = $b]",
		"[$c] = [$c = $d = $b]",
		"[$b] \<: any()",
		"[|php+globalVar:///b|] = [$b]",
		"[$c] \<: any()",
		"[|php+globalVar:///c|] = [$c]",
		"[$d] \<: any()",
		"[|php+globalVar:///d|] = [$d]"
	];
	list[str] expectedTypes = [
		"[2] = { integerType() }",
		"[$a] = { integerType() }",
		"[$a = 2] = { integerType() }",
		"[$a] = { integerType() }",
		"[$b = $a] = { integerType() }",
		"[$b] = { integerType() }",
		"[$b] = { integerType() }",
		"[$c = $d = $b] = { integerType() }",
		"[$c] = { integerType() }",
		"[$d = $b] = { integerType() }",
		"[$d] = { integerType() }",
		"[|php+globalVar:///a|] = { integerType() }",
		"[|php+globalVar:///b|] = { integerType() }",
		"[|php+globalVar:///c|] = { integerType() }",
		"[|php+globalVar:///d|] = { integerType() }"
	];
	return testConstraints("normalAssign", expectedConstraints, expectedTypes);
}

public test bool testScalars() {
	list[str] expectedConstraints = [
		// floats -> floatType()
		"[0.0] = floatType()", "[0.5] = floatType()", "[1000.0382] = floatType()",
		// int -> int()
		"[0] = integerType()", "[1] = integerType()", "[2] = integerType()", "[10] = integerType()", "[100] = integerType()",
		// strings -> stringType()
		"[\"string\"] = stringType()", "[\'also a string\'] = stringType()", 
		// encapsed -> stringType()
		// also evaluate the items of the encapsed string
		"[\"$encapsed string\"] = stringType()", "[\"{$encapsed} string\"] = stringType()",
		"[$encapsed] \<: any()", "[$encapsed] \<: any()",
		"[|php+globalVar:///encapsed|] = [$encapsed]",
		"[|php+globalVar:///encapsed|] = [$encapsed]"
	];
	list[str] expectedTypes = [
		"[\"$encapsed string\"] = { stringType() }",
		"[\"string\"] = { stringType() }",
		"[\"{$encapsed} string\"] = { stringType() }",
		"[$encapsed] = { any() }",
		"[$encapsed] = { any() }",
		"[\'also a string\'] = { stringType() }",
		"[0.0] = { floatType() }",
		"[0.5] = { floatType() }",
		"[0] = { integerType() }",
		"[1000.0382] = { floatType() }",
		"[100] = { integerType() }",
		"[10] = { integerType() }",
		"[1] = { integerType() }",
		"[2] = { integerType() }",
		"[|php+globalVar:///encapsed|] = { any() }"
	];
	return testConstraints("scalar", expectedConstraints, expectedTypes);
}

public test bool testPredefinedConstants() {
	list[str] expectedConstraints = [
		// magic constants -> stringType() (except for __LINE__ which is of type integerType()
		"[__CLASS__] = stringType()", "[__DIR__] = stringType()", "[__FILE__] = stringType()", "[__FUNCTION__] = stringType()", 
		"[__LINE__] = integerType()", "[__METHOD__] = stringType()", "[__NAMESPACE__] = stringType()", "[__TRAIT__] = stringType()",
		
		// booleans -> booleanType()
		"[TRUE] = booleanType()", "[true] = booleanType()", "[TrUe] = booleanType()",
		"[FALSE] = booleanType()", "[false] = booleanType()", "[FalSe] = booleanType()",
		
		"[DEFAULT_INCLUDE_PATH] = stringType()",
		"[E_ALL] = integerType()",
		"[E_COMPILE_ERROR] = integerType()",
		"[E_COMPILE_WARNING] = integerType()",
		"[E_CORE_ERROR] = integerType()",
		"[E_CORE_WARNING] = integerType()",
		"[E_DEPRECATED] = integerType()",
		"[E_ERROR] = integerType()",
		"[E_NOTICE] = integerType()",
		"[E_PARSE] = integerType()",
		"[E_RECOVERABLE_ERROR] = integerType()",
		"[E_STRICT] = integerType()",
		"[E_USER_DEPRECATED] = integerType()",
		"[E_USER_ERROR] = integerType()",
		"[E_USER_NOTICE] = integerType()",
		"[E_USER_WARNING] = integerType()",
		"[E_WARNING] = integerType()",
		"[E_USER_DEPRECATED] = integerType()",
		"[FALSE] = booleanType()",
		"[INF] = floatType()",
		"[M_1_PI] = floatType()",
		"[M_2_PI] = floatType()",
		"[M_2_SQRTPI] = floatType()",
		"[M_E] = floatType()",
		"[M_EULER] = floatType()",
		"[M_LN10] = floatType()",
		"[M_LN2] = floatType()",
		"[M_LNPI] = floatType()",
		"[M_LOG10E] = floatType()",
		"[M_LOG2E] = floatType()",
		"[M_PI] = floatType()",
		"[M_PI_2] = floatType()",
		"[M_PI_4] = floatType()",
		"[M_SQRT1_2] = floatType()",
		"[M_SQRT2] = floatType()",
		"[M_SQRT3] = floatType()",
		"[M_SQRTPI] = floatType()",
		"[NAN] = floatType()",
		"[NULL] = nullType()",
		"[PHP_BINARY] = stringType()",
		"[PHP_BINDIR] = stringType()",
		"[PHP_CONFIG_FILE_PATH] = stringType()",
		"[PHP_CONFIG_FILE_SCAN_DIR] = stringType()",
		"[PHP_DEBUG] = integerType()",
		"[PHP_EOL] = stringType()",
		"[PHP_EXTENSION_DIR] = stringType()",
		"[PHP_EXTRA_VERSION] = stringType()",
		"[PHP_INT_MAX] = integerType()",
		"[PHP_INT_SIZE] = integerType()",
		"[PHP_MAJOR_VERSION] = integerType()",
		"[PHP_MANDIR] = stringType()",
		"[PHP_MAXPATHLEN] = integerType()",
		"[PHP_MINOR_VERSION] = integerType()",
		"[PHP_OS] = stringType()",
		"[PHP_PREFIX] = stringType()",
		"[PHP_RELEASE_VERSION] = integerType()",
		"[PHP_ROUND_HALF_DOWN] = integerType()",
		"[PHP_ROUND_HALF_EVEN] = integerType()",
		"[PHP_ROUND_HALF_ODD] = integerType()",
		"[PHP_ROUND_HALF_UP] = integerType()",
		"[PHP_SAPI] = stringType()",
		"[PHP_SHLIB_SUFFIX] = stringType()",
		"[PHP_SYSCONFDIR] = stringType()",
		"[PHP_VERSION] = stringType()",
		"[PHP_VERSION_ID] = integerType()",
		"[PHP_ZTS] = integerType()",
		"[STDIN] = resourceType()",
		"[STDOUT] = resourceType()",
		"[STDERR] = resourceType()",
		"[TRUE] = booleanType()"
	];
	list[str] expectedTypes = [
		"[DEFAULT_INCLUDE_PATH] = { stringType() }",
		"[E_ALL] = { integerType() }",
		"[E_COMPILE_ERROR] = { integerType() }",
		"[E_COMPILE_WARNING] = { integerType() }",
		"[E_CORE_ERROR] = { integerType() }",
		"[E_CORE_WARNING] = { integerType() }",
		"[E_DEPRECATED] = { integerType() }",
		"[E_ERROR] = { integerType() }",
		"[E_NOTICE] = { integerType() }",
		"[E_PARSE] = { integerType() }",
		"[E_RECOVERABLE_ERROR] = { integerType() }",
		"[E_STRICT] = { integerType() }",
		"[E_USER_DEPRECATED] = { integerType() }",
		"[E_USER_DEPRECATED] = { integerType() }",
		"[E_USER_ERROR] = { integerType() }",
		"[E_USER_NOTICE] = { integerType() }",
		"[E_USER_WARNING] = { integerType() }",
		"[E_WARNING] = { integerType() }",
		"[FALSE] = { booleanType() }",
		"[FALSE] = { booleanType() }",
		"[FalSe] = { booleanType() }",
		"[INF] = { floatType() }",
		"[M_1_PI] = { floatType() }",
		"[M_2_PI] = { floatType() }",
		"[M_2_SQRTPI] = { floatType() }",
		"[M_EULER] = { floatType() }",
		"[M_E] = { floatType() }",
		"[M_LN10] = { floatType() }",
		"[M_LN2] = { floatType() }",
		"[M_LNPI] = { floatType() }",
		"[M_LOG10E] = { floatType() }",
		"[M_LOG2E] = { floatType() }",
		"[M_PI] = { floatType() }",
		"[M_PI_2] = { floatType() }",
		"[M_PI_4] = { floatType() }",
		"[M_SQRT1_2] = { floatType() }",
		"[M_SQRT2] = { floatType() }",
		"[M_SQRT3] = { floatType() }",
		"[M_SQRTPI] = { floatType() }",
		"[NAN] = { floatType() }",
		"[NULL] = { nullType() }",
		"[PHP_BINARY] = { stringType() }",
		"[PHP_BINDIR] = { stringType() }",
		"[PHP_CONFIG_FILE_PATH] = { stringType() }",
		"[PHP_CONFIG_FILE_SCAN_DIR] = { stringType() }",
		"[PHP_DEBUG] = { integerType() }",
		"[PHP_EOL] = { stringType() }",
		"[PHP_EXTENSION_DIR] = { stringType() }",
		"[PHP_EXTRA_VERSION] = { stringType() }",
		"[PHP_INT_MAX] = { integerType() }",
		"[PHP_INT_SIZE] = { integerType() }",
		"[PHP_MAJOR_VERSION] = { integerType() }",
		"[PHP_MANDIR] = { stringType() }",
		"[PHP_MAXPATHLEN] = { integerType() }",
		"[PHP_MINOR_VERSION] = { integerType() }",
		"[PHP_OS] = { stringType() }",
		"[PHP_PREFIX] = { stringType() }",
		"[PHP_RELEASE_VERSION] = { integerType() }",
		"[PHP_ROUND_HALF_DOWN] = { integerType() }",
		"[PHP_ROUND_HALF_EVEN] = { integerType() }",
		"[PHP_ROUND_HALF_ODD] = { integerType() }",
		"[PHP_ROUND_HALF_UP] = { integerType() }",
		"[PHP_SAPI] = { stringType() }",
		"[PHP_SHLIB_SUFFIX] = { stringType() }",
		"[PHP_SYSCONFDIR] = { stringType() }",
		"[PHP_VERSION] = { stringType() }",
		"[PHP_VERSION_ID] = { integerType() }",
		"[PHP_ZTS] = { integerType() }",
		"[STDERR] = { resourceType() }",
		"[STDIN] = { resourceType() }",
		"[STDOUT] = { resourceType() }",
		"[TRUE] = { booleanType() }",
		"[TRUE] = { booleanType() }",
		"[TrUe] = { booleanType() }",
		"[__CLASS__] = { stringType() }",
		"[__DIR__] = { stringType() }",
		"[__FILE__] = { stringType() }",
		"[__FUNCTION__] = { stringType() }",
		"[__LINE__] = { integerType() }",
		"[__METHOD__] = { stringType() }",
		"[__NAMESPACE__] = { stringType() }",
		"[__TRAIT__] = { stringType() }",
		"[false] = { booleanType() }",
		"[true] = { booleanType() }"
	];
	return testConstraints("predefinedConstants", expectedConstraints, expectedTypes);
}

public test bool testPredefinedVariables() {
	list[str] expectedConstraints = [
		"[$argc] = integerType()",
		"[$argv] = arrayType(stringType())",
		"[$_COOKIE] \<: arrayType(any())",
		"[$_ENV] \<: arrayType(any())",
		"[$_FILES] \<: arrayType(any())",
		"[$_GET] \<: arrayType(any())",
		"[$GLOBALS] \<: arrayType(any())",
		"[$_REQUEST] \<: arrayType(any())",
		"[$_POST] \<: arrayType(any())",
		"[$_SERVER] \<: arrayType(any())",
		"[$_SESSION] \<: arrayType(any())",
    
		"[$php_errormsg] = stringType()",
		"[$HTTP_RAW_POST_DATA] = arrayType(stringType())",
		"[$http_response_header] = arrayType(stringType())",
		
		"[|php+globalVar:///GLOBALS|] = [$GLOBALS]",
		"[|php+globalVar:///HTTP_RAW_POST_DATA|] = [$HTTP_RAW_POST_DATA]",
		"[|php+globalVar:///_COOKIE|] = [$_COOKIE]",
		"[|php+globalVar:///_ENV|] = [$_ENV]",
		"[|php+globalVar:///_FILES|] = [$_FILES]",
		"[|php+globalVar:///_GET|] = [$_GET]",
		"[|php+globalVar:///_POST|] = [$_POST]",
		"[|php+globalVar:///_REQUEST|] = [$_REQUEST]",
		"[|php+globalVar:///_SERVER|] = [$_SERVER]",
		"[|php+globalVar:///_SESSION|] = [$_SESSION]",
		"[|php+globalVar:///argc|] = [$argc]",
		"[|php+globalVar:///argv|] = [$argv]",
		"[|php+globalVar:///http_response_header|] = [$http_response_header]",
		"[|php+globalVar:///php_errormsg|] = [$php_errormsg]"
	];
	list[str] expectedTypes = [];
	return testConstraints("predefinedVariables", expectedConstraints, expectedTypes);
}

public test bool testOpAssign() {
	list[str] expectedConstraints = [
		// LHS = integerType()
		"[$a] \<: any()", "[$b] \<: any()", "[$a] = integerType()", // $a  &= $b
		"[$c] \<: any()", "[$d] \<: any()", "[$c] = integerType()", // $c  |= $d
		"[$e] \<: any()", "[$f] \<: any()", "[$e] = integerType()", // $e  ^= $f
		"[$g] \<: any()", "[$h] \<: any()", "[$g] = integerType()", // $g  %= $h
		"[$i] \<: any()", "[$j] \<: any()", "[$i] = integerType()", // $i <<= $j
		"[$k] \<: any()", "[$l] \<: any()", "[$k] = integerType()", // $k >>= $l
	
		// LHS = stringType()	
		"[$m] \<: any()", "[$n] \<: any()", "[$m] = stringType()", // $m .= $n
		"if ([$n] \<: objectType()) then (hasMethod([$n], __tostring))", // if (n == object) => [$n] has method __tostring
	
		// LHS = integer, RHS != arrayType()	
		"[$o] \<: any()", "[$p] \<: any()", "[$o] = integerType()", "neg([$p] \<: arrayType(any()))", // $o /= $p
		"[$q] \<: any()", "[$r] \<: any()", "[$q] = integerType()", "neg([$r] \<: arrayType(any()))", // $q -= $r
	
		// LHS = integer || number => LHS <: numberType()	
		"[$s] \<: any()", "[$t] \<: any()", "[$s] \<: numberType()", // $s *= $t
		"[$u] \<: any()", "[$v] \<: any()", "[$u] \<: numberType()",  // $u += $v
		
		// Variables
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///b|] = [$b]",
		"[|php+globalVar:///c|] = [$c]",
		"[|php+globalVar:///d|] = [$d]",
		"[|php+globalVar:///e|] = [$e]",
		"[|php+globalVar:///f|] = [$f]",
		"[|php+globalVar:///g|] = [$g]",
		"[|php+globalVar:///h|] = [$h]",
		"[|php+globalVar:///i|] = [$i]",
		"[|php+globalVar:///j|] = [$j]",
		"[|php+globalVar:///k|] = [$k]",
		"[|php+globalVar:///l|] = [$l]",
		"[|php+globalVar:///m|] = [$m]",
		"[|php+globalVar:///n|] = [$n]",
		"[|php+globalVar:///o|] = [$o]",
		"[|php+globalVar:///p|] = [$p]",
		"[|php+globalVar:///q|] = [$q]",
		"[|php+globalVar:///r|] = [$r]",
		"[|php+globalVar:///s|] = [$s]",
		"[|php+globalVar:///t|] = [$t]",
		"[|php+globalVar:///u|] = [$u]",
		"[|php+globalVar:///v|] = [$v]"
	];
	list[str] expectedTypes = [
		"[$a] = { integerType() }",
		"[$b] = { any() }",
		"[$c] = { integerType() }",
		"[$d] = { any() }",
		"[$e] = { integerType() }",
		"[$f] = { any() }",
		"[$g] = { integerType() }",
		"[$h] = { any() }",
		"[$i] = { integerType() }",
		"[$j] = { any() }",
		"[$k] = { integerType() }",
		"[$l] = { any() }",
		"[$m] = { stringType() }",
		"[$n] = { any() }",
		"[$o] = { integerType() }",
		"[$p] = { any() }",
		"[$q] = { integerType() }",
		"[$r] = { any() }",
		"[$s] = { any() }",
		"[$t] = { any() }",
		"[$u] = { any() }",
		"[$v] = { any() }",
		
		"[|php+globalVar:///a|] = { integerType() }",
		"[|php+globalVar:///b|] = { any() }",
		"[|php+globalVar:///c|] = { integerType() }",
		"[|php+globalVar:///d|] = { any() }",
		"[|php+globalVar:///e|] = { integerType() }",
		"[|php+globalVar:///f|] = { any() }",
		"[|php+globalVar:///g|] = { integerType() }",
		"[|php+globalVar:///h|] = { any() }",
		"[|php+globalVar:///i|] = { integerType() }",
		"[|php+globalVar:///j|] = { any() }",
		"[|php+globalVar:///k|] = { integerType() }",
		"[|php+globalVar:///l|] = { any() }",
		"[|php+globalVar:///m|] = { stringType() }",
		"[|php+globalVar:///n|] = { any() }",
		"[|php+globalVar:///o|] = { integerType() }",
		"[|php+globalVar:///p|] = { any() }",
		"[|php+globalVar:///q|] = { integerType() }",
		"[|php+globalVar:///r|] = { any() }",
		"[|php+globalVar:///s|] = { any() }",
		"[|php+globalVar:///t|] = { any() }",
		"[|php+globalVar:///u|] = { any() }",
		"[|php+globalVar:///v|] = { any() }"
	];
	return testConstraints("opAssign", expectedConstraints, expectedTypes);
}

public test bool testUnaryOp() {
	list[str] expectedConstraints = [
		// +$a;
		"[$a] \<: any()",
		"[|php+globalVar:///a|] = [$a]",
		"[+$a] \<: numberType()", // expression is number or int
		"neg([$a] \<: arrayType(any()))", // $a is not an array

		// -$b;
		"[$b] \<: any()",
		"[|php+globalVar:///b|] = [$b]",
		"[-$b] \<: numberType()", // expression is number or int
		"neg([$b] \<: arrayType(any()))", // $b is not an array
		
		// !$c;
		"[$c] \<: any()", 
		"[|php+globalVar:///c|] = [$c]",
		"[!$c] = booleanType()", 
	
		// ~$d;	
		"[$d] \<: any()", 
		"[|php+globalVar:///d|] = [$d]",
		"or([$d] = floatType(), [$d] = integerType(), [$d] = stringType())", 
		"or([~$d] = integerType(), [~$d] = stringType())", 
		
		// $e++;	
		"[$e] \<: any()",
		"[|php+globalVar:///e|] = [$e]",
		"if ([$e] \<: arrayType(any())) then ([$e++] \<: arrayType(any()))",
		"if ([$e] = booleanType()) then ([$e++] = booleanType())",
		"if ([$e] = floatType()) then ([$e++] = floatType())",
		"if ([$e] = integerType()) then ([$e++] = integerType())",
		"if ([$e] = nullType()) then (or([$e++] = integerType(), [$e++] = nullType()))",
		"if ([$e] \<: objectType()) then ([$e++] \<: objectType())",
		"if ([$e] = resourceType()) then ([$e++] = resourceType())",
		"if ([$e] = stringType()) then (or([$e++] = floatType(), [$e++] = integerType(), [$e++] = stringType()))",
	
		// $f--;	
		"[$f] \<: any()",
		"[|php+globalVar:///f|] = [$f]",
		"if ([$f] \<: arrayType(any())) then ([$f--] \<: arrayType(any()))",
		"if ([$f] = booleanType()) then ([$f--] = booleanType())",
		"if ([$f] = floatType()) then ([$f--] = floatType())",
		"if ([$f] = integerType()) then ([$f--] = integerType())",
		"if ([$f] = nullType()) then (or([$f--] = integerType(), [$f--] = nullType()))",
		"if ([$f] \<: objectType()) then ([$f--] \<: objectType())",
		"if ([$f] = resourceType()) then ([$f--] = resourceType())",
		"if ([$f] = stringType()) then (or([$f--] = floatType(), [$f--] = integerType(), [$f--] = stringType()))",
	
		// ++$g;	
		"[$g] \<: any()",
		"[|php+globalVar:///g|] = [$g]",
		"if ([$g] \<: arrayType(any())) then ([++$g] \<: arrayType(any()))",
		"if ([$g] = booleanType()) then ([++$g] = booleanType())",
		"if ([$g] = floatType()) then ([++$g] = floatType())",
		"if ([$g] = integerType()) then ([++$g] = integerType())",
		"if ([$g] = nullType()) then ([++$g] = integerType())",
		"if ([$g] \<: objectType()) then ([++$g] \<: objectType())",
		"if ([$g] = resourceType()) then ([++$g] = resourceType())",
		"if ([$g] = stringType()) then (or([++$g] = floatType(), [++$g] = integerType(), [++$g] = stringType()))",
		
		// --$h;
		"[$h] \<: any()",
		"[|php+globalVar:///h|] = [$h]",
		"if ([$h] \<: arrayType(any())) then ([--$h] \<: arrayType(any()))",
		"if ([$h] = booleanType()) then ([--$h] = booleanType())",
		"if ([$h] = floatType()) then ([--$h] = floatType())",
		"if ([$h] = integerType()) then ([--$h] = integerType())",
		"if ([$h] = nullType()) then ([--$h] = integerType())",
		"if ([$h] \<: objectType()) then ([--$h] \<: objectType())",
		"if ([$h] = resourceType()) then ([--$h] = resourceType())",
		"if ([$h] = stringType()) then (or([--$h] = floatType(), [--$h] = integerType(), [--$h] = stringType()))"
	];
	list[str] expectedTypes = [
		// todo: fix solving of these constraints
	];
	return testConstraints("unaryOp", expectedConstraints, expectedTypes);
}

public test bool testBinaryOp() {
	list[str] expectedConstraints = [
		// $a + $b;
		"[$a] \<: any()", "[$b] \<: any()",
		"or([$a + $b] \<: arrayType(any()), [$a + $b] \<: numberType())", // always array, or subtype of numberType()
		"if (and([$a] \<: arrayType(any()), [$b] \<: arrayType(any()))) then ([$a + $b] \<: arrayType(any()))", // ($a = array && $b = array) => [E] = array
		"if (or(neg([$a] \<: arrayType(any())), neg([$b] \<: arrayType(any())))) then ([$a + $b] \<: numberType())", // ($a != array || $b = array) => [E] <: number 
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///b|] = [$b]",
		
		// $c - $d;	
		"[$c] \<: any()", "[$d] \<: any()",
		"neg([$c] \<: arrayType(any()))",
		"neg([$d] \<: arrayType(any()))",
		"[$c - $d] \<: numberType()",
		"[|php+globalVar:///c|] = [$c]",
		"[|php+globalVar:///d|] = [$d]",
	
		// $e * $f;	
		"[$e] \<: any()", "[$f] \<: any()",
		"neg([$e] \<: arrayType(any()))",
		"neg([$f] \<: arrayType(any()))",
		"[$e * $f] \<: numberType()",
		"[|php+globalVar:///e|] = [$e]",
		"[|php+globalVar:///f|] = [$f]",
	
		// $g / $h;	
		"[$g] \<: any()", "[$h] \<: any()",
		"neg([$g] \<: arrayType(any()))",
		"neg([$h] \<: arrayType(any()))",
		"[$g / $h] \<: numberType()",
		"[|php+globalVar:///g|] = [$g]",
		"[|php+globalVar:///h|] = [$h]",
	
		// $i % $j;	
		"[$i] \<: any()", "[$j] \<: any()",
		"[$i % $j] = integerType()",
		"[|php+globalVar:///i|] = [$i]",
		"[|php+globalVar:///j|] = [$j]",

		// $k & $l;	
		"[$k] \<: any()", "[$l] \<: any()",
		"if (and([$k] = stringType(), [$l] = stringType())) then ([$k & $l] = stringType())",
		"if (or(neg([$k] = stringType()), neg([$l] = stringType()))) then ([$k & $l] = integerType())",
		"or([$k & $l] = integerType(), [$k & $l] = stringType())",
		"[|php+globalVar:///k|] = [$k]",
		"[|php+globalVar:///l|] = [$l]",
		
		// $m | $n;	
		"[$m] \<: any()", "[$n] \<: any()",
		"if (and([$m] = stringType(), [$n] = stringType())) then ([$m | $n] = stringType())",
		"if (or(neg([$m] = stringType()), neg([$n] = stringType()))) then ([$m | $n] = integerType())",
		"or([$m | $n] = integerType(), [$m | $n] = stringType())",
		"[|php+globalVar:///m|] = [$m]",
		"[|php+globalVar:///n|] = [$n]",
		
		// $o ^ $p;	
		"[$o] \<: any()", "[$p] \<: any()",
		"if (and([$o] = stringType(), [$p] = stringType())) then ([$o ^ $p] = stringType())",
		"if (or(neg([$o] = stringType()), neg([$p] = stringType()))) then ([$o ^ $p] = integerType())",
		"or([$o ^ $p] = integerType(), [$o ^ $p] = stringType())",
		"[|php+globalVar:///o|] = [$o]",
		"[|php+globalVar:///p|] = [$p]",
		
		// $q << $r;	
		"[$q] \<: any()", "[$r] \<: any()",
		"[$q \<\< $r] = integerType()",
		"[|php+globalVar:///q|] = [$q]",
		"[|php+globalVar:///r|] = [$r]",
		
		// $s >> $t;	
		"[$s] \<: any()", "[$t] \<: any()",
		"[$s \>\> $t] = integerType()",
		"[|php+globalVar:///s|] = [$s]",
		"[|php+globalVar:///t|] = [$t]"
		
	];
	list[str] expectedTypes = [
		// todo solve constraints
	];
	return testConstraints("binaryOp", expectedConstraints, expectedTypes);
}

public test bool testTernary() {
	list[str] expectedConstraints = [
		// $a = true ? $b : "string";
		"[$a] \<: any()", "[$b] \<: any()", // $a and $b
		"[true] = booleanType()", "[\"string\"] = stringType()", // true and "string"
		"or([true ? $b : \"string\"] \<: [\"string\"], [true ? $b : \"string\"] \<: [$b])", // [E] = [E2] OR [E3]
		"[true ? $b : \"string\"] \<: [$a]", // $a = [E]
		"[$a] = [$a = true ? $b : \"string\"]", // result of the whole expression is a subtype of $a
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///b|] = [$b]",
		
		// $c = TRUE ? : "str";
		"[$c] \<: any()", 
		"[TRUE] = booleanType()", "[\"str\"] = stringType()", // TRUE and "string"
		"or([TRUE ? : \"str\"] \<: [\"str\"], [TRUE ? : \"str\"] \<: [TRUE])", // [E] = [E1] OR [E3]
		"[TRUE ? : \"str\"] \<: [$c]", // [E] = $c
		"[$c] = [$c = TRUE ? : \"str\"]", // result of the whole expression is a subtype of $c
		"[|php+globalVar:///c|] = [$c]",
	
		// $d = $e = 3 ? "l" : "r";
		"[$d] \<: any()", "[$e] \<: any()", 
		"[3] = integerType()", "[\"l\"] = stringType()", "[\"r\"] = stringType()", // 3, "l" and "r"
		"or([3 ? \"l\" : \"r\"] \<: [\"l\"], [3 ? \"l\" : \"r\"] \<: [\"r\"])",// [E] = [E1] OR [E3]
		"[3 ? \"l\" : \"r\"] \<: [$e]", // [E] <: $e
		"[$e = 3 ? \"l\" : \"r\"] \<: [$d]", // $d = $e
		"[$d] = [$d = $e = 3 ? \"l\" : \"r\"]",// result of the whole expression is a subtype of $c
		"[$e] = [$e = 3 ? \"l\" : \"r\"]", // result of the whole expression is a subtype of $c
		"[|php+globalVar:///d|] = [$d]",
		"[|php+globalVar:///e|] = [$e]"
		
	];
	list[str] expectedTypes = [];
	return testConstraints("ternary", expectedConstraints, expectedTypes);
}

public test bool testLogicalOp() {
	list[str] expectedConstraints = [
		// $a and $b;
		"[$a] \<: any()", "[$b] \<: any()",
		"[$a and $b] = booleanType()",
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///b|] = [$b]",
		
		// $c or $d;
		"[$c] \<: any()", "[$d] \<: any()",
		"[$c or $d] = booleanType()",
		"[|php+globalVar:///c|] = [$c]",
		"[|php+globalVar:///d|] = [$d]",
		
		// $e xor $f;
		"[$e] \<: any()", "[$f] \<: any()",
		"[$e xor $f] = booleanType()",
		"[|php+globalVar:///e|] = [$e]",
		"[|php+globalVar:///f|] = [$f]",
		
		// $g && $h;
		"[$g] \<: any()", "[$h] \<: any()",
		"[$g && $h] = booleanType()",
		"[|php+globalVar:///g|] = [$g]",
		"[|php+globalVar:///h|] = [$h]",
		
		// $i || $j;
		"[$i] \<: any()", "[$j] \<: any()",
		"[$i || $j] = booleanType()",
		"[|php+globalVar:///i|] = [$i]",
		"[|php+globalVar:///j|] = [$j]"
	];
	list[str] expectedTypes = [];
	return testConstraints("logicalOp", expectedConstraints, expectedTypes);
}

public test bool testComparisonOp() {
	list[str] expectedConstraints = [
		// $a < $b;
		"[$a] \<: any()", "[$b] \<: any()",
		"[$a \< $b] = booleanType()",
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///b|] = [$b]",
		
		// $c <= $d;
		"[$c] \<: any()", "[$d] \<: any()",
		"[$c \<= $d] = booleanType()",
		"[|php+globalVar:///c|] = [$c]",
		"[|php+globalVar:///d|] = [$d]",
		
		// $e > $f;
		"[$e] \<: any()", "[$f] \<: any()",
		"[$e \> $f] = booleanType()",
		"[|php+globalVar:///e|] = [$e]",
		"[|php+globalVar:///f|] = [$f]",
		
		// $g >= $h;
		"[$g] \<: any()", "[$h] \<: any()",
		"[$g \>= $h] = booleanType()",
		"[|php+globalVar:///g|] = [$g]",
		"[|php+globalVar:///h|] = [$h]",
		
		// $i == $j;
		"[$i] \<: any()", "[$j] \<: any()",
		"[$i == $j] = booleanType()",
		"[|php+globalVar:///i|] = [$i]",
		"[|php+globalVar:///j|] = [$j]",
		
		// $k === $l;
		"[$k] \<: any()", "[$l] \<: any()",
		"[$k === $l] = booleanType()",
		"[|php+globalVar:///k|] = [$k]",
		"[|php+globalVar:///l|] = [$l]",
	
		// $m != $n;
		"[$m] \<: any()", "[$n] \<: any()",
		"[$m != $n] = booleanType()",
		"[|php+globalVar:///m|] = [$m]",
		"[|php+globalVar:///n|] = [$n]",
		
		// $o <> $p;
		"[$o] \<: any()", "[$p] \<: any()",
		"[$o \<\> $p] = booleanType()",
		"[|php+globalVar:///o|] = [$o]",
		"[|php+globalVar:///p|] = [$p]",
		
		// $q !== $r;
		"[$q] \<: any()", "[$r] \<: any()",
		"[$q !== $r] = booleanType()",
		"[|php+globalVar:///q|] = [$q]",
		"[|php+globalVar:///r|] = [$r]"
	];
	list[str] expectedTypes = [];
	return testConstraints("comparisonOp", expectedConstraints, expectedTypes);
}

public test bool testCasts() {
	list[str] expectedConstraints = [
		"[$a] \<: any()", "[$b] \<: any()", "[$c] \<: any()", "[$d] \<: any()", 
		"[$e] \<: any()", "[$f] \<: any()", "[$g] \<: any()", "[$h] \<: any()", 
		"[$i] \<: any()", "[$j] \<: any()", "[$k] \<: any()", 
		"[|php+globalVar:///a|] = [$a]",
		"[|php+globalVar:///b|] = [$b]",
		"[|php+globalVar:///c|] = [$c]",
		"[|php+globalVar:///d|] = [$d]",
		"[|php+globalVar:///e|] = [$e]",
		"[|php+globalVar:///f|] = [$f]",
		"[|php+globalVar:///g|] = [$g]",
		"[|php+globalVar:///h|] = [$h]",
		"[|php+globalVar:///i|] = [$i]",
		"[|php+globalVar:///j|] = [$j]",
		"[|php+globalVar:///k|] = [$k]",
		
		// (cast)$var;	
		"[(array)$a] \<: arrayType(any())",
		"[(bool)$b] = booleanType()",
		"[(boolean)$c] = booleanType()",
		"[(int)$d] = integerType()",
		"[(integer)$e] = integerType()",
		"[(float)$f] = floatType()",
		"[(double)$g] = floatType()",
		"[(real)$h] = floatType()",
		
		"[(string)$i] = stringType()",
		"if ([$i] \<: objectType()) then (hasMethod([$i], __tostring))",
		
		"[(object)$j] \<: objectType()",
		"[(unset)$k] = nullType()"
	];
	list[str] expectedTypes = [
		"[$a] = { any() }",
		"[$b] = { any() }",
		"[$c] = { any() }",
		"[$d] = { any() }",
		"[$e] = { any() }",
		"[$f] = { any() }",
		"[$g] = { any() }",
		"[$h] = { any() }",
		"[$i] = { any() }",
		"[$j] = { any() }",
		"[$k] = { any() }",
		"[(array)$a] = { arrayType(any()) }",
		"[(bool)$b] = { booleanType() }",
		"[(boolean)$c] = { booleanType() }",
		"[(double)$g] = { floatType() }",
		"[(float)$f] = { floatType() }",
		"[(int)$d] = { integerType() }",
		"[(integer)$e] = { integerType() }",
		"[(object)$j] = { objectType() }", 
		"[(real)$h] = { floatType() }",
		"[(string)$i] = { stringType() }",
		"[(unset)$k] = { nullType() }",
		"[|php+globalVar:///a|] = { any() }",
		"[|php+globalVar:///b|] = { any() }",
		"[|php+globalVar:///c|] = { any() }",
		"[|php+globalVar:///d|] = { any() }",
		"[|php+globalVar:///e|] = { any() }",
		"[|php+globalVar:///f|] = { any() }",
		"[|php+globalVar:///g|] = { any() }",
		"[|php+globalVar:///h|] = { any() }",
		"[|php+globalVar:///i|] = { any() }",
		"[|php+globalVar:///j|] = { any() }",
		"[|php+globalVar:///k|] = { any() }"
	];
	return testConstraints("casts", expectedConstraints, expectedTypes);
}

public test bool testarrayType() {
	list[str] expectedConstraints = [
		// arrayType(); [];
		"[array()] = arrayType()",
		"[[]] = arrayType()",
		
		// arrayType("a", "b", "c");
		"[\"a\"] = stringType()", "[\"b\"] = stringType()", "[\"c\"] = stringType()",
		"[array(\"a\", \"b\", \"c\")] = arrayType([\"a\"], [\"b\"], [\"c\"])",
	
		// arrayType(0, "b", 3.4); 
		"[0] = integerType()", "[\"b\"] = stringType()", "[3.4] = floatType()",
		"[array(0, \"b\", 3.4)] = arrayType([\"b\"], [0], [3.4])",
		
		// [0,1,2];
		"[0] = integerType()", "[1] = integerType()", "[2] = integerType()", 
		"[[0,1,2]] = arrayType([0], [1], [2])",
		
		// $a[0];
		"[$a[0]] \<: any()", // not very specific!!!
		"[0] = integerType()",
		"[$a] \<: arrayType(any())",
		"[$a] \<: any()", 
		"neg([$a] \<: objectType())",
		
		// $b["def"]
		"[$b[\"def\"]] \<: any()", // not very specific!!!
		"[\"def\"] = stringType()",
		"[$b] \<: arrayType(any())",
		"[$b] \<: any()", 
		"neg([$b] \<: objectType())",
		
		// $c[0][0]
		"[$c[0][0]] \<: any()",
		"[0] = integerType()", "[0] = integerType()",
		"[$c] \<: arrayType(any())",
		"[$c] \<: any()", 
		"[$c[0]] \<: arrayType(any())",
		"[$c[0]] \<: any()",
		"neg([$c] \<: objectType())",
		"neg([$c[0]] \<: objectType())",
		
		// $d[] = 1;
		"[$d] \<: arrayType(any())",
		"[$d] \<: any()", 
		"[$d[]] \<: any()", 
		"neg([$d] \<: objectType())",
		"[1] = integerType()",
		//"[1] \<: [$d[]]",
		"[$d[]] = [1]",
		//"[$d[]] \<: [$d[] = 1]",
		"[$d[] = 1] = [$d[]]"
	];
	list[str] expectedTypes = [];
	return testConstraints("array", expectedConstraints, expectedTypes);
}

public test bool testVarious() {
	list[str] expectedConstraints = [
		// $a = clone($b);
		"[$a] \<: any()", 
		"[$a] \<: objectType()", 
		"[clone($a)] \<: objectType()",
		
		// new ABC();	
		"[new ABC()] = classType(|php+class:///abc|)",
		// new \DEF();	
		"[new \\DEF()] = classType(|php+class:///def|)",
		// new \GHI\JKL;	
		"[new \\GHI\\JKL] = classType(|php+class:///ghi/jkl|)",
		// new MNO\PQR;	
		"[new MNO\\PQR] = classType(|php+class:///qwerty/mno/pqr|)",
		
		// new $b();
		"[$b] \<: any()",
		"[new $b()] \<: objectType()",
		"or([$b] \<: objectType(), [$b] = stringType())"
	];
	list[str] expectedTypes = [];
	return testConstraints("various", expectedConstraints, expectedTypes);
}

public test bool testControlStructures() {
	list[str] expectedConstraints = [
		// if ($a1) {"10";}
		"[$a1] \<: any()", "[\"10\"] = stringType()", 
		// if ($b1) {"20";} else {"30";}
		"[$b1] \<: any()", "[\"20\"] = stringType()", "[\"30\"] = stringType()", 
		// if ($c1) {"40";} else if ("50") {$d1;} else {$e1;}
		// if ($c1) {"40";} elseif ("50") {$d1;} else {$e1;}
		"[$c1] \<: any()", 		"[$c1] \<: any()", 
		"[\"40\"] = stringType()",	"[\"40\"] = stringType()", 
		"[\"50\"] = stringType()",	"[\"50\"] = stringType()", 
		"[$d1] \<: any()",		"[$d1] \<: any()", 
		"[$e1] \<: any()",		"[$e1] \<: any()", 
		// if ($a2) "11";
		"[$a2] \<: any()", "[\"11\"] = stringType()", 
		// if ($b2) "21"; else "31";
		"[$b2] \<: any()", "[\"21\"] = stringType()", "[\"31\"] = stringType()", 
		// if ($c2) "41"; else if ("51") $d2; else $e2;
		"[$c2] \<: any()", "[$d2] \<: any()", "[$e2] \<: any()",
		"[\"41\"] = stringType()", "[\"51\"] = stringType()", 
		// if ($a1): "12"; endif;
		"[$a1] \<: any()", "[\"12\"] = stringType()", 
		
		// while($f1) { "60"; }
		"[$f1] \<: any()", "[\"60\"] = stringType()", 
		// while($f2)  "61";
		"[$f2] \<: any()", "[\"61\"] = stringType()", 
		// while ($f3): "62"; endwhile;	
		"[$f3] \<: any()", "[\"62\"] = stringType()", 
		
		// do { $g1; } while ($h1);
		"[$g1] \<: any()", "[$h1] \<: any()", 
		// do $g2; while ($h2);
		"[$g2] \<: any()", "[$h2] \<: any()", 
	
		// for ($i1=0; $i2<10; $i3++) { "70"; }	
		"[$i1] \<: any()", "[$i2] \<: any()", "[$i3] \<: any()", "[\"70\"] = stringType()", 
		// for ($i4; ;$i5) { "71"; }
		"[$i4] \<: any()", "[$i5] \<: any()", "[\"71\"] = stringType()", 
		// for (; ; ) { "72"; }
		"[\"72\"] = stringType()", 
		// for ($i6, $j7; $i8; $j9, $i11, $i12);
		"[$i6] \<: any()", "[$j7] \<: any()", "[$i8] \<: any()", 
		"[$j9] \<: any()", "[$i11] \<: any()", "[$i12] \<: any()", 
		
		// foreach ($k as $v) foreach ($kk as $vv) "80";
		"[$k] \<: any()", "[$v] \<: any()", 
		"[$kk] \<: any()", "[$vv] \<: any()", "[\"80\"] = stringType()", 
		// foreach ($arr as $key => $value) { "statement"; }
		"[$arr] \<: any()", "[$key] \<: any()", "[$value] \<: any()", "[\"statement\"] = stringType()",
		// foreach ($array as $element): "81"; endforeach;
		"[$array] \<: any()", "[$element] \<: any()", "[\"81\"] = stringType()", 
	
		// switch ($l2) { case 10; case "1str": "string"; break; default: "def"; }
		"[$l2] \<: any()", "[10] = integerType()", 
		"[\"1str\"] = stringType()", "[\"string\"] = stringType()", "[\"def\"] = stringType()", 
		// switch ($l2): case 20: "zero2"; break; case "2str": "string"; break; default: "def"; endswitch;	
		"[$l2] \<: any()", "[20] = integerType()", "[\"2str\"] = stringType()",
		"[\"zero2\"] = stringType()", "[\"string\"] = stringType()", "[\"def\"] = stringType()", 
		
		// declare(ticks=1) { $m; }
		"[$m] \<: any()",
		
		// goto a; 'Foo';  a: 'Bar';
		"[\'Foo\'] = stringType()", "[\'Bar\'] = stringType()",
		
		// try { $n1; } catch (\Exception $e) { $n2; };
		"[$n1] \<: any()", "[$n2] \<: any()",
		// try { $n3; } catch (\Exception $e) { $n4; } finally { $n5; };
		"[$n3] \<: any()", "[$n4] \<: any()", "[$n5] \<: any()"
	];
	list[str] expectedTypes = [];
	return testConstraints("controlStructures", expectedConstraints, expectedTypes);
}

public test bool testFunction() {
	list[str] expectedConstraints = [
		// function a() {}
		"[function a() {}] = nullType()",
		// function &b() {}
		"[function &b() {}] = nullType()",
		// function c() { return; }
		"or([function c() { return; }] = nullType())",
		// function d() { return true; return false; }
		"or([function d() { return true; return false; }] = [false], [function d() { return true; return false; }] = [true])",
		"[false] = booleanType()", "[true] = booleanType()",
		// function f() { function g() { return "string"; } }
		"[function f() { function g() { return \"string\"; } }] = nullType()",
		"or([function g() { return \"string\"; }] = [\"string\"])",
		"[\"string\"] = stringType()",
		
		// function h() { $a = "str"; $a = 100; }
		"[\"str\"] \<: [$a]",
		"[\"str\"] = stringType()",
		"[$a] \<: any()",
		"[$a] \<: any()",
		"[100] \<: [$a]",
		"[100] = integerType()",
		"[function h() { $a = \"str\"; $a = 100; }] = nullType()",
		"[$a] \<: [$a = \"str\"]",
		"[$a] \<: [$a = 100]",
		"[|php+functionVar:///h/a|] = [$a]",
		"[|php+functionVar:///h/a|] = [$a]",
		
		// function i() { $i = "str"; function j() { $i = 100; } }
		"[\"str\"] \<: [$i]",
		"[\"str\"] = stringType()",
		"[$i] \<: any()",
		"[$i] \<: any()",
		"[100] \<: [$i]",
		"[100] = integerType()",
		"[function i() { $i = \"str\"; function j() { $i = 100; } }] = nullType()",
		"[function j() { $i = 100; }] = nullType()",
		"[$i] \<: [$i = \"str\"]",
		"[$i] \<: [$i = 100]",
		"[|php+functionVar:///i/i|] = [$i]",
		"[|php+functionVar:///j/i|] = [$i]",
	
		// if (true) { function k() { $k1; } } else { function k() { $k2; } }	
		"[$k1] \<: any()",
		"[$k2] \<: any()",
		"[function k() { $k1; }] = nullType()",
		"[function k() { $k2; }] = nullType()",
		"[true] = booleanType()",
		
		// a();	
		"[a()] \<: [function a() {}]",
		// b();
		"[b()] \<: [function &b() {}]",
		// x(); // function does not exist
		"[x()] \<: any()",
		// no constraints.... function does not exists
		
		//$x(); // variable call
		"[$x()] \<: any()",
		"or([$x] \<: objectType(), [$x] = stringType())",
		"if ([$x] \<: objectType()) then (hasMethod([$x], __invoke))"
	];
	list[str] expectedTypes = [];
	return testConstraints("function", expectedConstraints, expectedTypes);
}

public test bool testClassMethod() {
	list[str] expectedConstraints = [
		// [public function m1() {}] = nullType()
		"[public function m1() {}] = nullType()",
		
		// class C2 { public function m2() { function f1() { return "a"; } return true; } }
		"[\"a\"] = stringType()", "[true] = booleanType()",
		"or([public function m2() { function f1() { return \"a\"; } return true; }] = [true])",
		"or([function f1() { return \"a\"; }] = [\"a\"])",
		
		// class C3 { public function m3() { $a = 2; function f1() { $a = "a"; } return $a; } }
		"[$a] \<: any()", "[$a] \<: any()", "[$a] \<: any()", // variables
		"[2] = integerType()", "[\"a\"] = stringType()",  // int/string
		"[2] \<: [$a]", "[\"a\"] \<: [$a]", // assignment
		"[$a] \<: [$a = 2]", "[$a] \<: [$a = \"a\"]", // result of assignment
		"or([public function m3() { $a = 2; function f1() { $a = \"a\"; } return $a; }] = [$a])", // type of method
		"[function f1() { $a = \"a\"; }] = nullType()", // type of function
		"[|php+methodVar:///ns/c3/m3/a|] = [$a]",
		"[|php+functionVar:///ns/f1/a|] = [$a]"
	];
	list[str] expectedTypes = [];
	return testConstraints("classMethod", expectedConstraints, expectedTypes);
}

public test bool testClassConstant() {
	list[str] expectedConstraints = [
		// class C1 { const c1 = 100; }
		"[c1 = 100] = [100]",
		"[100] = integerType()",
		"[|php+classConstant:///classconstant/c1/c1|] = [c1 = 100]",
		// class C2 { const c21 = 21, c22 = 22; }
		"[c21 = 21] = [21]",
		"[21] = integerType()",
		"[c22 = 22] = [22]",
		"[22] = integerType()",
		"[|php+classConstant:///classconstant/c2/c21|] = [c21 = 21]",
		"[|php+classConstant:///classconstant/c2/c22|] = [c22 = 22]",
		 //interface C3 { const cInterface = "interface constant"; }
		"[cInterface = \"interface constant\"] = [\"interface constant\"]",
		"[\"interface constant\"] = stringType()",
		"[|php+classConstant:///classconstant/c3/cInterface|] = [cInterface = \"interface constant\"]" 
	];
	list[str] expectedTypes = [];
	return testConstraints("classConstant", expectedConstraints, expectedTypes);
}

public test bool testClassProperty() {
	list[str] expectedConstraints = [
		// class cl1 { public $pub1; public $pub2 = 2; }
		"[2] = integerType()",
		"[$pub2 = 2] = [2]",
		"[|php+field:///randomnamespace/cl1/pub1|] = [$pub1]",
		"[|php+field:///randomnamespace/cl1/pub2|] = [$pub2 = 2]",
		// class cl2 { private $priv1; private $priv2 = 2; }
		"[2] = integerType()",
		"[$priv2 = 2] = [2]",
		"[|php+field:///randomnamespace/cl2/priv1|] = [$priv1]",
		"[|php+field:///randomnamespace/cl2/priv2|] = [$priv2 = 2]",
		// class cl3 { protected $pro1; protected $pro2 = 2; }
		"[2] = integerType()",
		"[$pro2 = 2] = [2]",
		"[|php+field:///randomnamespace/cl3/pro1|] = [$pro1]",
		"[|php+field:///randomnamespace/cl3/pro2|] = [$pro2 = 2]"
	];
	list[str] expectedTypes = [];
	return testConstraints("classProperty", expectedConstraints, expectedTypes);
}

public test bool testMethodCallStatic() {
	// information is retreived from m3, declares in uses
	list[str] expectedConstraints = [
		// if (true)
		"[true] = booleanType()",
		// class C { public static function d() {return true; } public function e() { $this::f(); } }
		"[public static function d() {}] = nullType()",
		"[public function e() { $this::f(); }] = nullType()",
		// $this
		"[$this] \<: any()",
		"[$this] \<: objectType()",
		"or([$this] :\> classType(|php+class:///c|), [$this] = classType(|php+class:///c|))",
		// f()
		"[f] = someMethod", // resolve all method
		"hasName([f], f)",
		"isItemOfClass([f], [$this])",
		// $this::f()
		
		// class C { public static function d() {} }
		"[public static function d() {}] = nullType()",
		
		//$c = c::d();
		"[$c] \<: [$c = c::d()]",
		"[$c] \<: any()",
		"[c::d()] \<: [$c]",
		"[c::d()] \<: [d]",
		"[c] \<: [class C { public static function d() {} public function e() { $this::f(); } }]",
		"[c] \<: [class C { public static function d() {} }]",
		"[c] \<: objectType()",
		"[d] = someMethod",
		"hasName([d], d)",
		"isItemOfClass([d], [c])",
	
		// $d = "d";
		"[$d] \<: any()",
		"[\"d\"] = stringType()",
		
		// $x = c::$d();	
		// c::d(); // static call of (static) method d of class c
		//"[c] \<: objectType()",
		//"[c] = (class(|php+class:///c|)",
		//"or(hasMethod([c], \"d\"), hasMethod([c], \"__callStatic\")",
		//"[c] \<: [class C { public static function d() {} }]",
		//"[public static function d() {}] = nullType()",
		//"or(hasMethod([$c], d, { static() })",
		// if LHS is of type: current class -> 
		// if LHS is of one of the parent classes ->
		""
    ];
	list[str] expectedTypes = [];
	return testConstraints("methodCallStatic", expectedConstraints, expectedTypes);
}

public test bool testClassKeywords() {
	// information is retreived from m3, declares in uses
	list[str] expectedConstraints = [
		// public function se() { self::foo(); }
		"[public function se() { self::foo(); }] = nullType()",
		"[self] = classType(|php+class:///ns/c|)",
		"[foo] = someMethod",
		//"or(hasMethod([self], foo, { static() }))",
		
		// public function pa() { parent::foo(); }
		"[public function pa() { parent::foo(); }] = nullType()",
		"or([parent] = classType(|php+class:///ns/p|))",
		"[foo] = someMethod",
		//"or(hasMethod([parent], foo, { static() }))",
		
		// public function st() { static::foo(); }	
		"[public function st() { static::foo(); }] = nullType()",
		"or([static] = classType(|php+class:///ns/c|), [static] = classType(|php+class:///ns/p|))"
		//"or(hasMethod([static], foo, { static() }))"
    ];
	list[str] expectedTypes = [];
	return testConstraints("classKeywords", expectedConstraints, expectedTypes);
}

public test bool testMethodCall() {
	// information is retreived from m3, declares in uses
	list[str] expectedConstraints = [
		// $a->b();
		//"[$a] \<: any()",
		//"or(hasMethod([$a], b, { !static() })",
		// class and method declaration information
		 //c::d(); // static call of (static) method d off class c
		//"[c] \<: objectType()",
		//"[c] \<: [class C { public static function d() {} }]",
		//"[public static function d() {}] = nullType()",
		//"or(hasMethod([$c], d, { static() })",
		// if LHS is of type: current class -> 
		// if LHS is of one of the parent classes ->
		""
    ];
	list[str] expectedTypes = [];
	return testConstraints("methodCall", expectedConstraints, expectedTypes);
}

public bool testConstraints(str fileName, list[str] expectedConstraints, list[str] expectedTypes)
{
	loc l = getFileLocation(fileName);
	//projectLocation = l;
	
	resetModifiedSystem(); // this is only needed for the tests
	System system = getSystem(l);
	M3 m3 = getM3ForSystem(system, l);
	system = getModifiedSystem();
	m3 = calculateAfterM3Creation(m3, system);

	set[Constraint] actual = getConstraints(system, m3);
	map[loc file, lrel[loc decl, loc location] vars] variableMapping = getVariableMapping();

	// for debugging purposes
	//printResult(fileName, expectedConstraints, actual);
	
	// assert that expectedConstraintsConstraints is equal to ActualConstraints
	bool test1 = comparePrettyPrintedConstraints(expectedConstraints, actual);
	if (!test1) {
		println("Constraints test failed..");
		return false;
	}

	if (!isEmpty(expectedTypes)) { // only test the types if they are provided; skip if they are not provided
    	map[TypeOf var, TypeSet possibles] solveResult = solveConstraints(constraints, variableMapping, m3, system);
    	bool test2 = comparePrettyPrintedTypes(expectedTypes, solveResult);
    
    	if (!test2) {
    		println("Solving constraints test failed..");
    		return false;
    	}
	} 
	
	return true;
}

//
// Compare pretty printed constraints (to make it readable for humans)
//
private bool comparePrettyPrintedConstraints(list[str] expectedConstraints, set[Constraint] actual) 
{
	list[str] actualPP = [ toStr(a) | a <- actual ];
	return comparePrettyPrinted(expectedConstraints, actualPP);
}

//
// Compare pretty printed constraints
//
private bool comparePrettyPrintedTypes(list[str] expectedTypes, map[TypeOf, TypeSet] actual) {
	// FOR NOW: when actual is empty, do not perform this test
	if (isEmpty(expectedTypes)) return true;
	
	list[str] actualPP = [ toStr(a) + " = " + toStr(actual[a]) | a <- actual ];
	
	return comparePrettyPrinted(expectedTypes, actualPP);
}

private bool comparePrettyPrinted(list[str] e, list[str] a) {
	a = sort(a);
	e = sort(e);
	
	notInActual = e - a;
	notInExpected = a - e;	
	
	if (!isEmpty(notInActual) || !isEmpty(notInExpected))	
	{
		iprintln("Actual: <a>");
		iprintln("Expected: <e>");
		iprintln("Correct:");
		for (correct <- (((e+a)-notInActual)-notInExpected)) println(correct);
		iprintln("(- = Not in actual)");
		for (nia <- notInActual) { print("- "); println(nia); }
		iprintln("(+ = Not in expected)");
		for (nie <- notInExpected) { print("+ "); println(nie); }
	}
	
	return a == e;
}


//
// Printer functions:
//

private void printResult(str fileName, list[str] expectedConstraints, set[Constraint] actual)
{
	loc l = getFileLocation(fileName);
	
	for (f <- l.ls) {
		println();
		println("----------File Content: <f>----------");
		if (isFile(f)) println(readFile(f)); else println("<f>");
		println();
	}
	println("---------------- Actual: -------------------");
	for (a <- actual) println(toStr(a));
	println("--------------------------------------------");
	println();
	println("--------------- Expected: ------------------");
	for (e <- expectedConstraints) println(e);
	println("--------------------------------------------");
	println();
}

// Pretty Print the constraints
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
private str toStr(isAMethod(TypeOf t))					= "<toStr(t)> = someMethod";
private str toStr(isAFunction(TypeOf t))				= "<toStr(t)> = someFunction";
private str toStr(isItemOfClass(TypeOf t, TypeOf t2))	= "isItemOfClass(<toStr(t)>, <toStr(t2)>)";
private str toStr(hasName(TypeOf t, str n))				= "hasName(<toStr(t)>, <n>)";
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