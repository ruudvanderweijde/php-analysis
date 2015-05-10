<?php

$basePath = "/Users/ruud/PHPAnalysis/systems/";
$phpStormInspect = "/Applications/PhpStorm.app/Contents/bin/inspect.sh";
$inspectionSettings = "/Users/ruud/Rascal.xml";
$tempResultFolder = "inspectionResults";

$template = <<<template
## START of new inspection ##

# 1) clear the folder before running the analysis
rm -rf  {$basePath}__program_name__/{$tempResultFolder}

# 2) do inspections
{$phpStormInspect} \
  {$basePath}__program_name__/__program_name__-__program_version____optional_source_folder \
  {$inspectionSettings} \
  {$basePath}__program_name__/{$tempResultFolder}
 \ -v0

# 3) format so rascal can read it
echo { \
  > {$basePath}__program_name__/__output_file__
cat  {$basePath}__program_name__/{$tempResultFolder}/RascalTypeUsage.xml \
  | grep description | sed s/'<description>'// | sed s/'<\/description>'/,/ | sed '\$s/,$//' | sed 's/&gt;/>/' | sed 's/&lt;/</' \
  >> {$basePath}__program_name__/__output_file__
echo } \
  >> {$basePath}__program_name__/__output_file__

## END ##


template;

$variations = [
    [ 'onlySourceFolder' => true,  'withDocBlock' => true  ],
    [ 'onlySourceFolder' => true,  'withDocBlock' => false ],
    [ 'onlySourceFolder' => false, 'withDocBlock' => true  ],
    [ 'onlySourceFolder' => false, 'withDocBlock' => false ],
];
$programs = [
//    [
//        'name' => 'Seldaek_monolog',
//        'version' => '1.10.0',
//        'sourceFolder' => '/src', // full path from root
//    ],
//    [
//        'name' => 'doctrine_annotations',
//        'version' => 'v1.2.0',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'doctrine_cache',
//        'version' => 'v.1.3.0',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'doctrine_collections',
//        'version' => 'v1.2',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'doctrine_common',
//        'version' => 'v2.4.2',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'doctrine_dbal',
//        'version' => 'v2.4.2',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'doctrine_doctrine2',
//        'version' => 'v2.4.4',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'doctrine_inflector',
//        'version' => 'v1.0',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'doctrine_lexer',
//        'version' => 'v1.0',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'fabpot_Twig',
//        'version' => 'v1.16.0',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'guzzle_guzzle3',
//        'version' => 'v3.9.2',
//        'sourceFolder' => '/lib', // full path from root
//    ],
//    [
//        'name' => 'php-fig_log',
//        'version' => '1.0.0',
//        'sourceFolder' => '/Psr', // full path from root
//    ],
//    [
//        'name' => 'sebastianbergmann_php-code-coverage',
//        'version' => '2.0.10',
//        'sourceFolder' => '/src', // full path from root
//    ],
    [
        'name' => 'sebastianbergmann_php-file-iterator',
        'version' => '1.3.4',
        'sourceFolder' => '/File', // full path from root
    ],
//    [
//        'name' => 'sebastianbergmann_php-text-template',
//        'version' => '1.2.0',
//        'sourceFolder' => '/Text', // full path from root
//    ],
//    [
//        'name' => 'sebastianbergmann_php-token-stream',
//        'version' => '1.2.2',
//        'sourceFolder' => '/PHP', // full path from root
//    ],
//    [
//        'name' => 'sebastianbergmann_phpunit',
//        'version' => '4.2.2',
//        'sourceFolder' => '/src', // full path from root
//    ],
//    [
//        'name' => 'sebastianbergmann_phpunit-mock-objects',
//        'version' => '2.2.0',
//        'sourceFolder' => '/src', // full path from root
//    ],
//    [
//        'name' => 'swiftmailer_swiftmailer',
//        'version' => 'v5.2.1',
//        'sourceFolder' => '/lib', // full path from root
//    ],
];
foreach ($programs as $program) {
    foreach ($variations as $variation) {
        $onlySourceFolder = $variation['onlySourceFolder'];
        $withDocBlock = $variation['withDocBlock'];

        $optionalSourceFolder = $onlySourceFolder ? $program['sourceFolder'] : "";
        $outputFileName = sprintf('resolved_types_%s_%s.txt',
            $withDocBlock ? "with_docblock" : "without_docblock",
            $onlySourceFolder ? "src_only" : "all"
        );

        $versionPostFix = $withDocBlock ? "_with_tests" : "_with_tests_without_docblock";

        $replace = [
            '__program_name__' => $program['name'],
            '__program_version__' => $program['version'] . $versionPostFix,
            '__output_file__' => $outputFileName,
            '__optional_source_folder' => $optionalSourceFolder,
        ];

        $output = str_replace(array_keys($replace), array_values($replace), $template);

        echo $output;
    }
}
