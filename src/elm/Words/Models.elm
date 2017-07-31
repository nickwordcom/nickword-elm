module Words.Models exposing (..)

import Entries.Models exposing (EntryId)


type alias WordId =
    String


type alias WordName =
    String


type alias WordEmotion =
    String


type alias WordsResponse =
    { words : List Word
    , distribution : List EmotionInfo
    }


type alias Word =
    { id : WordId
    , name : WordName
    , en : String
    , lang : String
    , emotion : String
    , votesCount : Int
    , votingFor : Maybe Bool
    }


type alias EntryVotedWords =
    { entryId : EntryId
    , ids : List WordId
    }


type alias EmotionInfo =
    { emotion : WordEmotion
    , sum : Int
    , percent : Float
    }


wordEmotions : List String
wordEmotions =
    [ "positive", "neutral", "negative" ]


wordNameRegex : String
wordNameRegex =
    "^[-0-9a-zA-Z]+$"


initWord : Word
initWord =
    { id = ""
    , name = ""
    , en = ""
    , lang = ""
    , emotion = ""
    , votesCount = 0
    , votingFor = Nothing
    }
