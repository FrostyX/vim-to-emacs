module Logic exposing (..)

import Models exposing (..)
import String.Interpolate exposing (interpolate)


vimDocumentation : Option -> String
vimDocumentation option =
    interpolate "https://vimhelp.org/options.txt.html#%27{0}%27" [ vimName option ]


vimName : Option -> String
vimName option =
    -- We need to drop the `set' part
    option.vim |> String.dropLeft 4
