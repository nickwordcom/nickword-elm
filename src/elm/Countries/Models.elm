module Countries.Models exposing (..)

import Entries.Models exposing (EntryId)


type alias CountryCode =
    String


type alias Country =
    { code : CountryCode
    , name : String
    }


type alias CountryWithVotes =
    { code : CountryCode
    , votes : Int
    }


type alias EntryVotedCountries =
    { entryId : EntryId
    , countries : List CountryWithVotes
    }


entryVotedCountriesInit : EntryVotedCountries
entryVotedCountriesInit =
    { entryId = ""
    , countries = []
    }
