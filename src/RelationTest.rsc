module RelationTest

import Relation;
import IO;

public void main()
{
	set[int] leafs = {2,3,5};
	rel[int, int] relation = {<1,2>,<1,3>,<3,4>,<3,5>};
	
	for (x <- leafs) {
		iprintln(x);
		removeThis = invert(relation)[x];
	  	leafs = leafs - removeThis;
	  	iprintln(leafs);
	}
	iprintln(leafs);
}