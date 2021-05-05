module Models exposing (..)

import Array
import Bootstrap.Accordion as Accordion


type alias Model =
    { options : Array.Array Option
    , accordionState : Accordion.State
    , vimConfig : String
    , emacsConfig : String
    }


type Msg
    = AccordionMsg Accordion.State
    | SetOptionValue String
    | Convert String


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
