module Models exposing (..)

import Array
import Bootstrap.Accordion as Accordion
import Http


type alias Model =
    { options : Array.Array Option
    , plugins : Array.Array Plugin
    , accordionState : Accordion.State
    , vimConfig : String
    , emacsConfig : String
    }


type Msg
    = AccordionMsg Accordion.State
    | SetOptionValue String
    | Convert String
    | GotOptions (Result Http.Error (List Option))
    | GotPlugins (Result Http.Error (List Plugin))


type Status
    = Compatible
    | NOOP
    | Incompatible
    | Unknown


type alias Option =
    { vim : String
    , emacs : Maybe String
    , param : Maybe String
    , status : Status
    , emacsDocs : Maybe String
    }


type alias Plugin =
    { vim : String
    , emacs : String
    , status : Status
    , vimCode : Maybe String
    , emacsCode : Maybe String
    , vimUrl : Maybe String
    , emacsUrl : Maybe String
    , note : Maybe String
    }
