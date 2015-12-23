module lang::php::experiments::mscse2014::ResultDataType

import lang::php::types::TypeSymbol;
import lang::php::types::TypeConstraints;

data ItemCount 
	= singleItem() 
	| multipleItems(int amount) 
	| allItems()
	| noItems() // error
	;

data AnalysisResult = analysisResult(
	loc variable, 
	ItemCount numberOfResolvedItems, 
	TypeSet originalTypeSet
);