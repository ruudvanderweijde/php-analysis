# List of constraints:


 * Todo: Types of arrays
 * Todo: Constants
 * Todo: References 
 * Todo: method/function calls + return types (is in the list but not yet defined) + constants
 * Todo: clone
 *
 
** Explanation of signs **

Sign | Explanation
--- | ---
`E` | some expression
`M` | some method
`Param(M, i)` | the `i`'th parameter of method `M`
`l = r` | `l` is the same type as `r`
`l <: r` | `l` is a subtype of `r`

** Assignments **

Code | Type | Notes
--- | --- | ---
`E = E'` | `E' <: E` | typeOf(`E'`) is subtypeOf(`E`)
`E = E' = E''` | `E'' <: E'` && `E' <: E` | typeOf(`E'`) is subtypeOf(`E`)
`E &= E'` | `E = int()`
`E \|= E';` | `E = int()` |
`E ^= E';` | `E = int()` |
`E <<= E';` | `E = int()` |
`E >>= E';` | `E = int()` |
`E %= E';` | `E = int()` |
`E .= E';` | `E = string()` | * Error when `E'` is of type `object()` and __toString is not defined or does not return a string 
`E /= E'` | `E = int()` | * Error when `E'` is of type `array()`
`E -= E'` | `E = int()` | * Error when `E'` is of type `array()`
`E *= E'` && `E'` == (`bool()`\|`int()`\|`null()`) | `E = int()` 
`E *= E'` && `E'` != (`bool()`\|`int()`\|`null()`) | `E = float()`
`E += E'` && `E'` == (`bool()`\|`int()`\|`null()`) | `E = int()` 
`E += E'` && `E'` != (`bool()`\|`int()`\|`null()`) | `E = float()`


** Class instantiation **

Code | Type | Notes
--- | --- | ---
`E = new C(E1..Ek)'` | `E = C` | typeOf(`E`) is `C`
`E = new C(E1..Ek)'`, `E'i == Param(M, i)` | `Ei <: E'i` | Actual parameter is subtype of provided param
`E.f` | `-` | todo: field access, can also be declared at runtime
`E0->m(E1..Ek)` | `-` | todo: method call with parameters (or magic method __call)
`E0::m(E1..Ek)` | `-` | todo: static method call
`f(E1..Ek)` | `-` | todo: function call with parameters
`E = f(...)` | `-` | todo: return type of function call
`E = E.m(...)` | `-` | todo: return type of method call


 * The return type of a method is the disjuction of all return expressions 
 * The type of a variable is the disjunction of all the types of that variable within the scope
 
** Comparison operators **

Code | Type
--- | ---
`E == E'` | bool()
`E === E'` | bool()
`E != E'` | bool()
`E <> E'` | bool()
`E !== E'` | bool()
`E < E'` | bool()
`E > E'` | bool()
`E <= E'` | bool()
`E >= E'` | bool()

** Bitwise operators **

Code | Type | Notes
--- | --- | ---
`E & E'` | string() | when E && E' are both strings
`E & E'` | int() | when E && E' are anything but both strings
--- | --- | ---
`E \| E'` | string() | when E && E' are both strings
`E \| E'` | int() | when E && E' are anything but both strings
--- | --- | ---
`E ^ E'` | string() | when E && E' are both strings
`E ^ E'` | int() | when E && E' are anything but both strings
--- | --- | ---
`~E` | int() | when E is integer|double
`~E` | string() | when E is string
`~E` | `ERROR` | error when type is not integer, double or string
--- | --- | ---
`E << E'` | int()
`E >> E'` | int()

---

** Cast operators **

Code | Type 
--- | ---
`(array) E`| array()
`(bool) E` | boolean()
`(object) E` | object()
`(unset) E` | null()

 * Todo: do something with references...
 * Variables constructs; variables variables, v. method calls, v. class instantiations
 
