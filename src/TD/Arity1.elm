module TD.Arity1 exposing (function, ready, replace, thenReturn, verify, when)

import Native.TD
import TD.Types exposing (TestDouble)


type TestDouble1 a b
    = TestDouble1 a b


type Api1 a b
    = Api1 a b


function : TestDouble1 a b
function =
    Native.TD.function 1


replace : (a -> b) -> TestDouble1 a b
replace =
    Native.TD.replace 1


when : a -> TestDouble1 a b -> Api1 a b
when a td =
    Native.TD.when1 td a


thenReturn : b -> Api1 a b -> TestDouble1 a b
thenReturn returnValue api =
    Native.TD.thenReturn returnValue api


ready : TestDouble1 a b -> TestDouble (a -> b)
ready =
    Native.TD.ready


verify : (a -> b) -> a -> Result String Bool
verify =
    Native.TD.verify1
