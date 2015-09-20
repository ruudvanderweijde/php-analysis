Analysis results
=================

Code
========

```php
<?php

class Paarent {}
class Int extends Paarent { public function getInt() { return 1; } }
class String extends Paarent { public function getString() { return "string"; } }

$intOnlyResult = $intOnly->getInt();

$stringOnlyResult = $stringOnly->getString();

$bothResult1 = $both->getString();
$bothResult2 = $both->getInt();
```

Results
========

* [|php+globalVar:///both|] :: {}
* [|php+globalVar:///bothResult1|] :: { any() }
* [|php+globalVar:///bothResult2|] :: { any(), integerType(), numberType(), scalarType() }
* [$stringOnly] :: { classType(|php+class:///string|) }
* [$stringOnly->getString()] :: { stringType() }
* [$stringOnlyResult] :: { any(), callableType(), scalarType(), stringType() }
* [$stringOnlyResult = $stringOnly->getString()] :: { any(), callableType(), scalarType(), stringType() }
* [$intOnly] :: { classType(|php+class:///int|) }
* [$intOnly->getInt()] :: { integerType() }
* [$both] :: {}
* [$both->getInt()] :: { integerType() }
* [$bothResult2] :: { any(), integerType(), numberType(), scalarType() }
* [$bothResult2 = $both->getInt()] :: { any(), integerType(), numberType(), scalarType() }
* [$intOnlyResult = $intOnly->getInt()] :: { any(), integerType(), numberType(), scalarType() }
* [$intOnlyResult] :: { any(), integerType(), numberType(), scalarType() }
* [$both->getString()] :: { any() }
* [$both] :: {}
* [$bothResult1] :: { any() }
* [$bothResult1 = $both->getString()] :: { any() }
* [|php+globalVar:///intOnly|] :: { classType(|php+class:///int|) }
* [|php+globalVar:///stringOnly|] :: { classType(|php+class:///string|) }
* [public function getInt() { return 1; }] :: { integerType() }
* [1] :: { integerType() }
* ["string"] :: { stringType() }
* [public function getString() { return "string"; }] :: { stringType() }
* [|php+globalVar:///intOnlyResult|] :: { any(), integerType(), numberType(), scalarType() }
* [|php+globalVar:///stringOnlyResult|] :: { any(), callableType(), scalarType(), stringType() }
