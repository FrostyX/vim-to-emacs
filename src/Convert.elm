module Convert exposing (..)

import Array
import Models exposing (..)
import String.Interpolate exposing (interpolate)


evilPackage : String
evilPackage =
    "(use-package evil\n"
        ++ "  :ensure t\n"
        ++ "  :config\n"
        ++ "  (evil-mode))\n\n"


convertVimToEmacs : String -> Array.Array Option -> String
convertVimToEmacs vimConfig options =
    vimConfig
        |> String.lines
        |> List.map String.trim
        |> List.map (\x -> convertOption x options)
        |> String.join "\n"
        |> String.append evilPackage


convertOption : String -> Array.Array Option -> String
convertOption configLine options =
    if String.startsWith "#" configLine then
        -- This config line is a comment
        ";; " ++ removeCommentSigns configLine

    else if String.filter (\x -> x /= ' ') configLine |> String.isEmpty then
        -- This config line is only a whitespace
        configLine

    else
        -- This config line is some kind of option
        let
            split =
                String.split "=" configLine |> Array.fromList |> Array.map String.trim

            name =
                split
                    |> Array.get 0
                    |> Maybe.withDefault configLine
                    |> removeComment
                    |> String.trim

            value =
                split |> Array.get 1
        in
        case Array.filter (\option -> option.vim == name) options |> Array.get 0 of
            Nothing ->
                ";; Unknown alternative to " ++ configLine

            Just option ->
                let
                    -- Is this an option that is supposed to have a value but it is missing?
                    missingValue =
                        option.param /= Nothing && (value |> Maybe.withDefault "" |> String.isEmpty)

                    defaultedValue =
                        if missingValue then
                            option.param

                        else if option.param == Nothing then
                            Nothing

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
                        , parameterizedEmacsOption option defaultedValue
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


parameterizedVimOption : String -> Maybe String -> String
parameterizedVimOption vim param =
    case param of
        Nothing ->
            vim

        Just x ->
            vim ++ "=" ++ x


parameterizedEmacsOption : Option -> Maybe String -> String
parameterizedEmacsOption option param =
    case ( option.emacs, param ) of
        ( Just emacsValue, Nothing ) ->
            emacsValue

        ( Just emacsValue, Just value ) ->
            interpolate emacsValue [ value ]

        ( Nothing, _ ) ->
            interpolate ";; The `{0}' option is NOOP for emacs" [ option.vim ]
