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


type alias CategoryWithEntries =
    { id : CategoryId
    , slug : String
    , title : String
    , entriesCount : Int
    , entries : List Entry
    }



-- type alias CategoryWithEntries a =
--   { a
--   | entries : List Entry
--   }


loremCategory : Category
loremCategory =
    { id = ""
    , slug = "lorem"
    , title = "Lorem category"
    , entriesCount = 1
    }
