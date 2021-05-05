module Main exposing (..)

import Array
import Bootstrap.Accordion as Accordion
import Browser
import Convert exposing (..)
import Debug
import Maybe
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


init : () -> ( Model, Cmd Msg )
init _ =
    ( { options =
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

      -- Use `Accordion.initialState` to have everything collapsed
      , accordionState = Accordion.initialStateCardOpen "set nofoldenable"
      , vimConfig = "Foo"
      , emacsConfig =
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
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AccordionMsg state ->
            ( { model | accordionState = state }
            , Cmd.none
            )

        Convert vimConfig ->
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
