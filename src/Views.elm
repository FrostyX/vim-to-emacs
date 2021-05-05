module Views exposing (..)

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
import Models exposing (..)


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
