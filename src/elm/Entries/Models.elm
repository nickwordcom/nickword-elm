module Entries.Models exposing (..)

import Categories.Models exposing (Category)


type alias EntryId =
    String


type alias EntrySlug =
    String


type alias CategoryId =
    String


type EntryTab
    = WordList
    | WordCloud
    | VotesMap
    | VotesList


type alias Entry =
    { id : EntryId
    , slug : EntrySlug
    , title : String
    , description : String
    , image : EntryImage
    , category : Category
    , votesCount : Int
    }


type alias EntryImage =
    { url : String
    , caption : String
    }


type alias NewEntry =
    { title : String
    , description : String
    , imageUrl : String
    , imageCaption : String
    , categoryId : CategoryId
    }


newEntryInit : NewEntry
newEntryInit =
    { title = ""
    , description = ""
    , imageUrl = ""
    , imageCaption = ""
    , categoryId = ""
    }


type LoadMoreState
    = EntriesNotAsked
    | EntriesLoading
    | EntriesFull


type FilterType
    = SelectFromCountry (Maybe String)
    | SelectWithEmotions (Maybe String)
    | Translate


type alias FiltersConfig =
    { country : Maybe String
    , emotions : Maybe String
    , translate : Bool
    , limit : Maybe Int
    , filtersExpanded : Bool
    , showOnlyTopWords : Bool
    }


filtersConfigInit : FiltersConfig
filtersConfigInit =
    { country = Nothing
    , emotions = Nothing
    , translate = False
    , limit = Just 100
    , filtersExpanded = False
    , showOnlyTopWords = True
    }
