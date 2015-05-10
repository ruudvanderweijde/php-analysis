module lang::php::experiments::mscse2014::ResultsAnalysis

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

private map[str,str] resultCorpus = (
	
	// sorted in LOC (all are enabled except for Werkspot and Symfony)
	"doctrine_lexer": "v1.0", // 1
	"sebastianbergmann_php-timer": "1.0.5", // 2 
	"sebastianbergmann_php-text-template": "1.2.0", // 3
	"doctrine_inflector": "v1.0", // 4
	"php-fig_log": "1.0.0", // 5
	"sebastianbergmann_php-file-iterator": "1.3.4", // 6
	//"symfony_Filesystem": "v2.5.3", // 7
	//"symfony_Yaml": "v2.5.3", // 8
	"sebastianbergmann_php-token-stream": "1.2.2", // 9
	"doctrine_collections": "v1.2", // 10
	//"symfony_Process": "v2.5.3", // 11
	//"symfony_Finder": "v2.5.3", // 12
	//"symfony_DomCrawler": "v2.5.3", // 13
	//"symfony_Translation": "v2.5.3", // 14
	//"symfony_Console": "v2.5.3", // 15
	//"symfony_HttpFoundation": "v2.5.3", // 16
	"fabpot_Twig": "v1.16.0", // 17
	//"symfony_EventDispatcher": "v2.5.3", // 18
	"swiftmailer_swiftmailer": "v5.2.1", // 19
	"sebastianbergmann_php-code-coverage": "2.0.10", // 20
	"sebastianbergmann_phpunit": "4.2.2", // 21
	"sebastianbergmann_phpunit-mock-objects": "2.2.0", // 22
	"doctrine_annotations": "v1.2.0", // 23
	"doctrine_common": "v2.4.2", // 24
	//"symfony_HttpKernel": "v2.5.3", // 25
	"doctrine_cache": "v.1.3.0", // 26
	"doctrine_dbal": "v2.4.2", // 27
	"guzzle_guzzle3": "v3.9.2", // 28 
	"doctrine_doctrine2": "v2.4.4", // 29
	"Seldaek_monolog": "1.10.0" // 30
	//"WerkspotNoTests":"oldWebsiteNoTests"
);

//private list[str] fileNames = [
//    "resolved_types_with_docblock_src_only.txt",
//    "resolved_types_without_docblock_src_only.txt",
//	"resolved_types_with_docblock_all.txt",
//    "resolved_types_without_docblock_all.txt"
//];

public void main()
{
	printTableHeader();
	printTableRows([
    	"resolved_types_without_docblock_src_only.txt",
    	"resolved_types_with_docblock_src_only.txt"
	]);
	printTableFooter("Results of type usage, source folder only", "results:source_only");

	printTableHeader();
	printTableRows([
    	"resolved_types_without_docblock_all.txt",
		"resolved_types_with_docblock_all.txt"
	]);
	printTableFooter("Results of type usage, including vendor folder", "results:with_vendor");
}

public void printTableRows(list[str] fileNames)
{
	for (c <- resultCorpus) {
		loc baseLocation = toLocation("file:///PHPAnalysis/systems/<c>/");
		lrel[int total, int unresolved, map[int numberOfTypes, int amount] resolvedTypes] results = [];
		//if (c != "Seldaek_monolog") continue; // for testing purposes
			
		for (fileName <- fileNames) {
			map[loc, set[TypeSymbol]] analysisResult = readResultsFromFile(baseLocation + fileName);
			//println("Total number of items: <size(analysisResult)>");
			
			int numberOfUnresolved = size([ 1 | key <- analysisResult, \any() in analysisResult[key]]);
			//println("Number of unresolved: <numberOfUnresolved>");
			
			map[loc, set[TypeSymbol]] resolvedItems = (key:analysisResult[key] | key <- analysisResult, \any() notin analysisResult[key] );
			map[int, int] possibleTypesPerCount = getPossibleTypesCount(resolvedItems);
			
			results += <size(analysisResult), numberOfUnresolved, possibleTypesPerCount>;
		}
		
		// preconditions:
		assert size(results) == 2;
		//assert results[0].total == results[1].total : "<results[0].total> is not equal to <results[1].total>";
		if (results[0].total != results[1].total) continue; // don't show the results
		
		// print product name
		str name = replaceAll(c, "_", " ");
		str productName = substring(name, findFirst(name, " ")+1);
		println("\t\t\t<productName> &");
		
		// print results
		int total = results[0].total;
			
		print("\t\t\t\\numprint{<total>} & ");
		
		// unresolved items (with percentage)
		int unresolved1 = results[0].unresolved;
		int unresolved2 = results[1].unresolved;
		print("\\numprint{<unresolved1>} & ");
		//print("(<100 * unresolved1 / total>\\%) & ");
		print("\\numprint{<unresolved2>} & ");
		//print("(<100 * unresolved2 / total>\\%) & ");
		print("(<difference(unresolved2, unresolved1)>\\%) & ");
		println("");
		
		// unique items (with percentage)
		int unique1 = getAmountOfSingleSolutions(results[0].resolvedTypes);
		int unique2 = getAmountOfSingleSolutions(results[1].resolvedTypes);
		print("\t\t\t\\numprint{<unique1>} &");
		//print("(<100 * unique1 / total>\\%) &");
		print("\\numprint{<unique2>} &");
		//print("(<100 * unique2 / total>\\%) &");
		print("(<difference(unique2, unique1)>\\%) &");
		println("");
		// 
		
		int otherCount1 = total - unresolved1 - unique1;
		int otherCount2 = total - unresolved2 - unique2;
		print("\t\t\t\\numprint{<otherCount1>} &");
		//print("(<100 * otherCount1 / total>\\%) &");
		print("\\numprint{<otherCount2>} &");
		//print("(<100 * otherCount2 / total>\\%) \\\\");
		print("(<difference(otherCount2, otherCount1)>\\%) \\\\");
		println("");
	}
}

@doc { based on: http://en.wikipedia.org/wiki/Relative_change_and_difference }
public int difference(int x1, int x2)
{
	if (x1 == 0 && x2 == 0) return 0; // prevent error
	
	real y1 = toReal(x1);
	real y2 = toReal(x2);
	
	real diff = ( (y1 - y2) / ( max(y1 , y2) / 2 ) ) * 100;
	
	return round(diff);
}

private int getAmountOfSingleSolutions(map[int, int] possibleTypesPerCount)
{
	int singleSolutions = 0;
	if (1 in possibleTypesPerCount) {
		singleSolutions = possibleTypesPerCount[1];
	}
	return singleSolutions;
}

public void printTableHeader()
{
    println("\\npaddmissingzero");
    println("\\npfourdigitsep");
    println("\\begin{table}[H]");
    println("\t\\centering");
    println("\t\\scriptsize");
    println("\t\\begin{tabular}{@{}lr|rrl|rrl|rrl@{}} ");
    println("\t\t\\toprule");
    println("\t\t\t& &");
    println("\t\t\t\\multicolumn{3}{c}{Unresolved types} &");
    println("\t\t\t\\multicolumn{6}{c}{Resolved types} \\\\");
    println("\t\t\t");
    println("\t\t\t& &");
    println("\t\t\t\\multicolumn{3}{c}{} &");
    println("\t\t\t\\multicolumn{3}{c}{Unique types} &");
    println("\t\t\t\\multicolumn{3}{c}{Multiple types} \\\\ ");
    println("\t\t\t");
    println("\t\t\tProduct & Total &");
    println("\t\t\t\\multicolumn{1}{c}{w/o doc} &");
    println("\t\t\t\\multicolumn{1}{c}{with doc} &");
    println("\t\t\t\\multicolumn{1}{c}{$\\Delta$} |&");
    println("\t\t\t\\multicolumn{1}{c}{w/o doc} &");
    println("\t\t\t\\multicolumn{1}{c}{with doc} &");
    println("\t\t\t\\multicolumn{1}{c}{$\\Delta$} |&");
    println("\t\t\t\\multicolumn{1}{c}{w/o doc} & ");
    println("\t\t\t\\multicolumn{1}{c}{with doc} &");
    println("\t\t\t\\multicolumn{1}{c}{$\\Delta$} \\\\");
    println("\t\t\\midrule");
}

public void printTableFooter(str caption, str label)
{
	println("\t\t\\bottomrule");
	println("\t\\end{tabular}");
	println("\t\\normalsize");
	println("\\caption{<caption>\\label{table:<label>}}");
	println("\\end{table}");
	println("\\npfourdigitnosep");
	println("\\npnoaddmissingzero");
}

public map[loc, set[TypeSymbol]] readResultsFromFile(loc source) 
{
	return makeMap(readTextValueFile(#rel[loc, set[TypeSymbol]], source));
}

public map[loc, set[TypeSymbol]] makeMap(rel[loc, set[TypeSymbol]] oldRel)
{
	map[loc, set[set[TypeSymbol]]] newMap = toMap(oldRel);
	
	// union is done to get one set, instead of sets of sets
	return (key : union(newMap[key]) | key <- newMap);
}

public map[int, int] getPossibleTypesCount(map[loc, set[TypeSymbol]] inputMap)
{
	rel[int, loc] itemsPerLoc = { <size(inputMap[key]), key> | key <- inputMap };
	map[int, set[loc]] newMap = toMap(itemsPerLoc);
	
	return (key : size(newMap[key]) | key <- newMap);
}