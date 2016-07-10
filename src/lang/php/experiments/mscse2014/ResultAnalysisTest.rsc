module lang::php::experiments::mscse2014::ResultAnalysisTest
extend lang::php::experiments::mscse2014::ResultAnalysis;

public void main()
{
	// no removals
	relation = {<\any(), stringType()>};
	typeSet = {stringType()};
	
	assert 1 == getActualNumberOfMultipleResults(typeSet, relation)
		: "1 == <getActualNumberOfMultipleResults(typeSet, relation)>";
		
	// remove numberType()
	relation = {<\any(), stringType()>,<\any(), numberType()>,<numberType(), integerType()>};
	typeSet = {numberType(), integerType()};
	
	assert 1 == getActualNumberOfMultipleResults(typeSet, relation)
		: "1 == <getActualNumberOfMultipleResults(typeSet, relation)>";
	
	// no removals	
	relation = {<\any(), stringType()>,<\any(), numberType()>};
	typeSet = {stringType(), numberType()};
	
	assert 2 == getActualNumberOfMultipleResults(typeSet, relation)
		: "2 == <getActualNumberOfMultipleResults(typeSet, relation)>";
		
	// remove \any()
	relation = {<\any(), stringType()>,<\any(), numberType()>};
	typeSet = {\any(), stringType(), numberType()};
	
	assert 2 == getActualNumberOfMultipleResults(typeSet, relation)
		: "2 == <getActualNumberOfMultipleResults(typeSet, relation)>";
}