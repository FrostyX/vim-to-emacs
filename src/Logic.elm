module Logic exposing (..)

import Models exposing (..)
import String.Interpolate exposing (interpolate)


vimDocumentation : Option -> String
vimDocumentation option =
    interpolate "https://vimhelp.org/options.txt.html#%27number%27" []
