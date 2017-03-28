module lang::php::experiments::mscse2014::testing

import IO;

public void main() {
	println(getConstraints());
}

private set[int] getConstraints() {
	set[int] input = {1,2,3};
	set[int] result = {};

	for (i <- input) return result += 100+i;
	
	return result;
}