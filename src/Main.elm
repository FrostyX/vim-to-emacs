module Main exposing (..)

import Array
import Bootstrap.Accordion as Accordion
import Browser
import Convert exposing (..)
import Debug
import Http exposing (..)
import Json.Decode exposing (Decoder, field, map2, map4, string, succeed)
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
    map4 Option
        (field "vim" string)
        (field "emacs" string)
        (field "param" paramDecoder)
        (field "status" statusDecoder)


paramDecoder : Decoder (Maybe String)
paramDecoder =
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


initOptions : Array.Array Option
initOptions =
    Array.fromList
        [ Option "set number" "(add-hook 'prog-mode-hook #'display-line-numbers-mode)" Nothing Compatible
        , Option "set nocompatible" "TODO" Nothing NOOP
        , Option "set nofoldenable" "TODO" Nothing Unknown
        , Option "set autowrite" "TODO" Nothing Unknown
        , Option "set showmatch" "TODO" Nothing Unknown
        , Option "set tabstop" "TODO" (Just "4") Unknown
        , Option "set shiftwidth" "(setq evil-shift-width {0})" (Just "4") Unknown
        , Option "set softtabstop" "TODO" (Just "4") Unknown
        , Option "set autoindent" "TODO" Nothing Unknown
        , Option "set smartindent" "TODO" Nothing Unknown
        , Option "set scrolloff" "TODO" (Just "5") Unknown
        , Option "set pastetoggle" "TODO NOOP" (Just "<F2>") Unknown
        , Option "nmap <silent> <c-k> :wincmd k<CR>" "TODO" Nothing Unknown
        , Option "nmap <silent> <c-j> :wincmd j<CR>" "TODO" Nothing Unknown
        , Option "nmap <silent> <c-h> :wincmd h<CR>" "TODO" Nothing Unknown
        , Option "nmap <silent> <c-l> :wincmd l<CR>" "TODO" Nothing Unknown
        ]


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
    ( { options = initOptions

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
                Ok option ->
                    ( model, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )
