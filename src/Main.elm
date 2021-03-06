module Main exposing (..)

import Array
import Bootstrap.Accordion as Accordion
import Browser
import Convert exposing (..)
import Debug
import Decoders exposing (..)
import Http exposing (..)
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


readPlugins : Cmd Msg
readPlugins =
    Http.get
        { url = "/data/plugins.json"
        , expect = Http.expectJson GotPlugins pluginListDecoder
        }


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
      , plugins = Array.fromList []

      -- Use `Accordion.initialState` to have everything collapsed
      , accordionState = Accordion.initialStateCardOpen "set nofoldenable"
      , vimConfig = "Foo"
      , emacsConfig = initEmacsConfig
      }
    , Cmd.batch [ readOptions, readPlugins ]
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

        GotPlugins result ->
            let
                _ =
                    Debug.log "Result" result
            in
            case result of
                Ok plugins ->
                    ( { model | plugins = Array.fromList plugins }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )
