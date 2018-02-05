module Votes.Models exposing (..)

import Entries.Models exposing (EntryId)
import Words.Models exposing (EmotionInfo, Word)


type alias VotesResponse =
    { votes : List Vote
    , distribution : List EmotionInfo
    }


type alias Vote =
    { word : String
    , wordEn : String
    , emotion : String
    , country : String
    , city : String
    , lat : Float
    , lon : Float
    , createdAt : String
    }


type alias VoteResponse =
    { word : Word
    , entryId : EntryId
    , counted : Bool
    , countryCode : String
    , newJWT : Maybe String
    }
