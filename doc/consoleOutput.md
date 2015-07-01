# Console output (first part)

Run instructions: (current selected project: `|file:///PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0|`)

See output below:

```
rascal>main();
Run instructions: (current selected project: `|file:///PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0|`)
----------------
1) Run run1() to parse the files (and save the parsed files to the cache)
2) Run run2() to create the m3 (and save system and m3 to cache)
3) Run run3() to collect constraints (and save the constraints to cache)
4) Run run4() to solve the constraints (and write results to cache)
5) Run run5() to print the results
----------------
Or runAll() with a project location, like:
 ⤷ runAll(|file:///PHPAnalysis/systems/doctrine_lexer/doctrine_lexer-v1.0|);
 ⤷ runAll(|file:///PHPAnalysis/systems/sebastianbergmann_php-timer/sebastianbergmann_php-timer-1.0.5|);
 ⤷ runAll(|file:///PHPAnalysis/systems/sebastianbergmann_php-text-template/sebastianbergmann_php-text-template-1.2.0|);
 ⤷ runAll(|file:///PHPAnalysis/systems/sebastianbergmann_php-file-iterator/sebastianbergmann_php-file-iterator-1.3.4|);
 ⤷ runAll(|file:///PHPAnalysis/systems/php-fig_log/php-fig_log-1.0.0|);
 ⤷ runAll(|file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1|); (=pretty big!!!)
ok

rascal>runAll(|file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1|);
2015-06-30 22:13:39 :: 1) Run run1() to parse the files (and save the parsed files to the cache)
2015-06-30 22:13:39 :: Run 1 [1/2] :: parsing php files to ASTs...
2015-06-30 22:13:40 :: 31% [21/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/ext|
2015-06-30 22:13:41 :: 33% [22/66] Parsing 6 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib|
2015-06-30 22:13:43 :: 34% [23/66] Parsing 1 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes|
2015-06-30 22:13:43 :: 36% [24/66] Parsing 40 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift|
2015-06-30 22:13:51 :: 37% [25/66] Parsing 4 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/ByteStream|
2015-06-30 22:13:52 :: 39% [26/66] Parsing 3 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/CharacterReader|
2015-06-30 22:13:53 :: 40% [27/66] Parsing 1 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/CharacterReaderFactory|
2015-06-30 22:13:53 :: 42% [28/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/CharacterStream|
2015-06-30 22:13:54 :: 43% [29/66] Parsing 3 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Encoder|
2015-06-30 22:13:55 :: 45% [30/66] Parsing 15 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Events|
2015-06-30 22:13:58 :: 46% [31/66] Parsing 5 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/KeyCache|
2015-06-30 22:13:59 :: 48% [32/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Mailer|
2015-06-30 22:14:00 :: 50% [33/66] Parsing 18 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Mime|
2015-06-30 22:14:04 :: 51% [34/66] Parsing 6 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Mime/ContentEncoder|
2015-06-30 22:14:06 :: 53% [35/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Mime/HeaderEncoder|
2015-06-30 22:14:06 :: 54% [36/66] Parsing 8 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Mime/Headers|
2015-06-30 22:14:08 :: 56% [37/66] Parsing 14 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Plugins|
2015-06-30 22:14:11 :: 57% [38/66] Parsing 1 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Plugins/Decorator|
2015-06-30 22:14:11 :: 59% [39/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Plugins/Loggers|
2015-06-30 22:14:12 :: 60% [40/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Plugins/Pop|
2015-06-30 22:14:12 :: 62% [41/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Plugins/Reporters|
2015-06-30 22:14:13 :: 63% [42/66] Parsing 6 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Signers|
2015-06-30 22:14:15 :: 65% [43/66] Parsing 3 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/StreamFilters|
2015-06-30 22:14:15 :: 66% [44/66] Parsing 14 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Transport|
2015-06-30 22:14:19 :: 68% [45/66] Parsing 2 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Transport/Esmtp|
2015-06-30 22:14:20 :: 69% [46/66] Parsing 5 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/classes/Swift/Transport/Esmtp/Auth|
2015-06-30 22:14:21 :: 71% [47/66] Parsing 4 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/lib/dependency_maps|
2015-06-30 22:14:22 :: 83% [55/66] Parsing 3 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/examples/starship|
2015-06-30 22:14:23 :: 84% [56/66] Parsing 1 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library|
2015-06-30 22:14:23 :: 86% [57/66] Parsing 11 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery|
2015-06-30 22:14:26 :: 89% [59/66] Parsing 1 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery/Adapter/Phpunit|
2015-06-30 22:14:27 :: 90% [60/66] Parsing 5 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery/CountValidator|
2015-06-30 22:14:28 :: 92% [61/66] Parsing 4 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery/Exception|
2015-06-30 22:14:28 :: 93% [62/66] Parsing 11 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery/Generator|
2015-06-30 22:14:31 :: 96% [64/66] Parsing 8 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery/Generator/StringManipulation/Pass|
2015-06-30 22:14:33 :: 98% [65/66] Parsing 3 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery/Loader|
2015-06-30 22:14:33 :: 100% [66/66] Parsing 13 files in directory: |file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1/vendor/mockery/mockery/library/Mockery/Matcher|
2015-06-30 22:14:36 :: Run 1 [2/2] :: writing parsed system to cache...
The scripts are now parsed into ASTs. Please run run2() now.
2015-06-30 22:14:36 :: 2) Run run2() to create the m3 (and save system and m3 to cache)
2015-06-30 22:14:36 :: Run 2 [1/5] :: Reading parsed system from cache...
2015-06-30 22:14:36 :: Run 2 [2/5] :: create M3 for system...
2015-06-30 22:14:36 :: Get M3 [1/2] :: create M3 per file
2015-06-30 22:14:54 :: Get M3 [2/2] :: create global M3
2015-06-30 22:14:54 :: Run 2 [3/5] :: get modified system...
2015-06-30 22:14:54 :: Run 2 [4/5] :: calculate after m3 creation...
calculateUsesBeforeResolvingTypes for 233 files
2015-06-30 22:15:01 :: 10 (4)%.. 
2015-06-30 22:15:12 :: 20 (8)%.. 
2015-06-30 22:15:32 :: 30 (12)%.. 
2015-06-30 22:17:12 :: 40 (17)%.. 
2015-06-30 22:18:16 :: 50 (21)%.. 
2015-06-30 22:19:06 :: 60 (25)%.. 
2015-06-30 22:19:39 :: 70 (30)%.. 
2015-06-30 22:21:20 :: 80 (34)%.. 
2015-06-30 22:21:59 :: 90 (38)%.. 
2015-06-30 22:25:08 :: 100 (42)%.. 
2015-06-30 22:28:08 :: 110 (47)%.. 
2015-06-30 22:28:52 :: 120 (51)%.. 
2015-06-30 22:29:44 :: 130 (55)%.. 
2015-06-30 22:31:42 :: 140 (60)%.. 
2015-06-30 22:33:31 :: 150 (64)%.. 
2015-06-30 22:35:16 :: 160 (68)%.. 
2015-06-30 22:37:06 :: 170 (72)%.. 
2015-06-30 22:40:46 :: 180 (77)%.. 
2015-06-30 22:43:26 :: 190 (81)%.. 
2015-06-30 22:45:04 :: 200 (85)%.. 
2015-06-30 22:48:42 :: 210 (90)%.. 
2015-06-30 22:52:24 :: 220 (94)%.. 
2015-06-30 22:54:42 :: 230 (98)%.. 
2015-06-30 22:55:58 :: Run 2 [5/5] :: writing system and m3 to filesystem
2015-06-30 22:56:47 :: M3 and System are written to the file system. Please run run3() now.
2015-06-30 22:56:47 :: 3) Run run3() to collect constraints (and save the constraints to cache)
2015-06-30 22:56:47 :: Reading system from cache...
2015-06-30 22:56:47 :: Reading M3 from cache...
2015-06-30 22:57:05 :: Reading done.
2015-06-30 22:57:05 :: Get constraints for system (233 files)
|rascal://lang::php::experiments::mscse2014::ConstraintExtractor|(40837,7,<1135,31>,<1135,38>): Undeclared variable: hasName
☞ Advice

rascal>runAll(|file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1|);
2015-06-30 23:06:26 :: 3) Run run3() to collect constraints (and save the constraints to cache)
2015-06-30 23:06:26 :: Reading system from cache...
2015-06-30 23:06:26 :: Reading M3 from cache...
2015-06-30 23:06:45 :: Reading done.
2015-06-30 23:06:45 :: Get constraints for system (233 files)
2015-06-30 23:09:58 :: 11 items are done... (4)%
2015-06-30 23:13:35 :: 22 items are done... (9)%
2015-06-30 23:16:40 :: 33 items are done... (14)%
2015-06-30 23:20:05 :: 44 items are done... (18)%
2015-06-30 23:22:43 :: 55 items are done... (23)%
2015-06-30 23:29:50 :: 66 items are done... (28)%
2015-06-30 23:36:03 :: 77 items are done... (33)%
2015-06-30 23:40:16 :: 88 items are done... (37)%
2015-06-30 23:45:40 :: 99 items are done... (42)%
2015-06-30 23:51:44 :: 110 items are done... (47)%
2015-06-30 23:53:22 :: 121 items are done... (51)%
2015-06-30 23:56:16 :: 132 items are done... (56)%
2015-06-30 23:58:42 :: 143 items are done... (61)%
2015-07-01 00:00:39 :: 154 items are done... (66)%
2015-07-01 00:03:33 :: 165 items are done... (70)%
2015-07-01 00:06:15 :: 176 items are done... (75)%
2015-07-01 00:07:21 :: 187 items are done... (80)%
2015-07-01 00:09:15 :: 198 items are done... (84)%
2015-07-01 00:14:09 :: 209 items are done... (89)%
2015-07-01 00:17:05 :: 220 items are done... (94)%
2015-07-01 00:20:36 :: 231 items are done... (99)%
2015-07-01 00:20:38 :: Yay. You have 32563 constraints collected! (|file:///PHPAnalysis/systems/swiftmailer_swiftmailer/swiftmailer_swiftmailer-v5.2.1|)
2015-07-01 00:20:38 :: Writing contraints to the file system
2015-07-01 00:20:38 :: Writing done. Now please run run4()
To view the constraints run:
1) import ValueIO;
2) import lang::php::types::TypeSymbol;
3) import lang::php::types::TypeConstraints;
4) constraints = readBinaryValueFile(#set[Constraint], |file:///Users/ruud/tmp/m3/swiftmailer_swiftmailer-v5.2.1_constraints_last.bin|);
2015-07-01 00:20:38 :: 4) Run run4() to solve the constraints (and write results to cache)
2015-07-01 00:20:38 :: Reading system from cache...
2015-07-01 00:20:39 :: Reading constraints from cache...
2015-07-01 00:20:39 :: Reading M3 from cache...
2015-07-01 00:20:56 :: Reading done.
2015-07-01 00:20:56 :: Now solving the constraints...
2015-07-01 00:21:02 :: ... still solving constraints
```

At 2015-07-01 07:15:00 there are still no new results... seems like this can take a few days...
