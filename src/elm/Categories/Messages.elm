module Categories.Messages exposing (..)

import App.Models exposing (WebData)
import Categories.Models exposing (..)


type Msg
    = NoOp
    | CategoriesResponse (WebData (List Category))
    | CategoriesWithEntriesResponse (WebData (List CategoryWithEntries))
