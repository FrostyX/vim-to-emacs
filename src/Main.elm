module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Bootstrap.Accordion as Accordion
import Bootstrap.Button as Button
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Grid as Grid
import Browser
import FontAwesome.Attributes as Icon
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Layering as Icon
import FontAwesome.Regular as RegularIcon
import FontAwesome.Solid as Icon
import FontAwesome.Styles as Icon
import FontAwesome.Svg as SvgIcon
import FontAwesome.Transforms as Icon
import Html exposing (Html, a, button, div, h1, h2, h3, i, input, p, pre, span, table, td, text, th, thead, tr)
import Html.Attributes exposing (attribute, class, href, id, name, value)
import Html.Events exposing (onClick)



-- MAIN


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



-- MODEL


type alias Option =
    { vim : String
    , emacs : String
    , param : Maybe String
    }


type alias Model =
    { options : List Option
    , accordionState : Accordion.State
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { options =
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

      -- Use `Accordion.initialState` to have everything collapsed
      , accordionState = Accordion.initialStateCardOpen "set nofoldenable"
      }
    , Cmd.none
    )


type Msg
    = AccordionMsg Accordion.State


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AccordionMsg state ->
            ( { model | accordionState = state }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Icon.css
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
        [ h2 [] [ text "Vim options" ]
        , Accordion.config AccordionMsg
            |> Accordion.withAnimation
            |> Accordion.cards (List.map viewOption model.options)
            |> Accordion.view model.accordionState
        ]


viewOption : Option -> Accordion.Card Msg
viewOption option =
    Accordion.card
        { id = option.vim
        , options = []
        , header =
            Accordion.header [] <|
                Accordion.toggle []
                    [ h3 [] [ text option.vim ] ]
        , blocks =
            [ Accordion.block []
                [ Block.text []
                    [ text "Some description of the Vim command" ]
                , Block.custom <|
                    p []
                        [ Icon.cross
                            |> Icon.present
                            |> Icon.transform [ Icon.rotate 180 ]
                            |> Icon.styled [ Icon.lg ]
                            |> Icon.view
                        , text " Vim configuration"
                        ]
                , Block.custom <| viewInput option
                , Block.custom <|
                    pre [] [ text (parameterizedVimOption option.vim option.param) ]
                , Block.custom <|
                    p []
                        [ Icon.bible |> Icon.viewStyled [ Icon.lg ]
                        , text " Emacs configuration"
                        ]
                , Block.custom <| pre [] [ text option.emacs ]
                , Block.text []
                    [ text "Some note about incompatibility or something" ]
                ]
            ]
        }


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
            , List.map viewOptionRow model.options
            ]
        )


viewOptionRow : Option -> Html Msg
viewOptionRow option =
    tr []
        [ td [] [ text option.vim ]
        , td [] [ text option.emacs ]
        ]
