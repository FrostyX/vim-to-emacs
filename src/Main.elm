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
    , param : Maybe String
    }


type alias Model =
    List Option


init : Model
init =
    [ Option "set number" "(add-hook 'prog-mode-hook #'display-line-numbers-mode)" Nothing
    , Option "set nofoldenable" "TODO" Nothing
    , Option "set autowrite" "TODO" Nothing
    , Option "set showmatch" "TODO" Nothing
    , Option "set tabstop" "TODO" (Just "4")
    , Option "set shiftwidth" "TODO" (Just "4")
    , Option "set softtabstop" "TODO" (Just "4")
    , Option "set autoindent" "TODO" Nothing
    , Option "set smartindent" "TODO" Nothing
    , Option "set scrolloff" "TODO" (Just "5")
    , Option "set pastetoggle" "TODO NOOP" (Just "<F2>")
    , Option "nmap <silent> <c-k> :wincmd k<CR>" "TODO" Nothing
    , Option "nmap <silent> <c-j> :wincmd j<CR>" "TODO" Nothing
    , Option "nmap <silent> <c-h> :wincmd h<CR>" "TODO" Nothing
    , Option "nmap <silent> <c-l> :wincmd l<CR>" "TODO" Nothing
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
        , p [] [ text "Some description of the Vim command" ]
        , p [] [ text "Vim configuration" ]
        , pre [] [ text (parameterizedVimOption option.vim option.param) ]
        , p [] [ text "Emacs configuration" ]
        , pre [] [ text option.emacs ]
        , p [] [ text "Some note about incompatibility or something" ]
        ]


parameterizedVimOption : String -> Maybe String -> String
parameterizedVimOption vim value =
    case value of
        Nothing ->
            vim

        Just x ->
            vim ++ "=" ++ x


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
