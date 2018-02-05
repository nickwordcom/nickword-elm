port module App.Ports exposing (..)

import App.Models exposing (PageInfo)
import Votes.Models exposing (Vote)
import Words.Models exposing (Word)


-- incoming values
-- port example : (String -> msg) -> Sub msg
-- outgoing values


port pageInfo : PageInfo -> Cmd msg


port setLocalLanguage : String -> Cmd msg


port setLocalJWT : String -> Cmd msg


port removeLocalJWT : () -> Cmd msg


port entryVotesMap : List Vote -> Cmd msg


port entryWordCloud : List Word -> Cmd msg


port updateGA : String -> Cmd msg
