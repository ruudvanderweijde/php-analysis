module lang::php::experiments::mscse2014::ResultAnalysis

import lang::php::types::TypeSymbol;
import lang::php::types::TypeConstraints;

import lang::php::experiments::mscse2014::ResultDataType;

import analysis::graphs::Graph;
import Relation;
import Set;

import IO; // for debugging

public set[AnalysisResult] getNumberOfPossibleItems(map[TypeOf, TypeSet] solveResults, rel[TypeSymbol, TypeSymbol] subtypes)
{
	reducedResults = {};
	
	for (key:typeOf(variable) <- solveResults) {
		reducedResults += analysisResult(variable, simplify(solveResults[key], subtypes), solveResults[key]);
	}
	
	return reducedResults;
}

private ItemCount simplify(TypeSet possibleTypes, rel[TypeSymbol, TypeSymbol] subtypes)
{
	switch(possibleTypes) {
		case ts:Set({oneItem}): 	return singleItem();
		case ts:Set(multiple:_):	return multipleItems(getActualNumberOfMultipleResults(multiple, subtypes));
		case Universe(): 			return allItems();
		case Root(): 				return allItems();
		case EmptySet(): 			return noItems();
		
		case notSupported:_:	throw("implement me: <notSupported>");
	}
}

// reduce the parents
// 
private int getActualNumberOfMultipleResults(set[TypeSymbol] possibleTypes, rel[TypeSymbol, TypeSymbol] subtypes)
{
	// remove all parents
	// for each item, remove the parents
	for (childType <- possibleTypes) {
		parents = invert(subtypes)[childType];
		possibleTypes = possibleTypes - parents;
	}
	
	return size(possibleTypes);
}
