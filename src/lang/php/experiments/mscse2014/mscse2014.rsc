module lang::php::experiments::mscse2014::mscse2014

import IO;
import Relation;
import Set;
import String;
import ValueIO;

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

import lang::php::experiments::mscse2014::ConstraintExtractor;
import lang::php::experiments::mscse2014::ConstraintSolver;
import lang::php::experiments::mscse2014::ResultDataType;
import lang::php::experiments::mscse2014::ResultAnalysis;

//loc projectLocation = |file:///PHPAnalysis/systems/WerkspotNoTests/WerkspotNoTests-oldWebsiteNoTests/plugins/wsCorePlugin/modules/craftsman/lib|;
//loc projectLocation = |file:///PHPAnalysis/systems/WerkspotNoTests/WerkspotNoTests-oldWebsiteNoTests/plugins/wsCorePlugin/modules/craftsman|;
//loc projectLocation = |file:///PHPAnalysis/systems/WerkspotNoTests/WerkspotNoTests-oldWebsiteNoTests/|;
//loc projectLocation = |file:///PHPAnalysis/systems/Kohana|;
//loc projectLocation = |file:///Users/ruud/git/php-analysis/src/tests/resources/experiments/mscse2014/variable|;
loc projectLocation = |file:///PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0|; // latest
//loc projectLocation = |file:///tmp/Calculator|;
//loc projectLocation = |file:///PHPAnalysis/systems/doctrine_common/doctrine_common-v2.4.2|;
//loc projectLocation = |file:///Users/ruud/test/types|;
//loc projectLocation = |file:///Users/ruud/tmp/solve/scalar|;

private loc getProjectLocation() = projectLocation;
private void setProjectLocation(loc pl) { projectLocation = pl; }

loc cacheFolder = |file:///Users/ruud/tmp/m3/|;
loc finalM3CacheFile = cacheFolder + "final_m3_<projectLocation.file>.bin";

loc getLastM3CacheFile() = cacheFolder + "<getProjectLocation().file>_m3_last.bin";
loc getModifiedSystemCacheFile() = cacheFolder + "<getProjectLocation().file>_system_last.bin";
loc getLastConstraintsCacheFile() = cacheFolder + "<getProjectLocation().file>_constraints_last.bin";
loc getLastResultsCacheFile() = cacheFolder + "<getProjectLocation().file>_results_last.bin";
loc getParsedSystemCacheFile() = cacheFolder + "<getProjectLocation().file>_system_parsed.bin";


private map[str,str] corpus = (
	
	// sorted in LOC
	"doctrine_lexer": "v1.0", // 1
	"sebastianbergmann_php-timer": "1.0.5", // 2 
	"sebastianbergmann_php-text-template": "1.2.0", // 3
	"doctrine_inflector": "v1.0", // 4
	"php-fig_log": "1.0.0", // 5
	"sebastianbergmann_php-file-iterator": "1.3.4", // 6
	"symfony_Filesystem": "v2.5.3" // 7
	//"symfony_Yaml": "v2.5.3", // 8
	//"sebastianbergmann_php-token-stream": "1.2.2", // 9
	//"doctrine_collections": "v1.2", // 10
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
	//"WerkspotNoTests":"oldWebsiteNoTests"
);

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
private str textStep1 = "1) Run run1() to parse the files (and save the parsed files to the cache)";
private str textStep2 = "2) Run run2() to create the m3 (and save system and m3 to cache)";
private str textStep3 = "3) Run run3() to collect constraints (and save the constraints to cache)";
private str textStep4 = "4) Run run4() to solve the constraints (and write results to cache)";
private str textStep5 = "5) Run run5() to print the results";

public void main() {
	println("Run instructions: (current selected project: `<projectLocation>`)");
	println("----------------");
	println(textStep1);
	println(textStep2);
	println(textStep3);
	println(textStep4);
	println(textStep5);
	println("----------------");
	println("Or runAll() with a project location, like:");
	//println(" ⤷ runAll(|file:///Users/ruud/git/php-analysis/test|);");
	//println(" ⤷ runAll(|file:///PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0|);");
	//println(" ⤷ runAll(|file:///PHPAnalysis/systems/sebastianbergmann_php-timer/sebastianbergmann_php-timer-1.0.5|);");
	//println(" ⤷ runAll(|file:///PHPAnalysis/systems/sebastianbergmann_php-text-template/sebastianbergmann_php-text-template-1.2.0|);");
	//println(" ⤷ runAll(|file:///PHPAnalysis/systems/sebastianbergmann_php-file-iterator/sebastianbergmann_php-file-iterator-1.3.4|);");
	//println(" ⤷ runAll(|file:///PHPAnalysis/systems/php-fig_log/php-fig_log-1.0.0|);");
	//println(" ⤷ runAll(|file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1|); (=pretty big!!!)");
	
	for (c <- resultCorpus) {
		if (!isFile(toLocation("file:///PHPAnalysis/systems/<c>/anaysis_results_without_docblock.txt"))) {
			println(" ⤷ runAll(|file:///PHPAnalysis/systems/<c>/<c>-<resultCorpus[c]>|);");
			//break;
		}
	}
	
}

public void runAll(loc project) {

	projectLocation = project;
	//projectLocation = |file:///PHPAnalysis/systems/sebastianbergmann_php-timer/sebastianbergmann_php-timer-1.0.5|; // latest
	//projectLocation = |file:///tmp/Calculator|;
	//projectLocation	= |file:///tmp/tst01|;
	run1();
	run2();
	run3();
	run4();
	run5();
	//printSubTypeGraph();

}

public void run1() {
	logMessage(textStep1, 1);
	
	resetModifiedSystem(); // this is only needed when running multiple tests
	logMessage("Run 1 [1/2] :: parsing php files to ASTs...", 1);
	System system = getSystem(getProjectLocation(), false); // useCache = false
	logMessage("Run 1 [2/2] :: writing parsed system to cache...", 1);
	writeBinaryValueFile(getParsedSystemCacheFile(), system);
	
	println("The scripts are now parsed into ASTs. Please run run2() now.");
}

public void run2() {
	// precondition: plain parsed system file should exists for this project
	assert isFile(getParsedSystemCacheFile()) : "Please run run1() first. Error: file(<getParsedSystemCacheFile()>) was not found";
	
	logMessage(textStep2, 1);
	logMessage("Run 2 [1/5] :: Reading parsed system from cache...", 1);
	System system = readBinaryValueFile(#System, getParsedSystemCacheFile());
	
	resetModifiedSystem(); // this is only needed when running multiple tests
	
	logMessage("Run 2 [2/5] :: create M3 for system...", 1);
	M3 m3 = getM3ForSystem(system);
	
	logMessage("Run 2 [3/5] :: get modified system...", 1);
	system = getModifiedSystem(); // for example the script is altered with scope information
	
	logMessage("Run 2 [4/5] :: calculate after m3 creation...", 1);
	m3 = calculateAfterM3Creation(m3, system);

	logMessage("Run 2 [5/5] :: writing system and m3 to filesystem", 1);	
	writeBinaryValueFile(getLastM3CacheFile(), m3);
	writeBinaryValueFile(getModifiedSystemCacheFile(), system);
	
	//printSubTypeGraph();
	logMessage("M3 and System are written to the file system. Please run run3() now.",1);
}

public void run3() {
	// precondition: system and m3 cache file must exist
	assert isFile(getModifiedSystemCacheFile()) : "Please run run2() first. Error: file(<getModifiedSystemCacheFile()>) was not found";
	assert isFile(getLastM3CacheFile())     	: "Please run run2() first. Error: file(<getLastM3CacheFile()>) was not found";
	
	logMessage(textStep3, 1);
	logMessage("Reading system from cache...", 1);
	System system = readBinaryValueFile(#System, getModifiedSystemCacheFile());
	logMessage("Reading M3 from cache...", 1);
	M3 m3 = readBinaryValueFile(#M3, getLastM3CacheFile());
	logMessage("Reading done.", 1);

	set[Constraint] constraints = getConstraints(system, m3);
	
	logMessage("Writing contraints to the file system", 1);
	writeBinaryValueFile(getLastConstraintsCacheFile(), constraints);
	logMessage("Writing done. Now please run run4()", 1);
	println("To view the constraints run:\n1) import ValueIO;\n2) import lang::php::types::TypeSymbol;\n3) import lang::php::types::TypeConstraints;\n4) constraints = readBinaryValueFile(#set[Constraint], <getLastConstraintsCacheFile()>);");

	// not sure yet, if this is the way to go... because there 
	//
	//logMessage("Populate classes with implementation of extended classes and implemented interfaces...", 1);
	//rel[loc,loc] propagatedContainment 
	//	= globalM3@containment
	//	+ getPropagatedExtensions(globalM3)
	//	+ getPropagatedImplementations(globalM3)
	//	;

	// print m3 info
	//printDuplicateDeclInfo(globalM3);
	

	//iprintln(globalM3@constructors);
	//iprintln(globalM3@modifiers);
	//iprintln(size(globalM3@modifiers));
}

public void run4()
{
	// precondition: constraints and m3 cache file must exist
	assert isFile(getModifiedSystemCacheFile())  : "Please run run2() first. Error: file(<getModifiedSystemCacheFile()>) was not found";
	assert isFile(getLastConstraintsCacheFile()) : "Please run run3() first. Error: file(<getLastConstraintsCacheFile()>) was not found";
	assert isFile(getLastM3CacheFile())          : "Please run run3() first. Error: file(<getLastM3CacheFile()>) was not found";
	
	logMessage(textStep4, 1);
	logMessage("Reading system from cache...", 1);
	System system = readBinaryValueFile(#System, getModifiedSystemCacheFile());
	logMessage("Reading constraints from cache...", 1);
	set[Constraint] constraints = readBinaryValueFile(#set[Constraint], getLastConstraintsCacheFile());
	logMessage("Reading M3 from cache...", 1);
	M3 m3 = readBinaryValueFile(#M3, getLastM3CacheFile());
	logMessage("Reading done.", 1);

	logMessage("Now solving the constraints...", 1);	
	map[TypeOf var, TypeSet possibles] solveResult = solveConstraints(constraints, getVariableMapping(), m3, system);
	logMessage("Writing the results of the constraint solving", 1);
	writeBinaryValueFile(getLastResultsCacheFile(), solveResult);
	logMessage("Writing done. Now please run run5()", 1);
}

public void run5() {
	assert isFile(getLastResultsCacheFile())  : "Please run run4() first. Error: file(<getLastResultsCacheFile()>) was not found";
	
	logMessage(textStep5, 1);
	
	logMessage("Reading solve results from cache...", 1);
	map[TypeOf var, TypeSet possibles] solveResult = readBinaryValueFile(#map[TypeOf var, TypeSet possibles], getLastResultsCacheFile());
	logMessage("Reading system from cache...", 1);
	System system = readBinaryValueFile(#System, getModifiedSystemCacheFile());
	logMessage("Reading M3 from cache...", 1);
	M3 m3 = readBinaryValueFile(#M3, getLastM3CacheFile());
	
	for (key <- solveResult) {
		println("<toStr(key)> :: <key>");	
		println("\t⤷ " + toStr(solveResult[key]));	
	}
	println("\n\nIn short format:");
    for (key <- solveResult) {
		println("<toStr(key)> :: <toStr(solveResult[key])>");	
	}
	
	println("--------------------------------------");
	counters = getNumberOfPossibleItems(solveResult, setSubTypes(m3, system));
	loc analysisResultOutputFile = getProjectLocation() + "../anaysis_results_without_docblock.txt";
	logMessage("Writing output to file <analysisResultOutputFile>.", 2);
	writeTextValueFile(analysisResultOutputFile, solveResult);
	logMessage("Writing done.", 2);
	//iprintln(counters);
}

private M3 getM3ForSystem(System system)
{
	logMessage("Get M3 [1/2] :: create M3 per file", 1);
	M3Collection m3s = getM3CollectionForSystem(system, getProjectLocation());
	
	logMessage("Get M3 [2/2] :: create global M3", 1);
	M3 globalM3 = M3CollectionToM3(m3s, getProjectLocation());
	
	return globalM3;
}

// implement overloading (fields, methods and constants)
public rel[loc,loc] getPropagatedExtensions(M3 m3) 
{
	rel[loc,loc] extSet = {};
	
	for (<base,extends> <- m3@extends+) {
		// add the fields, methods and constants of the parent class to the 'base' class
		//extSet += { <base, ext[path=base.path+"/"+ext.file]> | ext <- m3@containment[extends] };
		extSet += { <base, ext> | ext <- m3@containment[extends] };
	}
	
	return extSet;
}

// implement intefaces (constants and methods)
public rel[loc,loc] getPropagatedImplementations(M3 m3) 
{
	rel[loc,loc] implSet = {};
	
	for (<base, implements> <- m3@implements) {
		// add the interface implementation to the base class
		//implSet += { <base, impl[path=base.path+"/"+impl.file]> | impl <- m3@containment[implements] };
		implSet += { <base, impl> | impl <- m3@containment[implements] };
	}
	
	return implSet;
}

// Helper methods, maybe remove this some at some moment
// Display number of duplicate classnames or classpaths (path is namespace+classname)
public void printDuplicateDeclInfo() = printDuplicateDeclInfo(readBinaryValueFile(#M3, finalM3CacheFile));
public void printDuplicateDeclInfo(M3 m3)
{
	// provide some cache:
	writeBinaryValueFile(finalM3CacheFile, m3);
	
	set[loc] classes = { d | <d,_> <- m3@declarations, isClass(d) };
	printMap("class", infoToMap(classes));
	
	set[loc] interfaces = { d | <d,_> <- m3@declarations, isInterface(d) };
	printMap("interfaces", infoToMap(interfaces));
	
	set[loc] traits = { d | <d,_> <- m3@declarations, isTrait(d) };
	printMap("trait", infoToMap(traits));
	
	set[loc] mixed = { d | <d,_> <- m3@declarations, isClass(d) || isInterface(d) || isTrait(d) };
	printMap("mixed", infoToMap(mixed));
	
	rel[str className, loc decl, loc fileName] t = { <d.file,d,f> | <d,f> <- m3@declarations, isClass(d) || isInterface(d) || isTrait(d) };
	iprintln({ x | x <- t, size(domainR(t, {x.className})) > 1});
}

public void printMap(str name, map[str, int] info) {
	println("------------------------------------");
	println("Total number of <name> decls: <info["total"]>");
	println("Unique <name> paths: <info["uniquePaths"]> (<(info["uniquePaths"]*100)/info["total"]>%)");
	println("Unique <name> names: <info["uniqueNames"]> (<(info["uniqueNames"]*100)/info["total"]>%)");
}

public map[str, int] infoToMap(set[loc] decls) 
	= (
		"total" : size(decls),
		"uniquePaths" : 	size({ d.path | d <- decls }),
		"uniqueNames" : 	size({ d.file | d <- decls })
	);

public void printIncludeScopeInfo() {
	// precondition: system and m3 cache file must exist
	assert isFile(getModifiedSystemCacheFile()) : "Please run run1() first. Error: file(<getModifiedSystemCacheFile()>) was not found";
	
	logMessage("Reading system from cache...", 1);
	System system = readBinaryValueFile(#System, getModifiedSystemCacheFile());	
	
	rel[loc, loc, IncludeType] includeInScope = {};
	for (s <- system) {
		println(s);
		visit(system[s]) {
			case i:include(_,t): 
				includeInScope += { <i@at, i@scope, t> };
		}
	}
		
	println("all scopes (<size(includeInScope)>):");
	iprintln(domain(includeInScope));
}

public void run1ForAll() {
	loc projectLoc;	
	for(c <- corpus) {
		setProjectLocation(toLocation("file:///PHPAnalysis/systems/<c>/<c>-<corpus[c]>"));
		if (isFile(getParsedSystemCacheFile())) {
			println("Skipped! If you want to recreate the files, please remove this file: <getParsedSystemCacheFile()>");	
		} else {
			println("Run1 for location: <getProjectLocation()>");
			run1();
		}
	}
}	

public void run2ForAll() {
	loc projectLoc;	
	for(c <- corpus) {
		setProjectLocation(toLocation("file:///PHPAnalysis/systems/<c>/<c>-<corpus[c]>"));
		if (isFile(getModifiedSystemCacheFile()) && isFile(getLastM3CacheFile())) {
			println("Skipped! If you want to recreate the files, please remove these files: <getModifiedSystemCacheFile()> and <getLastM3CacheFile()>");
		} else {
			println("Run2 for location: <getProjectLocation()>");
			run2();
		}
	}
}	

public void run3ForAll() {
	loc projectLoc;	
	for(c <- corpus) {
		setProjectLocation(toLocation("file:///PHPAnalysis/systems/<c>/<c>-<corpus[c]>"));
		
		// run unconditionally.
	//	if (isFile(getModifiedSystemCacheFile()) && isFile(getLastM3CacheFile())) {
	//		println("Skipped! If you want to recreate the files, please remove these files: <getModifiedSystemCacheFile()> and <getLastM3CacheFile()>");
	//	} else {
			println("Run3 for location: <getProjectLocation()>");
			run3();
	//	}
	}
}	

public void printIncludeScopeInfoForAll() {
	loc projectLoc;	
	for(c <- corpus) {
		setProjectLocation(toLocation("file:///PHPAnalysis/systems/<c>"));
		println("Running printIncludeScopeInfoFor <getProjectLocation()>");
		printIncludeScopeInfo();
	}
}	

public void printSubTypeGraph()
{
	assert isFile(getModifiedSystemCacheFile()) : "Please run run2() first. Error: file(<getModifiedSystemCacheFile()>) was not found";
	assert isFile(getLastM3CacheFile())     	: "Please run run2() first. Error: file(<getLastM3CacheFile()>) was not found";
	
	logMessage("Reading system from cache...", 1);
	System system = readBinaryValueFile(#System, getModifiedSystemCacheFile());
	logMessage("Reading M3 from cache...", 1);
	M3 m3 = readBinaryValueFile(#M3, getLastM3CacheFile());
	logMessage("Reading done.", 1);
	
	subtypes = setSubTypes(m3, system);
	
	displaySubTypes(subtypes);
}