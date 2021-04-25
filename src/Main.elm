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
    , Option "set showmatch" "bar"
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
