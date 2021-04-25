module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Browser
import Html exposing (Html, button, div, table, td, text, th, thead, tr)
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
    table []
        (List.concat
            [ [ thead []
                    [ th [] [ text "Vim" ]
                    , th [] [ text "Emacs" ]
                    ]
              ]
            , List.map viewOption model
            ]
        )


viewOption : Option -> Html Msg
viewOption option =
    tr []
        [ td [] [ text option.vim ]
        , td [] [ text option.emacs ]
        ]
