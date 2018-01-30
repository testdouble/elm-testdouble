module Helpers.Expect exposing (..)

import Expect exposing (Expectation)
import Native.Helpers.Expect
import Regex exposing (Regex)


crash : Regex -> (a -> b) -> Expectation
crash regex testExecution =
    let
        passed =
            Native.Helpers.Expect.crash testExecution
                |> Result.map (Regex.contains regex)
                |> Result.withDefault False
    in
    if passed then
        Expect.pass
    else
        Expect.fail "Expected to crash"
