module Views exposing (..)

import Array
import Bootstrap.Accordion as Accordion
import Bootstrap.Button as Button
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.CDN as CDN
import Bootstrap.Card as Card
import Bootstrap.Card.Block as Block
import Bootstrap.Form.Textarea as Textarea
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid.Row
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Navbar as Navbar
import Bootstrap.Utilities.Flex as Flex
import Browser
import Convert exposing (..)
import Debug
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
        , node
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
import Html.Attributes exposing (attribute, class, href, id, name, rel, style, value)
import Html.Events exposing (onClick, onInput)
import Logic exposing (..)
import Maybe
import Models exposing (..)


stylesheet : Html msg
stylesheet =
    node "link"
        [ rel "stylesheet"
        , href "/css/style.css"
        ]
        []


view : Model -> Html Msg
view model =
    Grid.container []
        [ CDN.stylesheet -- creates an inline style node with the Bootstrap CSS
        , Icon.css
        , stylesheet
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
        ( textClass, icon, textValue ) =
            case option.status of
                Compatible ->
                    ( "text-success", Icon.check, "Compatible" )

                NOOP ->
                    ( "text-info", Icon.smile, "NOOP" )

                Incompatible ->
                    ( "text-danger", Icon.times, "Incompatible" )

                Unknown ->
                    ( "text-warning", Icon.exclamationTriangle, "Unknown" )
    in
    span
        [ class textClass
        ]
        [ icon |> Icon.viewStyled [ Icon.lg ]
        , text <| " " ++ textValue
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
                [ Block.custom <|
                    Grid.container []
                        [ Grid.row []
                            [ Grid.col []
                                [ p [] [ text "Some description of the Vim command" ]
                                , p []
                                    [ Icon.cross
                                        |> Icon.present
                                        |> Icon.transform [ Icon.rotate 180 ]
                                        |> Icon.styled [ Icon.lg ]
                                        |> Icon.view
                                    , text " Vim configuration"
                                    , viewInput option
                                    , pre []
                                        [ text (parameterizedVimOption option.vim option.param) ]
                                    , p []
                                        [ Icon.bible |> Icon.viewStyled [ Icon.lg ]
                                        , text " Emacs configuration"
                                        ]
                                    , viewEmacsCommand option
                                    , p [] [ text "Some note about incompatibility or something" ]
                                    ]
                                ]
                            , Grid.col [ Col.xs3 ]
                                [ viewDocumentationLinks option
                                ]
                            ]
                        ]
                ]
            ]
        }


viewEmacsCommand : Option -> Html Msg
viewEmacsCommand option =
    case option.emacs of
        Nothing ->
            p [] [ text "This option is NOOP for emacs" ]

        Just emacsValue ->
            pre [] [ text emacsValue ]


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


viewDocumentationLinks : Option -> Html Msg
viewDocumentationLinks option =
    ListGroup.custom
        [ ListGroup.button
            [ ListGroup.disabled ]
            [ viewOptionStatus option ]
        , ListGroup.anchor
            [ ListGroup.attrs [ href <| vimDocumentation option ] ]
            [ text "Vim documentation" ]
        , ListGroup.anchor
            []
            [ text "Emacs documentation" ]
        ]
