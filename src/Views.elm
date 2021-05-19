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
        , br
        , button
        , div
        , h1
        , h2
        , h3
        , i
        , img
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
import Html.Attributes exposing (attribute, class, href, id, name, rel, src, style, value, width)
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
                [ viewMenu
                , h1 [] [ text "Vim to Emacs" ]
                , viewJumbotron
                , viewConvertor model
                , viewOptionSections model
                , viewPlugins model
                , viewFooter
                ]
            ]
        ]


viewMenu : Html Msg
viewMenu =
    Html.nav
        [ class "navbar"
        , class "navbar-expand-lg"
        ]
        [ viewLogo
        , div
            [ class "navbar-nav"
            , class "ml-auto"
            ]
            [ viewMenuItem "Issue tracker" "https://github.com/FrostyX/vim-to-emacs/issues"
            , viewMenuItem "Source code" "https://github.com/FrostyX/vim-to-emacs"
            , viewMenuItem "License" "https://github.com/FrostyX/vim-to-emacs/blob/master/LICENSE"
            ]
        ]


viewMenuItem : String -> String -> Html Msg
viewMenuItem title url =
    a [ class "nav-link", class "nav-item", href url ]
        [ text title ]


viewLogo : Html Msg
viewLogo =
    a [ id "logo", class "navbar-brand", href "/" ]
        [ img [ width 25, src "/img/emacs.svg" ] []
        , span [] []
        , RegularIcon.heart |> Icon.viewStyled [ Icon.lg ]
        , span [] []
        , img [ width 25, src "/img/macvim.svg" ] []
        ]


viewOptionSections : Model -> Html Msg
viewOptionSections model =
    div []
        [ h2 [] [ text "Vim options" ]
        , viewAccordion model (Array.map viewOption model.options |> Array.toList)
        ]


viewPlugins : Model -> Html Msg
viewPlugins model =
    div []
        [ h2 [] [ text "Vim plugins" ]
        , viewAccordion model (Array.map viewPlugin model.plugins |> Array.toList)
        ]


viewAccordion : Model -> List (Accordion.Card Msg) -> Html Msg
viewAccordion model cards =
    Accordion.config AccordionMsg
        |> Accordion.withAnimation
        |> Accordion.cards cards
        |> Accordion.view model.accordionState


viewStatus : Status -> Html Msg
viewStatus status =
    let
        ( textClass, icon, textValue ) =
            case status of
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


viewVimIcon : Html Msg
viewVimIcon =
    img [ width 18, src "/img/macvim.svg" ] []


viewEmacsIcon : Html Msg
viewEmacsIcon =
    img [ width 18, src "/img/emacs.svg" ] []


viewCard : String -> List (Grid.Column Msg) -> Accordion.Card Msg
viewCard title content =
    Accordion.card
        { id = title
        , options = []
        , header =
            Accordion.header [] <|
                Accordion.toggle []
                    [ h3 [] [ text title ] ]
        , blocks =
            [ Accordion.block []
                [ Block.custom <|
                    Grid.container []
                        [ Grid.row [] content ]
                ]
            ]
        }


viewOption : Option -> Accordion.Card Msg
viewOption option =
    viewCard option.vim <|
        [ Grid.col []
            [ p []
                [ viewVimIcon
                , text " Vim configuration"
                ]
            , viewInput option
            , pre [] [ text (parameterizedVimOption option.vim option.param) ]
            , p []
                [ viewEmacsIcon
                , text " Emacs configuration"
                ]
            , viewEmacsCommand option
            ]
        , Grid.col [ Col.xs3 ]
            [ viewDocumentationLinks option
            ]
        ]


viewPlugin : Plugin -> Accordion.Card Msg
viewPlugin plugin =
    viewCard plugin.vim <|
        [ Grid.col []
            [ p []
                [ viewVimIcon
                , text " Vim configuration"
                ]
            , viewVimPluginCommand plugin
            , p []
                [ viewEmacsIcon
                , text " Emacs configuration"
                ]
            , viewEmacsCommand2 plugin
            , div [] [ text <| Maybe.withDefault "" plugin.note ]
            ]
        , Grid.col [ Col.xs3 ]
            [ viewPluginDocumentationLinks plugin
            ]
        ]


viewEmacsCommand : Option -> Html Msg
viewEmacsCommand option =
    case option.emacs of
        Nothing ->
            p [] [ text "This option is NOOP for emacs" ]

        Just emacsValue ->
            pre [] [ text <| parameterizedEmacsOption option option.param ]


viewEmacsCommand2 : Plugin -> Html Msg
viewEmacsCommand2 plugin =
    case plugin.emacsCode of
        Nothing ->
            p [] [ text "This plugin is NOOP for emacs" ]

        Just emacsCode ->
            pre [] [ text emacsCode ]


viewVimPluginCommand : Plugin -> Html Msg
viewVimPluginCommand plugin =
    case ( plugin.vimCode, plugin.vimUrl ) of
        ( Nothing, Just vimUrl ) ->
            p []
                [ text "See the plugin homepage for installation instructions\n"
                , br [] []
                , a [ href vimUrl ] [ text vimUrl ]
                ]

        ( Just vimCode, _ ) ->
            div []
                [ p [] [ text "Exaple installation using Vundle" ]
                , pre [] [ text vimCode ]
                ]

        ( Nothing, Nothing ) ->
            span [] []


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
            [ viewStatus option.status ]
        , ListGroup.anchor
            [ ListGroup.attrs [ href <| vimDocumentation option ] ]
            [ text "Vim documentation" ]
        , viewEmacsDocumentationLink option
        , ListGroup.anchor
            [ ListGroup.attrs [ href "https://github.com/FrostyX/vim-to-emacs/issues" ] ]
            [ text "Report issue" ]
        ]


viewPluginDocumentationLinks : Plugin -> Html Msg
viewPluginDocumentationLinks plugin =
    ListGroup.custom
        [ ListGroup.button
            [ ListGroup.disabled ]
            [ viewStatus plugin.status ]
        , case plugin.vimUrl of
            Nothing ->
                ListGroup.anchor
                    [ ListGroup.disabled ]
                    [ text "Vim plugin" ]

            Just value ->
                ListGroup.anchor
                    [ ListGroup.attrs [ href value ] ]
                    [ text "Vim plugin" ]
        , case plugin.emacsUrl of
            Nothing ->
                ListGroup.anchor
                    [ ListGroup.disabled ]
                    [ text "Emacs package" ]

            Just value ->
                ListGroup.anchor
                    [ ListGroup.attrs [ href value ] ]
                    [ text "Emacs package" ]
        , ListGroup.anchor
            [ ListGroup.attrs [ href "https://github.com/FrostyX/vim-to-emacs/issues" ] ]
            [ text "Report issue" ]
        ]


viewEmacsDocumentationLink : Option -> ListGroup.CustomItem Msg
viewEmacsDocumentationLink option =
    case option.emacsDocs of
        Nothing ->
            ListGroup.anchor
                [ ListGroup.disabled ]
                [ text "Emacs documentation" ]

        Just value ->
            ListGroup.anchor
                [ ListGroup.attrs [ href value ] ]
                [ text "Emacs documentation" ]


viewFooter : Html Msg
viewFooter =
    Html.footer []
        [ Grid.row []
            [ Grid.col [] [ viewCopyright ]
            ]
        ]


viewCopyright : Html Msg
viewCopyright =
    p []
        [ text "Jakub Kadlčík © 2021 | "
        , a [ href "http://frostyx.cz/" ]
            [ text "FrostyX.cz" ]
        ]
