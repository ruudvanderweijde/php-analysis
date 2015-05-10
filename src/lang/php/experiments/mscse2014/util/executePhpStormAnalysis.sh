#!/bin/sh

echo "Do not run this again. It will take like 30 minutes to run and you should not have PhpStorm open"
exit; 
## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/Seldaek_monolog-1.10.0_with_tests/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/Seldaek_monolog-1.10.0_with_tests_without_docblock/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/Seldaek_monolog-1.10.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/Seldaek_monolog-1.10.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/Seldaek_monolog/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/doctrine_annotations-v1.2.0_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/doctrine_annotations-v1.2.0_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/doctrine_annotations-v1.2.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/doctrine_annotations-v1.2.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_annotations/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_annotations/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/doctrine_cache-v.1.3.0_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/doctrine_cache-v.1.3.0_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/doctrine_cache-v.1.3.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/doctrine_cache-v.1.3.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_cache/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_cache/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/doctrine_collections-v1.2_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/doctrine_collections-v1.2_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/doctrine_collections-v1.2_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/doctrine_collections-v1.2_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_collections/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_collections/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/doctrine_common-v2.4.2_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/doctrine_common-v2.4.2_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/doctrine_common-v2.4.2_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/doctrine_common-v2.4.2_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_common/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_common/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/doctrine_dbal-v2.4.2_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/doctrine_dbal-v2.4.2_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/doctrine_dbal-v2.4.2_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/doctrine_dbal-v2.4.2_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_dbal/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_dbal/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/doctrine_doctrine2-v2.4.4_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/doctrine_doctrine2-v2.4.4_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/doctrine_doctrine2-v2.4.4_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/doctrine_doctrine2-v2.4.4_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_doctrine2/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/doctrine_inflector-v1.0_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/doctrine_inflector-v1.0_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/doctrine_inflector-v1.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/doctrine_inflector-v1.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_inflector/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_inflector/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/doctrine_lexer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/doctrine_lexer/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/fabpot_Twig-v1.16.0_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/fabpot_Twig-v1.16.0_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/fabpot_Twig-v1.16.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/fabpot_Twig-v1.16.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/fabpot_Twig/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/fabpot_Twig/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/guzzle_guzzle3-v3.9.2_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/guzzle_guzzle3-v3.9.2_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/guzzle_guzzle3-v3.9.2_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/guzzle_guzzle3-v3.9.2_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/guzzle_guzzle3/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/php-fig_log-1.0.0_with_tests/Psr \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/php-fig_log-1.0.0_with_tests_without_docblock/Psr \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/php-fig_log-1.0.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/php-fig_log-1.0.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/php-fig_log/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/php-fig_log/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/sebastianbergmann_php-code-coverage-2.0.10_with_tests/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/sebastianbergmann_php-code-coverage-2.0.10_with_tests_without_docblock/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/sebastianbergmann_php-code-coverage-2.0.10_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/sebastianbergmann_php-code-coverage-2.0.10_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-code-coverage/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/sebastianbergmann_php-text-template-1.2.0_with_tests/Text \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/sebastianbergmann_php-text-template-1.2.0_with_tests_without_docblock/Text \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/sebastianbergmann_php-text-template-1.2.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/sebastianbergmann_php-text-template-1.2.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-text-template/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/sebastianbergmann_php-token-stream-1.2.2_with_tests/PHP \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/sebastianbergmann_php-token-stream-1.2.2_with_tests_without_docblock/PHP \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/sebastianbergmann_php-token-stream-1.2.2_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/sebastianbergmann_php-token-stream-1.2.2_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-token-stream/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/sebastianbergmann_phpunit-4.2.2_with_tests/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/sebastianbergmann_phpunit-4.2.2_with_tests_without_docblock/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/sebastianbergmann_phpunit-4.2.2_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/sebastianbergmann_phpunit-4.2.2_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/sebastianbergmann_phpunit-mock-objects-2.2.0_with_tests/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/sebastianbergmann_phpunit-mock-objects-2.2.0_with_tests_without_docblock/src \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/sebastianbergmann_phpunit-mock-objects-2.2.0_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/sebastianbergmann_phpunit-mock-objects-2.2.0_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_phpunit-mock-objects/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1_with_tests/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1_with_tests_without_docblock/lib \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults
 \
  -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/swiftmailer_swiftmailer/resolved_types_without_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/sebastianbergmann_php-file-iterator-1.3.4_with_tests/File \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults
 \ -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_with_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_with_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_with_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/sebastianbergmann_php-file-iterator-1.3.4_with_tests_without_docblock/File \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults
 \ -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_without_docblock_src_only.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_without_docblock_src_only.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_without_docblock_src_only.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/sebastianbergmann_php-file-iterator-1.3.4_with_tests \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults
 \ -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_with_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_with_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_with_docblock_all.txt

## END ##

## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults

# 2) do inspections
/Applications/PhpStorm.app/Contents/bin/inspect.sh \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/sebastianbergmann_php-file-iterator-1.3.4_with_tests_without_docblock \
  /Users/ruud/Rascal.xml \
  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults
 \ -v0

# 3) format so rascal can read it
echo { \
  > /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_without_docblock_all.txt
cat  /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/inspectionResults/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_without_docblock_all.txt
echo } \
  >> /Users/ruud/PHPAnalysis/systems/sebastianbergmann_php-file-iterator/resolved_types_without_docblock_all.txt

## END ##
