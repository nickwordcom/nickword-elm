module Countries.Messages exposing (..)

import App.Models exposing (WebData)
import Countries.Models exposing (Country)


type Msg
    = NoOp
    | CountriesResponse (WebData (List Country))
