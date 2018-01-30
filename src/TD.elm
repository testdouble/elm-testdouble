module TD exposing (..)

import Native.TD
import TD.Types as Types


type alias TestDouble a =
    Types.TestDouble a


run : TestDouble a -> (a -> b) -> b
run =
    Native.TD.run1


run2 : TestDouble a -> TestDouble b -> (a -> b -> c) -> c
run2 =
    Native.TD.run2
