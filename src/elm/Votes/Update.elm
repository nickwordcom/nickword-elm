module Votes.Update exposing (..)

import App.Models exposing (Model, RemoteData(..), WebData)
import App.Ports exposing (entryVotesMap, setLocalJWT)
import App.Translations exposing (..)
import App.Utils.Converters exposing (increaseEntryEmotions)
import Countries.Models exposing (CountryWithVotes, EntryVotedCountries)
import Entries.Models exposing (Entry, EntryId, FiltersConfig)
import List.Extra as ListEx
import Material.Helpers exposing (map1st, map2nd)
import Material.Snackbar as Snackbar
import Regex
import Users.Utils exposing (activateUser)
import Votes.Messages exposing (Msg(..))
import Votes.Models exposing (..)
import Words.Models exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        EntryVotesResponse response ->
            ( { model | entryVotes = response }, Cmd.none )

        EntryVotesSlimResponse response ->
            let
                votes =
                    votesFromResponse response model.entryFilters

                distribution =
                    distributionFromResponse response
            in
            { model | entryVotesSlim = votes, entryEmotionsInfo = distribution }
                ! [ sendVotesToMap votes ]

        AddNewVote (Ok voteResponse) ->
            let
                updatedEntryVotedWords =
                    updateEntryVotedWords voteResponse model.entryVotedWords

                updatedEntryVotedCountries =
                    updateEntryVotedCountries voteResponse model.entryVotedCountries

                updatedEntryEmotionsInfo =
                    updateEmotionsInfo voteResponse model.entryEmotionsInfo

                numberOfVotes =
                    countNumberOfVotes updatedEntryVotedWords

                notCountedMessage =
                    translate model.appLanguage <| VoteIsNotCounted voteResponse.word.name

                numberOfVotesMessage =
                    translate model.appLanguage <| NVotesOutOfText numberOfVotes 5

                ( snackbar, snackEffect ) =
                    if voteResponse.counted && numberOfVotes >= 4 then
                        Snackbar.add (Snackbar.toast 0 numberOfVotesMessage) model.snackbar
                            |> map2nd (Cmd.map Snackbar)
                    else if voteResponse.counted then
                        ( model.snackbar, Cmd.none )
                    else
                        Snackbar.add (Snackbar.toast 0 notCountedMessage) model.snackbar
                            |> map2nd (Cmd.map Snackbar)

                ( newUser, jwtCmd ) =
                    case voteResponse.newJWT of
                        Just jwt ->
                            ( activateUser jwt, setLocalJWT jwt )

                        Nothing ->
                            ( model.user, Cmd.none )
            in
            { model
                | entryWords = updateEntryWords model.entryWords voteResponse
                , entry = updateEntryVotesCounter model.entry voteResponse
                , entryVotedWords = updatedEntryVotedWords
                , entryVotedCountries = updatedEntryVotedCountries
                , entryEmotionsInfo = updatedEntryEmotionsInfo
                , user = newUser
                , snackbar = snackbar
            }
                ! [ snackEffect, jwtCmd ]

        AddNewVote (Err _) ->
            let
                toastMessage =
                    translate model.appLanguage SomethingWentWrong

                ( snackbar, snackEffect ) =
                    Snackbar.add (Snackbar.toast 0 toastMessage) model.snackbar
                        |> map2nd (Cmd.map Snackbar)
            in
            { model | snackbar = snackbar } ! [ snackEffect ]

        EntryVotedCountriesResponse (Ok response) ->
            { model | entryVotedCountries = response } ! []

        EntryVotedCountriesResponse (Err _) ->
            model ! []

        Snackbar msg ->
            Snackbar.update msg model.snackbar
                |> map1st (\s -> { model | snackbar = s })
                |> map2nd (Cmd.map Snackbar)


updateEntryWords : WebData (List Word) -> VoteResponse -> WebData (List Word)
updateEntryWords entryWords voteResponse =
    case entryWords of
        Loading ->
            entryWords

        Failure err ->
            entryWords

        Success entryWords ->
            Success (updateWord voteResponse entryWords)


updateWord : VoteResponse -> List Word -> List Word
updateWord { word, counted } =
    let
        select existingWord =
            if existingWord.id == word.id then
                if counted then
                    { existingWord | votingFor = Nothing, votesCount = existingWord.votesCount + 1 }
                else
                    { existingWord | votingFor = Nothing }
            else
                existingWord
    in
    List.map select


updateEntryVotesCounter : WebData Entry -> VoteResponse -> WebData Entry
updateEntryVotesCounter entry { entryId, counted } =
    case entry of
        Loading ->
            entry

        Failure err ->
            entry

        Success entry ->
            let
                updatedEntry =
                    if entry.id == entryId && counted then
                        { entry | votesCount = entry.votesCount + 1 }
                    else
                        entry
            in
            Success updatedEntry


updateEntryVotedWords : VoteResponse -> WebData EntryVotedWords -> WebData EntryVotedWords
updateEntryVotedWords { word, entryId, counted } entryVotedWords =
    if counted then
        case entryVotedWords of
            Loading ->
                Success { entryId = entryId, ids = word.id :: [] }

            Failure err ->
                Success { entryId = entryId, ids = word.id :: [] }

            Success votedIds ->
                Success { votedIds | ids = word.id :: votedIds.ids }
    else
        entryVotedWords


updateEntryVotedCountries : VoteResponse -> EntryVotedCountries -> EntryVotedCountries
updateEntryVotedCountries { countryCode } { entryId, countries } =
    let
        voteCountryCode =
            countryCode

        countryPresent =
            countries
                |> List.map .code
                |> List.member voteCountryCode

        updatedCountries =
            if countryPresent then
                List.map (updateCountryVotes voteCountryCode) countries
            else
                { code = voteCountryCode, votes = 1 } :: countries
    in
    { entryId = entryId, countries = updatedCountries }


updateCountryVotes : String -> CountryWithVotes -> CountryWithVotes
updateCountryVotes voteCountryCode country =
    if voteCountryCode == country.code then
        { country | votes = country.votes + 1 }
    else
        country


updateEmotionsInfo : VoteResponse -> Maybe (List EmotionInfo) -> Maybe (List EmotionInfo)
updateEmotionsInfo { word, counted } emotionsInfo =
    if counted then
        case emotionsInfo of
            Nothing ->
                emotionsInfo

            Just emotions ->
                Just (increaseEntryEmotions word emotions)
    else
        emotionsInfo


sendVotesToMap : WebData (List VoteSlim) -> Cmd Msg
sendVotesToMap entryVotes =
    case entryVotes of
        Loading ->
            Cmd.none

        Failure err ->
            Cmd.none

        Success votes ->
            entryVotesMap votes


votesFromResponse : WebData VotesSlimResponse -> FiltersConfig -> WebData (List VoteSlim)
votesFromResponse response filtersConfig =
    case response of
        Loading ->
            Loading

        Failure error ->
            Failure error

        Success { votes, distribution } ->
            if filtersConfig.translate then
                Success <| translateWords votes
            else
                Success votes


distributionFromResponse : WebData VotesSlimResponse -> Maybe (List EmotionInfo)
distributionFromResponse response =
    case response of
        Loading ->
            Nothing

        Failure error ->
            Nothing

        Success { votes, distribution } ->
            Just distribution


countNumberOfVotes : WebData EntryVotedWords -> Int
countNumberOfVotes votedWords =
    case votedWords of
        Success { ids } ->
            List.length ids

        _ ->
            0



-- TODO: update translateWords like in combineEntryWords


translateWords : List VoteSlim -> List VoteSlim
translateWords votes =
    votes
        |> ListEx.updateIf wordTranslated (\v -> { v | wordName = v.wordEn })
        |> List.filter (\v -> Regex.contains (Regex.regex wordNameRegex) v.wordName)


wordTranslated : VoteSlim -> Bool
wordTranslated vote =
    not (String.isEmpty vote.wordEn)
