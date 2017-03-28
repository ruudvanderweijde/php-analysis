module ParserTest

import ParseTree;
import Node;
import IO;

//lexical Preserved = p: "Test";
lexical Word = w: ("@" [a-z A-Z]+);

keyword KW
	//= "@ABC" | "@DEF"
	= "@DEF" | "@ABC"
	;
	
syntax PreservedOrWord
	= abc: "@ABC"
	| def: "@DEF"
	> twee: Word \ "@ABC" | "@DEF"
	//> twee: Word \ KW
	;
	
public void main() {
    tryToParse(#PreservedOrWord, "@BC"); 
    tryToParse(#PreservedOrWord, "@ABC"); 
    tryToParse(#PreservedOrWord, "@DEF"); 
    tryToParse(#PreservedOrWord, "@abc"); 
}

public void tryToParse(type[&T<:Tree] t, str input)
{
    try 
    {
        println(getName(parse(t, input))); 
        println(implode(#node, parse(t, input))); 
        //node n = implode(#node, parse(t, input)); 
        //println("<t> :: \"<input>\" :: parsed. Type == <getName(n)>, <expectedType> expected");
    } 
    catch ParseError(loc l):
        println("<t> :: \"<input>\" :: failed to parse.");
    catch : 
        println("<t> :: \"<input>\" :: UNKNOWN ERROR, AMBIGOUS");
} 