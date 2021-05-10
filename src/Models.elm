module Models exposing (..)

import Array
import Bootstrap.Accordion as Accordion
import Http


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
    | GotOptions (Result Http.Error (List Option))


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
