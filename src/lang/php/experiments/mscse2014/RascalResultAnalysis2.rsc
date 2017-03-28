module lang::php::experiments::mscse2014::RascalResultAnalysis2

import Prelude;
import util::Math;

import lang::php::util::Utils;
import lang::php::util::Corpus;

import lang::php::ast::System;
import lang::php::ast::AbstractSyntax;
import lang::php::util::Config;
import lang::php::m3::FillM3;
import lang::php::m3::Declarations;
import lang::php::m3::Containment;
import lang::php::pp::PrettyPrinter;
import lang::php::types::TypeSymbol;
import lang::php::types::TypeConstraints;


private map[str,str] resultCorpus = (
	
	// sorted in LOC (all are enabled except for Werkspot and Symfony)
	//"doctrine_lexer": "v1.0", // 1
	//"sebastianbergmann_php-timer": "1.0.5", // 2 
	//"sebastianbergmann_php-text-template": "1.2.0", // 3
	//"doctrine_inflector": "v1.0", // 4
	"php-fig_log": "1.0.0" // 5
	//"sebastianbergmann_php-file-iterator": "1.3.4" // 6
	
	//"symfony_Filesystem": "v2.5.3", // 7
	//"doctrine_collections": "v1.2"
	
	//"symfony_Yaml": "v2.5.3", // 8
	//"sebastianbergmann_php-token-stream": "1.2.2", // 9
	//, // 10
	//"symfony_Process": "v2.5.3", // 11
	//"symfony_Finder": "v2.5.3", // 12
	//"symfony_DomCrawler": "v2.5.3", // 13
	//"symfony_Translation": "v2.5.3", // 14
	//"symfony_Console": "v2.5.3", // 15
	//"symfony_HttpFoundation": "v2.5.3", // 16
	//"fabpot_Twig": "v1.16.0", // 17
	//"symfony_EventDispatcher": "v2.5.3", // 18
	//"swiftmailer_swiftmailer": "v5.2.1", // 19
	//"sebastianbergmann_php-code-coverage": "2.0.10", // 20
	//"sebastianbergmann_phpunit": "4.2.2", // 21
	//"sebastianbergmann_phpunit-mock-objects": "2.2.0", // 22
	//"doctrine_annotations": "v1.2.0", // 23
	//"doctrine_common": "v2.4.2", // 24
	//"symfony_HttpKernel": "v2.5.3", // 25
	//"doctrine_cache": "v.1.3.0", // 26
	//"doctrine_dbal": "v2.4.2", // 27
	//"guzzle_guzzle3": "v3.9.2", // 28 
	//"doctrine_doctrine2": "v2.4.4", // 29
	//"Seldaek_monolog": "1.10.0" // 30
);

public void main()
{
	printTableHeader([
		"w/o PHPDoc",
		"w/ PHPDocs"
	]);
	printTableRows([
    	"anaysis_results_without_docblock_without_phpfunctions.txt",
    	"anaysis_results_with_docblock_without_phpfunctions.txt",
    	"anaysis_results_with_docblock_with_phpfunctions.txt" // only here to align total
    	
	]);
	printTableFooter(
		"Type inference results, with and without PHPDocs", 
		"results:rascal_results_docblocks"
	);
	
	println("\n\n\n\n\n");
	
	printTableHeader([
		"w/o Built-ins",
		"w/ Built-ins"
	]);
	printTableRows([
	    "anaysis_results_with_docblock_without_phpfunctions.txt",
    	"anaysis_results_with_docblock_with_phpfunctions.txt",
    	"anaysis_results_without_docblock_without_phpfunctions.txt" // only here to align total
    ]);
	printTableFooter(
		"Results of type usage, with and without PHP built-ins", 
		"results:rascal_results_built-ins"
	);
	
	println("\n\n\n\n\n");
	
	printBarChart(
		"Analysis results comparison", 
		[
			"anaysis_results_without_docblock_without_phpfunctions.txt",
    		"anaysis_results_with_docblock_without_phpfunctions.txt",
    		"anaysis_results_with_docblock_with_phpfunctions.txt"
    	]
	);
}

private void printTableRows(list[str] fileNames)
{
	for (c <- resultCorpus) {
		loc baseLocation = corpusRoot + "/<c>";
		lrel[int total, int unresolved, map[int numberOfTypes, int amount] resolvedTypes] results = [];
		
		for (fileName <- fileNames) {
			map[loc, set[TypeSymbol]] analysisResult = readResultsFromFile(baseLocation + fileName);
			
			int numberOfUnresolved = size([ 1 | key <- analysisResult, \any() in analysisResult[key]]);
			
			map[loc, set[TypeSymbol]] resolvedItems = (key:analysisResult[key] | key <- analysisResult, \any() notin analysisResult[key] );
			map[int, int] possibleTypesPerCount = getPossibleTypesCount(resolvedItems);
			
			results += <size(analysisResult), numberOfUnresolved, possibleTypesPerCount>;
		}
	
		// preconditions:
		assert size(results) == 3;

		// print product name
		str name = replaceAll(c, "_", " ");
		str productName = substring(name, findFirst(name, " ")+1);
		
		// totals results
		int total1 = results[0].total;
		int total2 = results[1].total;
		int total3 = results[2].total;
		assert total1 == total2 && total2 == total3;
				
		// unresolved items 
		int unresolved1 = results[0].unresolved;
		real unresolved1Percentage = round(100 * unresolved1 / toReal(total1), 0.1);
		int unresolved2 = results[1].unresolved;
		real unresolved2Percentage = round(100 * unresolved2 / toReal(total2), 0.1);
		int unresolved3 = results[2].unresolved;
		real unresolved3Percentage = round(100 * unresolved2 / toReal(total3), 0.1);		
		
		// resolved items 
		int resolved1 = total1 - unresolved1;
		real resolved1Percentage = round(100 * resolved1 / toReal(total1), 0.1);
		int resolved2 = total2 - unresolved2;
		real resolved2Percentage = round(100 * resolved2 / toReal(total2), 0.1);

		println("\t\t\t<productName> &");			
		println("\t\t\t\\numprint{<max(total1, max(total2, total3))>} & % total");
		
		print("\t\t\t");
		print("\\numprint{<resolved1>} & ");
		print("\\numprint{<resolved2>} \\\\ ");
		println();
	}
}

@doc { based on: http://en.wikipedia.org/wiki/Relative_change_and_difference }
public real difference(real y1, real y2)
{
	if (y1 == 0 && y2 == 0) return 0.; // prevent error
	
	real diff = (y1 - y2);
	//real diff = ( (y1 - y2) / ( (y1 + y2) / 2 ) ) * 100;
	//real diff = ( (y1 - y2) / ( max(y1 , y2) / 2 ) ) * 100;
	
	return round(diff, 0.1);
}

private int getAmountOfSingleSolutions(map[int, int] possibleTypesPerCount)
{
	try return sum(range(domainR(possibleTypesPerCount, {1})));
	catch ArithmeticException: return 0; 
}
private int getAmountOfMultipleSolutions(map[int, int] possibleTypesPerCount)
{
	try return sum(range(domainX(possibleTypesPerCount, {0,1})));
	catch ArithmeticException: return 0; 
}
private int getAmountOfNoResultSolutions(map[int, int] possibleTypesPerCount)
{
	try return sum(range(domainR(possibleTypesPerCount, {0})));
	catch ArithmeticException: return 0; 
}

private void printTableHeader(list[str] headings)
{
    println("\\npaddmissingzero");
    println("\\npfourdigitsep");
    println("\\begin{table}[H]");
    println("\t\\centering");
    println("\t\\scriptsize");
    println("\t\\begin{tabular}{@{}lr|rr@{}} ");
    println("\t\t\\toprule");
    println("\t\t\t& &");
    println("\t\t\t\\multicolumn{2}{c}{Resolved types} \\\\");
    println("\t\t\t");
    println("\t\t\tProject & Total &");
    println("\t\t\t<headings[0]> &");
    println("\t\t\t<headings[1]> \\\\");
    println("\t\t\\midrule");
}

private void printTableFooter(str caption, str label)
{
	println("\t\t\\bottomrule");
	println("\t\\end{tabular}");
	println("\t\\normalsize");
	println("\\caption{<caption>\\label{table:<label>}}");
	println("\\end{table}");
	println("\\npfourdigitnosep");
	println("\\npnoaddmissingzero");
}

private void printBarChart(str caption, list[str] fileNames)
{
	println("\\pgfplotstableread[col sep=comma,header=false]{");
	list[str] productNames = [];
	
	// warning duplicate code!!
	for (c <- resultCorpus) {
		loc baseLocation = corpusRoot + "/<c>";
		lrel[int total, int unresolved, map[int numberOfTypes, int amount] resolvedTypes] results = [];
		
		for (fileName <- fileNames) {
			map[loc, set[TypeSymbol]] analysisResult = readResultsFromFile(baseLocation + fileName);
			
			int numberOfUnresolved = size([ 1 | key <- analysisResult, \any() in analysisResult[key]]);
			
			map[loc, set[TypeSymbol]] resolvedItems = (key:analysisResult[key] | key <- analysisResult, \any() notin analysisResult[key] );
			map[int, int] possibleTypesPerCount = getPossibleTypesCount(resolvedItems);
			
			results += <size(analysisResult), numberOfUnresolved, possibleTypesPerCount>;
		}
	
		// preconditions:
		assert size(results) == 3;

		// print product name
		str name = replaceAll(c, "_", " ");
		str productName = substring(name, findFirst(name, " ")+1);
		
		// totals results
		int total1 = results[0].total;
		int total2 = results[1].total;
		int total3 = results[2].total;
				
		// unresolved items 
		int unresolved1 = results[0].unresolved;
		real unresolved1Percentage = round(100 * unresolved1 / toReal(total1), 0.1);
		int unresolved2 = results[1].unresolved;
		real unresolved2Percentage = round(100 * unresolved2 / toReal(total2), 0.1);
		int unresolved3 = results[2].unresolved;
		real unresolved3Percentage = round(100 * unresolved2 / toReal(total3), 0.1);		
		
		// resolved items 
		int resolved1 = total1 - unresolved1;
		int resolved1Percentage = round(100 * resolved1 / toReal(total1));
		int resolved2 = total2 - unresolved2;
		int resolved2Percentage = round(100 * resolved2 / toReal(total2));
		int resolved3 = total3 - unresolved3;
		int resolved3Percentage = round(100 * resolved3 / toReal(total3));
		
		println("\t<productName>,<resolved1Percentage>,<resolved2Percentage>,<resolved3Percentage>");
		productNames = push(productName, productNames);
	}
	
	//println("\tlexer,66,78,72");
	//println("\tphp-timer,4,42,77");
	//println("\tphp-text-template,13,37,70");
	//println("\tinflector,74,79,77");
	//println("\tlog,14,41,61");
	//println("\tphp-file-iterator,14,30,55");
	println("}\\data");

	println("\\pgfplotsset{");
	println("\tpercentage plot/.style={");
	println("\t\tpoint meta=explicit,");
	println("\t\tyticklabel=\\pgfmathprintnumber{\\tick}\\,$\\%$,");
	println("\t\tymin=0,");
	println("\t\tymax=100,");
	println("\t\tenlarge y limits={upper,value=0},");
	println("\t\tvisualization depends on={y \\as \\originalvalue}");
	println("\t},");
	println("\tpercentage series/.style={");
	println("\t\ttable/y expr=\\thisrow{#1},table/meta=#1");
	println("\t}");
	println("}");

	println("\\begin{figure}");
	println("\\begin{tikzpicture}");
	println("\\begin{axis}[");
	println("\taxis on top,");
	println("\twidth=16cm,");
	println("\theight=7cm,");
	println("\tylabel=Percentage of resolved items,");
	println("\txlabel=,");
	println("\tpercentage plot,");
	println("\tybar,");
	println("\tbar width=0.5cm,");
	println("\tenlarge x limits=0.12,");
	println("\tcycle list={");
	println("\t\t{fill=black!10,draw=black,postaction={pattern=crosshatch dots}},");
	println("\t\t{fill=black!30,draw=black,postaction={pattern=north east lines}},");
	println("\t\t{fill=black!50,draw=black,postaction={pattern=crosshatch}}");
	println("\t},");
	println("\tlegend style={");
    println("\t\tcolumn sep=0.5cm,");
    println("\t\t/tikz/every odd column/.append style={column sep=0cm},");
	println("\t\tat={(0.43,-0.50)},");
	println("\t\tanchor=north,");
	println("\t\tlegend columns=-1");
	println("\t},");
    println("\tlegend image code/.code={%");
    println("\t\t\\draw[#1] (0cm,-0.1cm) rectangle (0.6cm,0.1cm);");
    println("\t\t},");
	println("\tmajor grid style=white,");
	println("\tsymbolic x coords={<intercalate(",", reverse(productNames))>},");
	println("\txtick=data,");
	println("\tnodes near coords,");
	println("\tnodes near coords align={vertical},");
	println("\tx tick label style={rotate=45,anchor=east}");
	println("]");
	println("\\addplot table [percentage series=1] {\\data};");
	println("\\addplot table [percentage series=2] {\\data};");
	println("\\addplot table [percentage series=3] {\\data};");
	println("\\legend{normal,w/ phpdoc, w/ built-ins}");
	println("\\end{axis}");
	println("\\end{tikzpicture}");
	println("\\caption{Comparison of the results\\label{chart:results-comparison}}");
	println("\\end{figure}");
	

}

public map[loc, set[TypeSymbol]] readResultsFromFile(loc source) 
{
	return mapMap(readTextValueFile(#map[TypeOf var, TypeSet possibles], source));
}

public map[loc, set[TypeSymbol]] mapMap(map[TypeOf, TypeSet] oldMap)
{
	map[loc, set[TypeSymbol]] newMap = ();
	
	for (i:typeOf(l) <- oldMap) {
		if (/^php+/ := l.scheme) {
			newMap[l] = typeSetToSetOfTypeSymbols(oldMap[i]);
		}
	}
	
	newMap = filterInternalPhpResults(newMap);
	
	return newMap;
}

private set[TypeSymbol] typeSetToSetOfTypeSymbols(Universe()) = {\any()};
private set[TypeSymbol] typeSetToSetOfTypeSymbols(EmptySet()) = {};
private set[TypeSymbol] typeSetToSetOfTypeSymbols(Root()) = {\any()};
private set[TypeSymbol] typeSetToSetOfTypeSymbols(Single(TypeSymbol T)) = {T};
private set[TypeSymbol] typeSetToSetOfTypeSymbols(Set(set[TypeSymbol] Ts)) = Ts;

public map[int, int] getPossibleTypesCount(map[loc, set[TypeSymbol]] inputMap)
{
	rel[int, loc] itemsPerLoc = { <size(inputMap[key]), key> | key <- inputMap };
	map[int, set[loc]] newMap = toMap(itemsPerLoc);
	
	return (key : size(newMap[key]) | key <- newMap);
}

public map[loc, set[TypeSymbol]] filterInternalPhpResults(map[loc, set[TypeSymbol]] input)
{  
	map[loc, set[TypeSymbol]] output = ();

	for (i <- input) {
		// not in list of php internal functions AND does not have 'php_internals' as directory
		if (!isBuiltIn(i)) {
			output[i] = input[i];
		}
	}

	return output;
}