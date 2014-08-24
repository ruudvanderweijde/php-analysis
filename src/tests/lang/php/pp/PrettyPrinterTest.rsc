module tests::lang::php::pp::PrettyPrinterTest
// note: the down side of this test is that it is hard to automate this test, 
// because different inputs (of the same semantic value) can have a general pretty print.

import lang::php::ast::AbstractSyntax;
import lang::php::ast::System;
import lang::php::pp::PrettyPrinter;
import lang::php::util::Config;
import lang::php::util::Utils;

import IO;
import List;
import String;
import Map;

private loc srcFolder = parserLoc + "PHP-Parser/test/code/parser";
private loc outputFolder = analysisLoc + "src/tests/resources/pp";
private str ppFileExtension = "phppp";
// these files fail to parse, ignore them
private list[str] ignoreFiles = [ "constant_expr.test", "assign.test", "int.test", "generator.test", "constantString.test" ];

// To run the tests, run: main();
public void main() {
	createPrettyPrintFiles();
	System phpFiles = loadPHPFiles(outputFolder, addLocationAnnotations = false, addUniqueIds = false, extensions = { "php" });
	System prettyPrintedFiles = loadPHPFiles(outputFolder, addLocationAnnotations = false, addUniqueIds = false, extensions = { "phppp" });

	System errors = (l : prettyPrintedFiles[l] | l <- prettyPrintedFiles, errscript(_) := prettyPrintedFiles[l]);
	if (!isEmpty(errors)) {
		printParseErrors(errors);
		throw "Unable to parse certain pretty printed files:";
	}
	
	// try to print
	for(l <- prettyPrintedFiles) {
		str expected = readFile(l);
		str actual = pp(prettyPrintedFiles[l]);
		if (expected != actual) {
			if (replaceAll(replaceAll(expected, "\n", ""), " ", "") == replaceAll(replaceAll(actual, "\n", ""), " ", "")) {
				println("Warning: different number of new lines or spaces for: <l>");	
			} else {
				println("Pretty printed file does not equal the parsed file. File: <l>");
				iprintln(expected);
				iprintln("- expected ^ | v actual -");
				iprintln(actual);
				println("--------------------");
			}
		}
	}
	
}

@doc { parse test files and pretty print them, (create php+phppp files) }
public void createPrettyPrintFiles() 
{
	if (isEmpty(outputFolder.ls)) {
		createPhpFilesFromPhpParserTestFiles();
	}
	
	System system = loadPHPFiles(outputFolder);
	for (fileLoc <- system) {
		loc prettyPrintedFile = phpFileToPp(fileLoc); 
		str prettyPrintedCode = pp(system[fileLoc]);
		
		writeFile(prettyPrintedFile, prettyPrintedCode);	
	}
}

@doc{ read PHP-Parser parser test files to create test files for pretty print }
private void createPhpFilesFromPhpParserTestFiles() 
{
	logMessage("Create php test files from PHP-Parser parser test files...", 2);
	for (file <- getPhpParserTestFiles()) {
		writeCodeFromTestFileToPhpFile(file);
	}
	logMessage("Done.", 2);
}

private loc phpFileToPp(loc f) = toLocation("<f>"[1..][0..-5]+".<ppFileExtension>");

private void writeCodeFromTestFileToPhpFile(loc l) {
	list[str] lines = readFileLines(l);
	
	str title = top(lines);
	lines = pop(lines)[1];
	
	str out = getCodeFromFile(lines);
	loc f = outputFolder + "<l.parent.file>_<replaceAll(title, " ", "")>.php";
	writeFile(f, out);	
}

private list[loc] getPhpParserTestFiles() = removeIgnored(crawl(srcFolder, "test"));
private list[loc] removeIgnored(list[loc] files) = [ f | f <- files, !(f.file in ignoreFiles) ];
private list[loc] getPhpSourceFiles() = crawl(outputFolder, "php");
private list[loc] getPrettyPrintedFiles() = crawl(outputFolder, ppFileExtension);


private list[loc] crawl(loc dir, str suffix){
  res = [];
  for(str entry <- listEntries(dir)){
      loc sub = dir + entry;   
      if(isDirectory(sub)) {
          res += crawl(sub, suffix);
      } else {
	      if(endsWith(entry, suffix)) { 
	         res += [sub]; 
	      }
      }
  };
  return res;
}

@doc {
format of test file:

Title
-----
code(1)
-----
result(1)
-----
code(2)
-----
result(2)
-----
code(3)
-----
result(3)


What we want is:

code(1)
code(2)
code(3)

}
private str getCodeFromFile(list[str] lines) {
	str startToken = "-----";
	list[list[str]] tests = [];
	list[str] \test = [];
	
	for (line <- lines) {
		if (line == startToken) {
			tests += [\test];
			\test = [];
		} else {
			\test += [line];
		}
	}
	
	// only get the code , discard the rest
	str out = "";
	for (strings <- tests[1,3..]) {
		for (string <- strings) {
			out += string + "\n";
		}
	}
	
	return out;
}

private void printParseErrors(System system) 
{
	println("Run:");
	println("import lang::php::pp::PrettyPrinter;");
	println("import lang::php::util::Utils;");
	for (l <- errors) {
		println("-----------------");
		println("-----------------");
		println("ReadFile :: readFile(<l[file=l.file[..-2]]>)");
		println("PrettyPrintFile :: print(pp(loadPHPFile(<l[file=l.file[..-2]]>)))");
		println("-----------------");
		println("<readFile(l[file=l.file[..-2]])>");
		println("-----------------");
		println("<pp(loadPHPFile(l[file=l.file[..-2]]))>");
	}
}