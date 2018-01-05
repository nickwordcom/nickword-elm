module Categories.Messages exposing (..)

import Categories.Models exposing (..)
import RemoteData exposing (WebData)


type Msg
    = NoOp
    | CategoriesResponse (WebData (List Category))
