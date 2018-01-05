module Votes.Messages exposing (..)

import Countries.Models exposing (EntryVotedCountries)
import Http exposing (Error)
import Material.Snackbar as Snackbar
import RemoteData exposing (WebData)
import Votes.Models exposing (..)


type Msg
    = NoOp
      -- Fetch entry votes
    | EntryVotesResponse (WebData (List Vote))
    | EntryVotesSlimResponse (WebData VotesSlimResponse)
      -- New Vote responses
    | AddNewVote (Result Error VoteResponse)
    | EntryVotedCountriesResponse (Result Error EntryVotedCountries)
    | Snackbar (Snackbar.Msg Int)
