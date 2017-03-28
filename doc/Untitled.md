Hey Jurgen,

Ik heb nog een vraagje over de least upper bound (adhv code sample hieronder).

```
<?php
$a = 2;  // $a1
$b = $a; // $a2
```

Constraints die hieruit komen zijn:

```
eq([$a], [2]);
subtype([2], [$a1]);
subtype([$a2], [$b]);
lub([$a1], [$a2]);
```

Initial:

```
2 = {int}
$a1 = {any, ... etc}
$b = {any, ... etc}
$a2 = {any, ... etc}
```

First solve iteration (#1):
    
```
subtype([2], [$a1]) 
	=> [$a1] = int (`subtype of int` is equal to `int`)
```

Als ik dan de LUB van deze $a1 en $a2 pak krijg ik any.

```
lub($a1, $a2) => lub(int, any) => any
```

Ik zou hier natuurlijk graag `int` uit zien komen. Zie ik iets over het hoofd hier?

Groet Ruud
