module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Browser
import Html exposing (Html, button, div, h1, h3, p, pre, table, td, text, th, thead, tr)
import Html.Events exposing (onClick)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Option =
    { vim : String
    , emacs : String
    }


type alias Model =
    List Option


init : Model
init =
    [ Option "set number" "(add-hook 'prog-mode-hook #'display-line-numbers-mode)"
    , Option "set nofoldenable" "TODO"
    , Option "set autowrite" "TODO"
    , Option "set showmatch" "TODO"
    , Option "set tabstop=4" "TODO"
    , Option "set shiftwidth=4" "TODO"
    , Option "set softtabstop=4" "TODO"
    , Option "set autoindent" "TODO"
    , Option "set smartindent" "TODO"
    , Option "set scrolloff=5" "TODO"
    , Option "set pastetoggle=<F2>" "TODO NOOP"
    , Option "nmap <silent> <c-k> :wincmd k<CR>" "TODO"
    , Option "nmap <silent> <c-j> :wincmd j<CR>" "TODO"
    , Option "nmap <silent> <c-h> :wincmd h<CR>" "TODO"
    , Option "nmap <silent> <c-l> :wincmd l<CR>" "TODO"
    ]


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    model



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewTable model
        , viewOptionSections model
        ]


viewOptionSections : Model -> Html Msg
viewOptionSections model =
    div []
        ([ h1 [] [ text "Vim options" ] ]
            ++ List.map viewOption model
        )


viewOption : Option -> Html Msg
viewOption option =
    div []
        [ h3 [] [ text option.vim ]
        , p [] [ text "Some description" ]
        , pre [] [ text option.emacs ]
        ]


viewTable : Model -> Html Msg
viewTable model =
    table []
        (List.concat
            [ [ thead []
                    [ th [] [ text "Vim" ]
                    , th [] [ text "Emacs" ]
                    ]
              ]
            , List.map viewOptionRow model
            ]
        )


viewOptionRow : Option -> Html Msg
viewOptionRow option =
    tr []
        [ td [] [ text option.vim ]
        , td [] [ text option.emacs ]
        ]
