module Main exposing (..)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html
--

import Array
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
import Html.Events exposing (onClick, onInput)
import Maybe



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


type Status
    = Compatible
    | NOOP
    | Incompatible
    | Unknown


type alias Option =
    { vim : String
    , emacs : String
    , param : Maybe String
    , status : Status
    }


type alias Model =
    { options : Array.Array Option
    , accordionState : Accordion.State
    }


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
                , Option "set shiftwidth" "TODO" (Just "4") Unknown
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
      }
    , Cmd.none
    )


type Msg
    = AccordionMsg Accordion.State
      -- | SetOptionValue Int (Maybe String)
    | SetOptionValue String



-- | Change String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AccordionMsg state ->
            ( { model | accordionState = state }
            , Cmd.none
            )

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
            |> Accordion.cards (Array.map viewOption model.options |> Array.toList)
            |> Accordion.view model.accordionState
        ]


viewOptionStatus : Option -> Html Msg
viewOptionStatus option =
    let
        ( textClass, icon ) =
            case option.status of
                Compatible ->
                    ( "text-success", Icon.check )

                NOOP ->
                    ( "text-info", Icon.smile )

                Incompatible ->
                    ( "text-danger", Icon.times )

                Unknown ->
                    ( "text-warning", Icon.exclamationTriangle )
    in
    span
        [ class "float-right"
        , class textClass
        ]
        [ icon |> Icon.viewStyled [ Icon.lg ] ]


viewOption : Option -> Accordion.Card Msg
viewOption option =
    Accordion.card
        { id = option.vim
        , options = []
        , header =
            (Accordion.header [] <|
                Accordion.toggle []
                    [ h3 [] [ text option.vim ] ]
            )
                |> Accordion.appendHeader [ viewOptionStatus option ]
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
                , input [ name (uniqName option), value x, onInput SetOptionValue ] []
                ]
