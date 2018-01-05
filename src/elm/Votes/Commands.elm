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
    Http.get (entryVotesUrl entryId filtersConfig) votesListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntryVotesResponse


fetchEntryVotesSlim : EntryId -> FiltersConfig -> Cmd Msg
fetchEntryVotesSlim entryId filtersConfig =
    Http.get (entryVotesSlimUrl entryId filtersConfig) votesSlimResponseDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntryVotesSlimResponse


addNewVote : EntryId -> WordId -> UserToken -> Cmd Msg
addNewVote entryId wordId token =
    postWithAuth (votesUrlPOST entryId wordId) newVoteEncoded createdVoteDecoder token
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

        limitParam =
            ( "limit", "100" )

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
            [ limitParam, countryParam, emotionsParam ]
                |> List.filter (\p -> p /= ( "", "" ))
    in
    encodeUrl baseUrl params


entryVotesSlimUrl : EntryId -> FiltersConfig -> String
entryVotesSlimUrl entryId { country, emotions } =
    let
        baseUrl =
            apiUrl ++ "/entries/" ++ entryId ++ "/votes"

        selectParam =
            ( "select", "slim" )

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
            [ selectParam, countryParam, emotionsParam ]
                |> List.filter (\p -> p /= ( "", "" ))
    in
    encodeUrl baseUrl params


votesUrl : EntryId -> WordId -> String
votesUrl entryId wordId =
    apiUrl ++ "/entries/" ++ entryId ++ "/words/" ++ wordId ++ "/votes"


votesUrlPOST : EntryId -> WordId -> String
votesUrlPOST entryId wordId =
    apiUrl ++ "/p/entries/" ++ entryId ++ "/words/" ++ wordId ++ "/votes"


entryVotedCountriesUrl : EntryId -> String
entryVotedCountriesUrl entryId =
    apiUrl ++ "/entries/" ++ entryId ++ "/votes/countries"



-- DECODERS


votesListDecoder : Decode.Decoder (List Vote)
votesListDecoder =
    Decode.map identity
        (field "data" (Decode.list voteDecoder))


votesSlimResponseDecoder : Decode.Decoder VotesSlimResponse
votesSlimResponseDecoder =
    Decode.map2 VotesSlimResponse
        (field "data" (Decode.list voteSlimDecoder))
        (field "distribution" (Decode.list emotionInfoDecoder))


votesSlimListDecoder : Decode.Decoder (List VoteSlim)
votesSlimListDecoder =
    Decode.map identity
        (field "data" (Decode.list voteSlimDecoder))


voteDecoder : Decode.Decoder Vote
voteDecoder =
    Decode.map5 Vote
        (field "word_name" Decode.string)
        (field "city" Decode.string)
        (field "lat" Decode.float)
        (field "lon" Decode.float)
        (field "created_at" Decode.string)


voteSlimDecoder : Decode.Decoder VoteSlim
voteSlimDecoder =
    Decode.map5 VoteSlim
        (field "word_name" Decode.string)
        (field "word_emotion" Decode.string)
        (field "word_en" Decode.string)
        (field "lat" Decode.float)
        (field "lon" Decode.float)


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


newVoteEncoded : Encode.Value
newVoteEncoded =
    Encode.object [ ( "", Encode.string "" ) ]
