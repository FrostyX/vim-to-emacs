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
    case parseConfigLine configLine options of
        Comment line ->
            ";; " ++ removeCommentSigns configLine

        Whitespace line ->
            line

        Unrecognized line ->
            ";; Unknown alternative to "
                ++ line

        OptionWithMissingValue option value ->
            ";; Missing option value, using default\n"
                ++ convertOptionLine option value

        OptionLine option value ->
            convertOptionLine option value


isComment : String -> Bool
isComment configLine =
    configLine
        |> String.trim
        |> String.startsWith "#"


isWhitespace : String -> Bool
isWhitespace configLine =
    configLine
        |> String.filter (\x -> x /= ' ')
        |> String.isEmpty


findOption : String -> Array.Array Option -> Maybe Option
findOption name options =
    options
        |> Array.filter (\option -> option.vim == name)
        |> Array.get 0


isValueMissing : Option -> Maybe String -> Bool
isValueMissing option value =
    -- Is this an option that is supposed to have a value but it is missing?
    option.param
        /= Nothing
        && (value |> Maybe.withDefault "" |> String.isEmpty)


defaultedValue : Option -> Maybe String -> Maybe String
defaultedValue option value =
    if isValueMissing option value then
        option.param

    else if option.param == Nothing then
        Nothing

    else
        value |> Maybe.withDefault "" |> removeComment |> String.trim |> Just


parseConfigLine : String -> Array.Array Option -> ConfigLine
parseConfigLine configLine options =
    if isComment configLine then
        Comment configLine

    else if isWhitespace configLine then
        Whitespace configLine

    else
        let
            nameValue =
                parseOptionNameValue configLine
        in
        case findOption nameValue.name options of
            Nothing ->
                Unrecognized configLine

            Just option ->
                if isValueMissing option nameValue.value then
                    OptionWithMissingValue option nameValue.value

                else
                    OptionLine option nameValue.value


parseOptionNameValue : String -> { name : String, value : Maybe String }
parseOptionNameValue configLine =
    let
        split =
            String.split "=" configLine
                |> Array.fromList
                |> Array.map String.trim

        name =
            split
                |> Array.get 0
                |> Maybe.withDefault configLine
                |> removeComment
                |> String.trim

        value =
            split |> Array.get 1
    in
    { name = name, value = value }


convertOptionLine : Option -> Maybe String -> String
convertOptionLine option value =
    interpolate ";; {0}\n{1}\n"
        [ parameterizedVimOption option.vim <| defaultedValue option value
        , parameterizedEmacsOption option <| defaultedValue option value
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
