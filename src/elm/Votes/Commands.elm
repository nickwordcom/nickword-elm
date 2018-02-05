module Votes.Commands exposing (..)

import App.Utils.Config exposing (apiUrl)
import App.Utils.Requests exposing (encodeUrl, postWithAuth)
import Countries.Models exposing (..)
import Entries.Models exposing (EntryId, FiltersConfig)
import Http
import Json.Decode as Decode exposing (field)
import Json.Encode as Encode
import RemoteData
import Users.Models exposing (UserToken)
import Votes.Messages exposing (Msg(..))
import Votes.Models exposing (..)
import Words.Commands exposing (emotionInfoDecoder, wordDecoder)
import Words.Models exposing (WordId)


-- HTTP Requests


fetchEntryVotes : EntryId -> FiltersConfig -> Cmd Msg
fetchEntryVotes entryId filtersConfig =
    Http.get (entryVotesUrl entryId filtersConfig) votesResponseDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntryVotesResponse


addNewVote : EntryId -> WordId -> UserToken -> Cmd Msg
addNewVote entryId wordId token =
    postWithAuth (votesUrl entryId wordId) Encode.null createdVoteDecoder token
        |> Http.send AddNewVote


fetchEntryVotedCountries : EntryId -> Cmd Msg
fetchEntryVotedCountries entryId =
    Http.get (entryVotedCountriesUrl entryId) entryVotedCountriesDecoder
        |> Http.send EntryVotedCountriesResponse



-- URLs


entryVotesUrl : EntryId -> FiltersConfig -> String
entryVotesUrl entryId { country, emotions } =
    let
        baseUrl =
            apiUrl ++ "/entries/" ++ entryId ++ "/votes"

        countryParam =
            case country of
                Just code ->
                    ( "country", code )

                Nothing ->
                    ( "", "" )

        emotionsParam =
            case emotions of
                Just emotion ->
                    ( "emotions", emotion )

                Nothing ->
                    ( "", "" )

        params =
            [ countryParam, emotionsParam ]
                |> List.filter (\p -> p /= ( "", "" ))
    in
    encodeUrl baseUrl params


votesUrl : EntryId -> WordId -> String
votesUrl entryId wordId =
    apiUrl ++ "/entries/" ++ entryId ++ "/words/" ++ wordId ++ "/votes"


entryVotedCountriesUrl : EntryId -> String
entryVotedCountriesUrl entryId =
    apiUrl ++ "/entries/" ++ entryId ++ "/votes/countries"



-- DECODERS


votesResponseDecoder : Decode.Decoder VotesResponse
votesResponseDecoder =
    Decode.map2 VotesResponse
        (field "data" (Decode.list voteDecoder))
        (field "distribution" (Decode.list emotionInfoDecoder))


voteDecoder : Decode.Decoder Vote
voteDecoder =
    Decode.map8 Vote
        (field "word" Decode.string)
        (field "word_en" Decode.string)
        (field "emotion" Decode.string)
        (field "country" Decode.string)
        (field "city" Decode.string)
        (field "lat" Decode.float)
        (field "lon" Decode.float)
        (field "created_at" Decode.string)


createdVoteDecoder : Decode.Decoder VoteResponse
createdVoteDecoder =
    Decode.map5 VoteResponse
        (Decode.at [ "data", "word" ] wordDecoder)
        (Decode.at [ "data", "entry_id" ] Decode.string)
        (Decode.at [ "data", "counted" ] Decode.bool)
        (Decode.at [ "data", "country_code" ] Decode.string)
        (Decode.at [ "data", "jwt" ] (Decode.nullable Decode.string))


entryVotedCountriesDecoder : Decode.Decoder EntryVotedCountries
entryVotedCountriesDecoder =
    Decode.map2 EntryVotedCountries
        (Decode.at [ "data", "entry_id" ] Decode.string)
        (Decode.at [ "data", "countries" ] (Decode.list countryWithVotes))


countryWithVotes : Decode.Decoder CountryWithVotes
countryWithVotes =
    Decode.map2 CountryWithVotes
        (field "code" Decode.string)
        (field "votes" Decode.int)



-- ENCODERS
