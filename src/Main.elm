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
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col
import Bootstrap.Grid.Row
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
import Html
    exposing
        ( Html
        , a
        , button
        , div
        , h1
        , h2
        , h3
        , i
        , input
        , p
        , pre
        , span
        , table
        , td
        , text
        , textarea
        , th
        , thead
        , tr
        )
import Html.Attributes exposing (attribute, class, href, id, name, value)
import Html.Events exposing (onClick, onInput)
import Maybe
import String.Interpolate exposing (interpolate)



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
    , vimConfig : String
    , emacsConfig : String
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


type Msg
    = AccordionMsg Accordion.State
      -- | SetOptionValue Int (Maybe String)
    | SetOptionValue String
    | Convert String



-- | Change String


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


convertVimToEmacs : String -> Array.Array Option -> String
convertVimToEmacs vimConfig options =
    vimConfig
        |> String.lines
        |> List.map String.trim
        |> List.map (\x -> convertOption x options)
        |> String.join "\n"


convertOption : String -> Array.Array Option -> String
convertOption configLine options =
    if String.startsWith "#" configLine then
        ";; " ++ removeCommentSigns configLine

    else if String.filter (\x -> x /= ' ') configLine |> String.isEmpty then
        configLine

    else
        let
            split =
                String.split "=" configLine |> Array.fromList |> Array.map String.trim

            name =
                split |> Array.get 0 |> Maybe.withDefault configLine

            value =
                split |> Array.get 1
        in
        case Array.filter (\option -> option.vim == name) options |> Array.get 0 of
            Nothing ->
                ";; Unknown alternative to " ++ configLine

            Just option ->
                let
                    missingValue =
                        option.param /= Nothing && (value |> Maybe.withDefault "" |> String.isEmpty)

                    defaultedValue =
                        if missingValue then
                            option.param

                        else
                            value |> Maybe.withDefault "" |> removeComment |> String.trim |> Just
                in
                (if missingValue then
                    ";; Missing option value, using default\n"

                 else
                    ""
                )
                    ++ interpolate ";; {0}\n{1}\n"
                        [ parameterizedVimOption option.vim defaultedValue
                        , parameterizedEmacsOption option.emacs defaultedValue
                        ]


removeComment : String -> String
removeComment configLine =
    configLine
        |> String.split "#"
        |> List.head
        |> Maybe.withDefault ""


removeCommentSigns : String -> String
removeCommentSigns configLine =
    if List.member (String.left 1 configLine) [ "#", " " ] then
        configLine |> String.dropLeft 1 |> removeCommentSigns

    else
        configLine



-- VIEW


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Icon.css
        , Grid.row []
            [ Grid.col []
                [ h1 [] [ text "Vim to Emacs" ]
                , viewJumbotron
                , viewConvertor model
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


parameterizedEmacsOption : String -> Maybe String -> String
parameterizedEmacsOption emacs param =
    case param of
        Nothing ->
            emacs

        Just value ->
            interpolate emacs [ value ]


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


viewJumbotron : Html Msg
viewJumbotron =
    div [] [ text "Vim to Emacs migration made easy" ]


viewConvertor : Model -> Html Msg
viewConvertor model =
    div []
        [ h2 [] [ text "Convert your config" ]
        , p [] [ text "Paste your existing Vim configuration and get it converted to Emacs Lisp code" ]
        , Grid.container []
            [ Grid.row
                []
                [ Grid.col
                    []
                    [ Textarea.textarea
                        [ Textarea.id "vim-config"
                        , Textarea.rows 11
                        , Textarea.onInput Convert
                        ]
                    ]
                , Grid.col
                    []
                    [ pre [] [ text model.emacsConfig ]
                    ]
                ]
            ]
        ]
