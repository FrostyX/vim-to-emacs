module TestConvert exposing (..)

import Array
import Convert exposing (..)
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Models exposing (..)
import Test exposing (..)


options =
    Array.fromList
        [ Option "set number" (Just "(set-number-mock t)") Nothing Compatible Nothing
        , Option "set shiftwidth" (Just "(setq evil-shift-width {0})") (Just "4") Unknown Nothing
        , Option "set nocompatible" Nothing Nothing NOOP Nothing
        ]


testConvertOption : Test
testConvertOption =
    describe "Test converting one config line"
        [ --
          test "Test comment" <|
            \_ ->
                Expect.equal
                    (convertOption "# Some comment" options)
                    ";; Some comment"

        -- It would be nice if this test worked in an `Expect.equal` manner but
        -- it is not necesary since we can be sure to pass only trimmed String
        , test "Test comment with excesive whitespace" <|
            \_ ->
                Expect.notEqual
                    (convertOption "   #     Some comment" options)
                    ";; Some comment"

        --
        , test "Test unknown option" <|
            \_ ->
                Expect.equal
                    (convertOption "set foo" options)
                    ";; Unknown alternative to set foo"

        --
        , test "Test simple option" <|
            \_ ->
                Expect.equal
                    (convertOption "set number" options)
                    ";; set number\n(set-number-mock t)\n"

        --
        , test "Test simple option with comment" <|
            \_ ->
                Expect.equal
                    (convertOption "set number # Foo" options)
                    ";; set number\n(set-number-mock t)\n"

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

        --
        , test "Test NOOP option" <|
            \_ ->
                Expect.equal
                    (convertOption "set nocompatible" options)
                    ";; set nocompatible\n;; The `set nocompatible' option is NOOP for emacs\n"

        --
        , test "Test NOOP option with param" <|
            \_ ->
                Expect.equal
                    (convertOption "set nocompatible" options)
                    ";; set nocompatible\n;; The `set nocompatible' option is NOOP for emacs\n"
        ]
