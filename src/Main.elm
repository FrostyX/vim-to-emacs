module Main exposing (..)

import Array
import Bootstrap.Accordion as Accordion
import Browser
import Convert exposing (..)
import Debug
import Http exposing (..)
import Json.Decode exposing (Decoder, field, map2, map4, map5, string, succeed)
import Models exposing (..)
import String.Interpolate exposing (interpolate)
import Views exposing (..)


main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Accordion.subscriptions model.accordionState AccordionMsg


readOptions : Cmd Msg
readOptions =
    Http.get
        { url = "/data/options.json"
        , expect = Http.expectJson GotOptions optionListDecoder
        }


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


initEmacsConfig : String
initEmacsConfig =
    ";; Put this into init.el\n"
        ++ "(use-package evil\n"
        ++ "  :ensure t\n"
        ++ "  :init\n"
        ++ "  (setq evil-search-module 'evil-search)\n"
        ++ "  (setq evil-ex-complete-emacs-commands nil)\n"
        ++ "  (setq evil-vsplit-window-right t)\n"
        ++ "  (setq evil-split-window-below t)\n"
        ++ "  (setq evil-shift-round nil)\n"
        ++ "  (setq evil-want-C-u-scroll t)\n"
        ++ "  (setq evil-ex-set-initial-state 'normal)\n"
        ++ "  :config\n"
        ++ "  (evil-mode))\n"


init : () -> ( Model, Cmd Msg )
init _ =
    ( { options = Array.fromList []

      -- Use `Accordion.initialState` to have everything collapsed
      , accordionState = Accordion.initialStateCardOpen "set nofoldenable"
      , vimConfig = "Foo"
      , emacsConfig = initEmacsConfig
      }
    , readOptions
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AccordionMsg state ->
            ( { model | accordionState = state }
            , Cmd.none
            )

        Convert vimConfig ->
            if vimConfig |> String.isEmpty then
                ( { model | emacsConfig = initEmacsConfig }, Cmd.none )

            else
                ( { model | emacsConfig = convertVimToEmacs vimConfig model.options }, Cmd.none )

        SetOptionValue value ->
            let
                optionIndex =
                    5

                option =
                    Array.get optionIndex model.options
            in
            case option of
                Nothing ->
                    ( model, Cmd.none )

                Just foundOption ->
                    let
                        updatedOption =
                            { foundOption | param = Just value }
                    in
                    ( { model | options = Array.set optionIndex updatedOption model.options }, Cmd.none )

        GotOptions result ->
            let
                _ =
                    Debug.log "Result" result
            in
            case result of
                Ok options ->
                    ( { model | options = Array.fromList options }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )
