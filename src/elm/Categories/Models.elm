module Categories.Models exposing (..)


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
    , title = ""
    , entriesCount = 1
    }
