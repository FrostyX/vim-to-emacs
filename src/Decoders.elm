module Decoders exposing (..)

import Json.Decode exposing (Decoder, field, map2, map4, map5, map6, map7, map8, string, succeed)
import Models exposing (..)


optionListDecoder : Decoder (List Option)
optionListDecoder =
    Json.Decode.list optionDecoder


pluginListDecoder : Decoder (List Plugin)
pluginListDecoder =
    Json.Decode.list pluginDecoder


optionDecoder : Decoder Option
optionDecoder =
    map5 Option
        (field "vim" string)
        (field "emacs" maybeStringDecoder)
        (field "param" maybeStringDecoder)
        (field "status" statusDecoder)
        (field "emacsDocs" maybeStringDecoder)


pluginDecoder : Decoder Plugin
pluginDecoder =
    map8 Plugin
        (field "vim" string)
        (field "emacs" string)
        (field "status" statusDecoder)
        (field "vimCode" maybeStringDecoder)
        (field "emacsCode" maybeStringDecoder)
        (field "vimUrl" maybeStringDecoder)
        (field "emacsUrl" maybeStringDecoder)
        (field "note" maybeStringDecoder)


maybeStringDecoder : Decoder (Maybe String)
maybeStringDecoder =
    Json.Decode.maybe Json.Decode.string


statusDecoder : Decoder Status
statusDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\str ->
                case str of
                    "Compatible" ->
                        Json.Decode.succeed Compatible

                    "NOOP" ->
                        Json.Decode.succeed NOOP

                    "Incompatible" ->
                        Json.Decode.succeed Incompatible

                    "Unknown" ->
                        Json.Decode.succeed Unknown

                    unexpected ->
                        Json.Decode.fail <| "Unexpected status: " ++ unexpected
            )
