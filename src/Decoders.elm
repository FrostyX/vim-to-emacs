module Decoders exposing (..)

import Json.Decode exposing (Decoder, field, map2, map4, map5, string, succeed)
import Models exposing (..)


optionListDecoder : Decoder (List Option)
optionListDecoder =
    Json.Decode.list optionDecoder


optionDecoder : Decoder Option
optionDecoder =
    map5 Option
        (field "vim" string)
        (field "emacs" emacsDecoder)
        (field "param" paramDecoder)
        (field "status" statusDecoder)
        (field "emacsDocs" emacsDocsDecoder)


emacsDecoder : Decoder (Maybe String)
emacsDecoder =
    Json.Decode.maybe Json.Decode.string


paramDecoder : Decoder (Maybe String)
paramDecoder =
    Json.Decode.maybe Json.Decode.string


emacsDocsDecoder : Decoder (Maybe String)
emacsDocsDecoder =
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
