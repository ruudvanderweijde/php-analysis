module ParserTest2

import ParseTree;
import Node;
import IO;

syntax A = "a";
	
public void main() {
	iprintln(parse(#A,"a"));
	//== appl(prod(sort("A"),[lit("a")],{}),[appl(prod(lit("a"),[\char-class([range(97,97)]),[char(97)])]);
    //tryToParse(#Exp, "1+2*3"); 
    //tryToParse(#Exp, "1+2[3]"); 
    //tryToParse(#Exp, "3!"); 
    //tryToParse(#Exp, "1*3!"); 
    //tryToParse(#Exp, "1+[2*3]"); 
}

public void tryToParse(type[&T<:Tree] t, str input)
{
    try 
    {
        println(getName(parse(t, input))); 
        println(delAnnotationsRec(implode(#node, parse(t, input)))); 
        //println("<t> :: \"<input>\" :: parsed. Type == <getName(n)>, <expectedType> expected");
    } 
    catch ParseError(loc l):
        println("<t> :: \"<input>\" :: failed to parse.");
    catch : 
        println("<t> :: \"<input>\" :: UNKNOWN ERROR, AMBIGOUS??");
} 