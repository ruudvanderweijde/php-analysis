module lang::php::experiments::mscse2014::MapTest

import Prelude;

public void main()
{
	map[int, str] inputMap = (
		1:"one",
		2:"two",
		3:"three",
		4:"four"
	);
	
	iprintln(inputMap);
	
	map[int,int] outputMap = ();
	
	for(i <- inputMap) {
		outputMap[i] = 4;
	}
	
	println(outputMap);
}
