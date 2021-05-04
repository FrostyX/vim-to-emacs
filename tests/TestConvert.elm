module TestConvert exposing (..)

import Array
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Main exposing (..)
import Test exposing (..)


options =
    Array.fromList
        [ Option "set number" "(set-number-mock t)" Nothing Compatible
        , Option "set shiftwidth" "(setq evil-shift-width {0})" (Just "4") Unknown
        ]


testConvertOption : Test
testConvertOption =
    describe "Test converting one config line"
        [ -- TODO Convert # to ;;
          test "Test comment" <|
            \_ ->
                Expect.equal
                    (convertOption "# Some comment" options)
                    ";; # Some comment"

        --
        , test "Test unknown option" <|
            \_ ->
                Expect.equal
                    (convertOption "set foo" options)
                    ";; Unknown alternative to set foo"

        -- TODO There shouldn't be =
        , test "Test simple option" <|
            \_ ->
                Expect.equal
                    (convertOption "set number" options)
                    ";; set number=\n(set-number-mock t)\n"

        --
        , test "Test option with parameter" <|
            \_ ->
                Expect.equal
                    (convertOption "set shiftwidth=2" options)
                    ";; set shiftwidth=2\n(setq evil-shift-width 2)\n"

        --
        , test "Test option with parameter and spaces" <|
            \_ ->
                Expect.equal
                    (convertOption "set shiftwidth   = 2" options)
                    ";; set shiftwidth=2\n(setq evil-shift-width 2)\n"

        --
        , test "Test option with missing parameter" <|
            \_ ->
                Expect.equal
                    (convertOption "set shiftwidth=" options)
                    ";; Missing option value, using default\n;; set shiftwidth=4\n(setq evil-shift-width 4)\n"

        --
        , test "Test option with missing parameter and equal sign" <|
            \_ ->
                Expect.equal
                    (convertOption "set shiftwidth" options)
                    ";; Missing option value, using default\n;; set shiftwidth=4\n(setq evil-shift-width 4)\n"

        --
        , test "Test option with parameter and comment" <|
            \_ ->
                Expect.equal
                    (convertOption "set shiftwidth=6  # Foo" options)
                    ";; set shiftwidth=6\n(setq evil-shift-width 6)\n"
        ]
