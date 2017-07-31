port module App.Ports exposing (..)

import Votes.Models exposing (VoteSlim)
import Words.Models exposing (Word)


-- incoming values
-- port example : (String -> msg) -> Sub msg
-- outgoing values


port appTitle : String -> Cmd msg


port appDescription : String -> Cmd msg


port setLocalLanguage : String -> Cmd msg


port setLocalJWT : String -> Cmd msg


port removeLocalJWT : () -> Cmd msg


port entryVotesMap : List VoteSlim -> Cmd msg


port entryWordCloud : List Word -> Cmd msg


port updateGA : String -> Cmd msg
