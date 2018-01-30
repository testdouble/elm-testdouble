module TDTest exposing (..)

import Expect
import Helpers.Expect as Expect
import Regex exposing (regex)
import Standin
import TD exposing (TestDouble)
import TD.Arity1 as TD
import Test exposing (..)


testArity1 : Test
testArity1 =
    describe "1-arity functions" <|
        let
            createdTestDouble : TestDouble (Int -> String)
            createdTestDouble =
                TD.function
                    |> TD.when 42
                    |> TD.thenReturn "Jane User"
                    |> TD.ready

            replacedFunction : TestDouble (Int -> String)
            replacedFunction =
                TD.replace Standin.oneArity
                    |> TD.when 42
                    |> TD.thenReturn "Jane User"
                    |> TD.ready
        in
        [ test "creates a 1-arity test double" <|
            \_ ->
                (\subject -> subject 42)
                    |> TD.run createdTestDouble
                    |> Expect.equal "Jane User"
        , test "replaces a 1-arity function" <|
            \_ ->
                (\_ -> Standin.oneArity 42)
                    |> TD.run replacedFunction
                    |> Expect.equal "Jane User"
        , test "new test doubles crash if not given an expected argument" <|
            \_ ->
                let
                    testExecution () =
                        (\subject -> subject 20)
                            |> TD.run createdTestDouble
                in
                testExecution
                    |> Expect.crash (regex "This test double was called with an unexpected argument")
        , test "replaced test doubles use default implementation with unexpected argument" <|
            \_ ->
                (\_ -> Standin.oneArity 1)
                    |> TD.run replacedFunction
                    |> Expect.equal "DEFAULT"
        , test "handles multiple possible inputs" <|
            \_ ->
                let
                    testdouble =
                        TD.function
                            |> TD.when 1
                            |> TD.thenReturn "1"
                            |> TD.when 2
                            |> TD.thenReturn "2"
                            |> TD.when 3
                            |> TD.thenReturn "3"
                            |> TD.ready
                in
                (\subject -> List.map subject [ 1, 2, 3 ])
                    |> TD.run testdouble
                    |> Expect.equal [ "1", "2", "3" ]
        , test "restores a replaced function after usage" <|
            \_ ->
                let
                    mockedResult =
                        (\_ -> Standin.oneArity 42)
                            |> TD.run replacedFunction
                in
                Standin.oneArity 42
                    |> flip (::) [ mockedResult ]
                    |> Expect.equal [ "DEFAULT", "Jane User" ]
        , test "verifies a test double was called with an expected argument" <|
            \_ ->
                let
                    testExecution subject =
                        let
                            _ =
                                Standin.oneArity 13
                        in
                        TD.verify Standin.oneArity 13
                in
                testExecution
                    |> TD.run replacedFunction
                    |> Expect.equal (Ok True)
        , test "returns an Err if verification fails" <|
            \_ ->
                let
                    testExecution subject =
                        let
                            _ =
                                Standin.oneArity 13
                        in
                        TD.verify Standin.oneArity 20

                    result =
                        testExecution
                            |> TD.run replacedFunction

                    errorRegex =
                        regex "Unsatisfied verification on test double `Standin.oneArity`"

                    failureMessage =
                        "Expected verification to fail"
                in
                case result of
                    Ok _ ->
                        Expect.fail failureMessage

                    Err error ->
                        error
                            |> Regex.contains errorRegex
                            |> Expect.true failureMessage
        ]
