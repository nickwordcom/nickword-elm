module Votes.Models exposing (..)

import Entries.Models exposing (EntryId)
import Words.Models exposing (EmotionInfo, Word)


type alias VotesSlimResponse =
    { votes : List VoteSlim
    , distribution : List EmotionInfo
    }


type alias VoteSlim =
    { wordName : String
    , wordEmotion : String
    , wordEn : String
    , lat : Float
    , lon : Float
    }


type alias Vote =
    { wordName : String
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
