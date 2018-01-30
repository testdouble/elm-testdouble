module TD.Arity2 exposing (function, replace, ready, thenReturn, when)

import Native.TD
import TD.Types exposing (TestDouble)


type TestDouble2 a b c
    = TestDouble2 a b c


type Api2 a b c
    = Api2 a b c


function : TestDouble2 a b c
function =
    Native.TD.function 2


replace : (a -> b -> c) -> TestDouble2 a b c
replace =
    Native.TD.replace 2


when : a -> b -> TestDouble2 a b c -> Api2 a b c
when a b td =
    Native.TD.when2 td a b


thenReturn : c -> Api2 a b c -> TestDouble2 a b c
thenReturn =
    Native.TD.thenReturn


ready : TestDouble2 a b c -> TestDouble (a -> b -> c)
ready =
    Native.TD.ready
