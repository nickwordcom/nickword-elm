module Countries.Messages exposing (..)

import Countries.Models exposing (Country)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | CountriesResponse (WebData (List Country))
