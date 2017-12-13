module Categories.Models exposing (..)

import Entries.Models exposing (Entry)


type alias CategoryId =
    String


type alias CategorySlug =
    String


type alias Category =
    { id : CategoryId
    , slug : String
    , title : String
    , entriesCount : Int
    }


loremCategory : Category
loremCategory =
    { id = ""
    , slug = "lorem"
    , title = "Lorem category"
    , entriesCount = 1
    }
