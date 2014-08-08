module lang::php::experiments::mscse2014::ConstraintsTest
extend lang::php::experiments::mscse2014::Constraints;
extend lang::php::experiments::mscse2014::mscse2014;

import lang::php::types::TypeConstraints;
import lang::php::util::Config;

import Set; // toList
import List; // sort

loc getFileLocation(str name) = analysisLoc + "/src/tests/resources/experiments/mscse2014/<name>/";
loc getFileLocationFull(str name) = getFileLocation(name) + "/<name>.php";

public void main()
{
	// trigger all tests
	assert true == testVariable();
	assert true == testNormalAssign();
	assert true == testScalars();
	assert true == testOpAssign();
	assert true == testUnaryOp();
	assert true == testBinaryOp();
}

public test bool testVariable() {
	str name = "variable";
	list[str] expected = [
		"[$a] \<: any()"
	];
	return run(name, expected);
}
public test bool testNormalAssign() {
	list[str] expected = [
		"[2] \<: [$a]",
		"[2] = int()",
		"[$a] \<: [$b]",
		"[$a] \<: any()", // twice because the variable occurs at two different places
		"[$a] \<: any()", 
		"[$b] \<: any()"
	];
	return run("normalAssign", expected);
}
public test bool testScalars() {
	list[str] expected = [
		// magic constants -> string()
		"[__CLASS__] = string()", "[__DIR__] = string()", "[__FILE__] = string()", "[__FUNCTION__] = string()", 
		"[__LINE__] = string()", "[__METHOD__] = string()", "[__NAMESPACE__] = string()", "[__TRAIT__] = string()",
		// floats -> float()
		"[0.0] = float()", "[0.5] = float()", "[1000.0382] = float()",
		// int -> int()
		"[0] = int()", "[1] = int()", "[2] = int()", "[10] = int()", "[100] = int()",
		// strings -> string()
		"[\"string\"] = string()", "[\'also a string\'] = string()", "[\"$encaped string\"] = string()", "[\"{$encaped} string\"] = string()"
	];
	return run("scalar", expected);
}

public test bool testOpAssign() {
	list[str] expected = [
		// LHS = int()
		"[$a] \<: any()", "[$b] \<: any()", "[$a] = int()", // $a  &= $b
		"[$c] \<: any()", "[$d] \<: any()", "[$c] = int()", // $c  |= $d
		"[$e] \<: any()", "[$f] \<: any()", "[$e] = int()", // $e  ^= $f
		"[$g] \<: any()", "[$h] \<: any()", "[$g] = int()", // $g  %= $h
		"[$i] \<: any()", "[$j] \<: any()", "[$i] = int()", // $i <<= $j
		"[$k] \<: any()", "[$l] \<: any()", "[$k] = int()", // $k >>= $l
	
		// LHS = string()	
		"[$m] \<: any()", "[$n] \<: any()", "[$m] = string()", // $m .= $n
	
		// LHS = int, RHS != array()	
		"[$o] \<: any()", "[$p] \<: any()", "[$o] = int()", "neg([$p] = array(any()))", // $o /= $p
		"[$q] \<: any()", "[$r] \<: any()", "[$q] = int()", "neg([$r] = array(any()))", // $q -= $r
	
		// LHS = int || float => LHS <: float()	
		"[$s] \<: any()", "[$t] \<: any()", "[$s] \<: float()", // $s *= $t
		"[$u] \<: any()", "[$v] \<: any()", "[$u] \<: float()"  // $u += $v
	];
	return run("opAssign", expected);
}

public test bool testUnaryOp() {
	list[str] expected = [
		"[$a] \<: any()",
		"[+$a] \<: float()", // expression is float or int
		"neg([$a] = array(any()))", // $a is not an array
		
		"[$b] \<: any()",
		"[-$b] \<: float()", // expression is float or int
		"neg([$b] = array(any()))", // $b is not an array
		
		"[$c] \<: any()", 
		"[!$c] = bool()", 
		
		"[$d] \<: any()", 
		"or([$d] = float(), [$d] = int(), [$d] = string())", 
		"or([~$d] = int(), [~$d] = string())", 
		
		"[$e] \<: any()",
		"if([$e] = array(any())) then ([$e++] = array(any()))",
		"if([$e] = bool()) then ([$e++] = bool())",
		"if([$e] = float()) then ([$e++] = float())",
		"if([$e] = int()) then ([$e++] = int())",
		"if([$e] = null()) then (or([$e++] = int(), [$e++] = null()))",
		"if([$e] \<: object()) then ([$e++] \<: object())",
		"if([$e] = resource()) then ([$e++] = resource())",
		"if([$e] = string()) then (or([$e++] = float(), [$e++] = int(), [$e++] = string()))",
		
		"[$f] \<: any()",
		"if([$f] = array(any())) then ([$f--] = array(any()))",
		"if([$f] = bool()) then ([$f--] = bool())",
		"if([$f] = float()) then ([$f--] = float())",
		"if([$f] = int()) then ([$f--] = int())",
		"if([$f] = null()) then (or([$f--] = int(), [$f--] = null()))",
		"if([$f] \<: object()) then ([$f--] \<: object())",
		"if([$f] = resource()) then ([$f--] = resource())",
		"if([$f] = string()) then (or([$f--] = float(), [$f--] = int(), [$f--] = string()))",
		
		"[$g] \<: any()",
		"if([$g] = array(any())) then ([++$g] = array(any()))",
		"if([$g] = bool()) then ([++$g] = bool())",
		"if([$g] = float()) then ([++$g] = float())",
		"if([$g] = int()) then ([++$g] = int())",
		"if([$g] = null()) then ([++$g] = int())",
		"if([$g] \<: object()) then ([++$g] \<: object())",
		"if([$g] = resource()) then ([++$g] = resource())",
		"if([$g] = string()) then (or([++$g] = float(), [++$g] = int(), [++$g] = string()))",
		
		"[$h] \<: any()",
		"if([$h] = array(any())) then ([--$h] = array(any()))",
		"if([$h] = bool()) then ([--$h] = bool())",
		"if([$h] = float()) then ([--$h] = float())",
		"if([$h] = int()) then ([--$h] = int())",
		"if([$h] = null()) then ([--$h] = int())",
		"if([$h] \<: object()) then ([--$h] \<: object())",
		"if([$h] = resource()) then ([--$h] = resource())",
		"if([$h] = string()) then (or([--$h] = float(), [--$h] = int(), [--$h] = string()))"
	];
	return run("unaryOp", expected);
}


public test bool testBinaryOp() {
	list[str] expected = [
		"[$a] \<: any()", "[$b] \<: any()",
		"or([$a + $b] \<: float(), [$a + $b] = array(any()))", // always array, or subtype of float()
		"if(and([$a] = array(any()), [$b] = array(any()))) then ([$a + $b] = array(any()))", // ($a = array && $b = array) => [E] = array
		"if(or(neg([$a] = array(any())), neg([$b] = array(any())))) then ([$a + $b] \<: float())", // ($a != array || $b = array) => [E] <: float 
		""
	];
	return run("binaryOp", expected);
}

public bool run(str fileName, list[str] expected)
{
	loc l = getFileLocation(fileName);
	
	System system = getSystem(l, false);
	M3 m3 = getM3ForSystem(system, false);

	set[Constraint] actual = getConstraints(system, m3);

	// for debugging purposes
	//printResult(fileName, expected, actual);
	
	// assert that expectedConstraints is a subset of ActualConstraints
	return comparePrettyPrinted(expected, actual);
}

//
// Assert pretty printed
//
private bool comparePrettyPrinted(list[str] expected, set[Constraint] actual) 
{
	list[str] actualPP = [ toStr(a) | a <- actual ];

	a = sort(actualPP);
	e = sort(expected);
	
	notInActual = a - e;
	notInExpected = e - a;	
	
	if (!isEmpty(notInActual) || !isEmpty(notInExpected))	
	{
		iprintln("Actual: <a>");
		iprintln("Expected: <e>");
		iprintln("Not in actual:");
		for (nia <- notInActual) println(nia);
		iprintln("Not in expected:");
		for (nie <- notInExpected) println(nie);
	}
	
	return a == e;
}


//
// Printer functions:
//

private void printResult(str fileName, list[str] expected, set[Constraint] actual)
{
	println();
	println("----------File Content: <fileName>----------");
	println(readFile(getFileLocationFull(fileName)));
	println();
	println("---------------- Actual: -------------------");
	for (a <- actual) println(toStr(a));
	println("--------------------------------------------");
	println();
	println("--------------- Expected: ------------------");
	for (e <- expected) println(e);
	println("--------------------------------------------");
	println();
}

// Pretty Print the constraints
private str toStr(eq(TypeOf a, TypeOf b)) 			= "<toStr(a)> = <toStr(b)>";
private str toStr(eq(TypeOf a, TypeSymbol ts)) 		= "<toStr(a)> = <toStr(ts)>";
private str toStr(subtyp(TypeOf a, TypeOf b)) 		= "<toStr(a)> \<: <toStr(b)>";
private str toStr(subtyp(TypeOf a, TypeSymbol ts)) 	= "<toStr(a)> \<: <toStr(ts)>";
private str toStr(disjunction(set[Constraint] cs))	= "or(<intercalate(", ", sort([ toStr(c) | c <- sort(toList(cs))]))>)";
private str toStr(exclusiveDisjunction(set[Constraint] cs))	= "xor(<intercalate(", ", sort([ toStr(c) | c <- sort(toList(cs))]))>)";
private str toStr(conjunction(set[Constraint] cs))	= "and(<intercalate(", ", sort([ toStr(c) | c <- sort(toList(cs))]))>)";
private str toStr(negation(Constraint c)) 			= "neg(<toStr(c)>)";
private str toStr(conditional(Constraint c, Constraint res)) = "if(<toStr(c)>) then (<toStr(res)>)";
default str toStr(Constraint c) { throw "Please implement toStr for node :: <c>"; }

private str toStr(typeOf(loc i)) 	= isFile(i) ? "["+readFile(i)+"]" : "[<i>]";
private str toStr(TypeSymbol t) 	= "<t>";
default str toStr(TypeOf to) { throw "Please implement toStr for node :: <to>"; }