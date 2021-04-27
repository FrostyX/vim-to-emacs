module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Browser
import Html exposing (Html, button, div, h1, h2, h3, input, p, pre, table, td, text, th, thead, tr)
import Html.Attributes exposing (name, value)
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
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Grid.row []
            [ Grid.col []
                [ h1 [] [ text "Vim to Emacs" ]
                , viewOptionSections model
                ]
            ]
        ]


viewOptionSections : Model -> Html Msg
viewOptionSections model =
    div []
        ([ h2 [] [ text "Vim options" ] ]
            ++ List.map viewOption model
        )


viewOption : Option -> Html Msg
viewOption option =
    div []
        [ h3 [] [ text option.vim ]
        , p [] [ text "Some description of the Vim command" ]
        , p [] [ text "Vim configuration" ]
        , viewInput option
        , pre [] [ text (parameterizedVimOption option.vim option.param) ]
        , p [] [ text "Emacs configuration" ]
        , pre [] [ text option.emacs ]
        , p [] [ text "Some note about incompatibility or something" ]
        ]


parameterizedVimOption : String -> Maybe String -> String
parameterizedVimOption vim param =
    case param of
        Nothing ->
            vim

        Just x ->
            vim ++ "=" ++ x


uniqName : Option -> String
uniqName option =
    String.replace " " "-" option.vim


viewInput : Option -> Html Msg
viewInput option =
    case option.param of
        Nothing ->
            text ""

        Just x ->
            p []
                [ text "This option accepts a parameter: "
                , input [ name (uniqName option), value x ] []
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
