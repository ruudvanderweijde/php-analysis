module lang::php::experiments::mscse2014::ValueIOTests

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
import util::Math;

@doc{ This file is added for rascal testing purposes }
public void main()
{
	testIn();
	exit();
	testAverageFormula();
	exit();
	mapCountTest();
	exit();
	tryToReadFromFile();
	exit();
	// test to map
	rel[loc, set[TypeSymbol]] testSet1 = {
		<|file:///abc|, {\any()}>,
		<|file:///abc|, {stringType()}>,
		<|file:///abc|, {integerType(),scalarType()}>
	};
	iprintln(testSet1);
	iprintln(toMap(testSet1));
	map[loc, set[set[TypeSymbol]]] testMap1 = toMap(testSet1);
	iprintln(testMap1);
	map[loc, set[TypeSymbol]] testMap2 = (key : union(testMap1[key]) | key <- testMap1);
	iprintln(testMap2);
	exit();
	
	// temp test: try to read results
	map[loc, set[TypeSymbol]] x = (
		|file:///abc|: {\any()},
		|php+class:///phpcs_sniffs_controlstructures_controlsignaturesniff|:{classType(|php+object:///phpcs_sniffs_controlstructures_controlsignaturesniff|)},
		|php+method:///phpcs_sniffs_controlstructures_controlsignaturesniff/__construct|:{classType(|php+object:///phpcs_sniffs_controlstructures_controlsignaturesniff|)},
		|php+method:///phpcs_sniffs_controlstructures_controlsignaturesniff/__construct|:{classType(|php+object:///phpcs_sniffs_controlstructures_controlsignaturesniff|)},
		|php+method:///phpcs_sniffs_controlstructures_controlsignaturesniff/getPatterns|:{arrayType(\any())}
	);
	// test 1: read from binary file
	loc binFile = |file:///tmp/file.bin|;
	writeBinaryValueFile(binFile, x);
	map[loc,set[TypeSymbol]] output = readBinaryValueFile(#map[loc, set[TypeSymbol]], binFile);
	println(output);
	
	// test 2: read from normal file
	loc textFile = |file:///tmp/file.txt|;
	writeTextValueFile(textFile, x);
	map[loc,set[TypeSymbol]] test2Result = readTextValueFile(#map[loc, set[TypeSymbol]], textFile);
	iprintln(test2Result);
	
	// test 3: read output of analysis file
	loc resultsFile = |file:///Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-timer/results-without-docblock/resolvedTypes.txt|;
	map[loc,set[TypeSymbol]] results = readTextValueFile(#map[loc, set[TypeSymbol]], resultsFile);
	iprintln(results);
	
	
}

public void testIn()
{
	map[loc, set[TypeSymbol]] testSet1 = (
		|file:///abc0|: {arrayType(\any())},
		|file:///abc1|: {\any()},
		|file:///abc2|: {stringType()},
		|file:///abc3|: {integerType(),scalarType()},
		|file:///abc4|: {\any(),arrayType(\any())},
		|file:///abc5|: {\any(),\any()},
		|file:///abc6|: {\any(),stringType()},
		|file:///abc7|: {\any(),integerType(),scalarType()}
	);
	println("true == any() in testSet1");
	println(true == \any() in testSet1);
	println("true == any() notin testSet1");
	println(true == \any() notin testSet1);
	
	map[loc, set[TypeSymbol]] resolvedItems = (key:testSet1[key] | key <- testSet1, \any() notin testSet1[key] );
	println("resolvedItems: <resolvedItems>");
}

public void mapCountTest()
{
	source = |file:///Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-timer/resolved_types_without_docblock_all.txt|;
	map[loc, set[TypeSymbol]] someMap = makeMap(readTextValueFile(#rel[loc, set[TypeSymbol]], source));
	rel[int, loc] itemsPerLoc = { <size(someMap[key]), key> | key <- someMap };
	map[int, set[loc]] newMap = toMap(itemsPerLoc);
	iprintln((key : size(newMap[key]) | key <- newMap));
}

public void tryToReadFromFile() 
{
	source = |file:///Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-timer/resolved_types_without_docblock_all.txt|;
	iprintln(makeMap(readTextValueFile(#rel[loc, set[TypeSymbol]], source)));
	println("----------------------------------------");
	source = |file:///Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-timer/resolved_types_with_docblock_all.txt|;
	iprintln(makeMap(readTextValueFile(#rel[loc, set[TypeSymbol]], source)));
	println("----------------------------------------");
	source = |file:///Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-timer/resolved_types_without_docblock_src_only.txt|;
	iprintln(makeMap(readTextValueFile(#rel[loc, set[TypeSymbol]], source)));
	println("----------------------------------------");
	source = |file:///Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-timer/resolved_types_with_docblock_src_only.txt|;
	iprintln(makeMap(readTextValueFile(#rel[loc, set[TypeSymbol]], source)));
	println("----------------------------------------");
}

public map[loc, set[TypeSymbol]] makeMap(rel[loc, set[TypeSymbol]] oldRel)
{
	map[loc, set[set[TypeSymbol]]] newMap = toMap(oldRel);
	
	// union is done to get one set, instead of sets of sets
	return (key : union(newMap[key]) | key <- newMap);
}


public int difference(int x1, int x2)
{
	// based on: http://www.calculatorsoup.com/calculators/algebra/percent-difference-calculator.php
	real y1 = toReal(x1);
	real y2 = toReal(x2);
	
	real diff = ( (y1 - y2) / ( (y1 + y2) / 2 ) ) * 100;
	
	int rounded = round(diff);
	
	return (x1 < x2) ? -rounded : rounded;
}


public real formula1 (real y1, real y2) = ( (y1 - y2) / ( (y1 + y2) / 2 ) ) * 100;
public real formula2 (real y1, real y2) = ( (y1 - y2) / ( max(y1 , y2) / 2 ) ) * 100;
public real formula3 (real y1, real y2) = ( (y1 - y2) / ( y1 / 2 ) ) * 100;
public void testAverageFormula() {
	lrel[real, real] numbersToTest = [
		<0.,0.>,
		<0.,1.>,
		<1.,0.>,
		<1.,1.>,
		<2.,1.>,
		<1.,2.>,
		<2.,3.>,
		<3.,2.>,
		<3.,1.>,
		<1.,3.>,
		<5.,8.>,
		<8.,5.>,
		<2.,10.>,
		<10.,2.>,
		<10.,10.>
	];
	
	for (<l,r> <- numbersToTest) {
		println("\n\nTesting with number: <l> and <r>");
		//println("formula1: <formula1(l,r)>");
		println("formula2: <formula2(l,r)>");
		//println("formula3: <formula3(l,r)>");
	}
}