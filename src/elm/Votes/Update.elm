module Votes.Update exposing (..)

import App.Models exposing (Model)
import App.Ports exposing (entryVotesMap, setLocalJWT)
import App.Translations exposing (..)
import App.Utils.Converters exposing (increaseEntryEmotions)
import Countries.Models exposing (CountryWithVotes, EntryVotedCountries)
import Entries.Models exposing (Entry, EntryId, FiltersConfig)
import List.Extra as ListEx
import Material.Helpers exposing (map1st, map2nd)
import Material.Snackbar as Snackbar
import Regex
import RemoteData exposing (RemoteData(..), WebData)
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
            let
                votes =
                    votesFromResponse response model.entryFilters

                distribution =
                    distributionFromResponse response
            in
            { model | entryVotes = votes, entryEmotionsInfo = distribution }
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
                    if voteResponse.counted && List.member numberOfVotes [ 4, 5 ] then
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
        Success entryWords ->
            Success (updateWord voteResponse entryWords)

        _ ->
            entryWords


updateWord : VoteResponse -> List Word -> List Word
updateWord { word, counted } =
    let
        predicate w =
            w.id == word.id && counted

        update w =
            { w | votesCount = w.votesCount + 1 }
    in
    ListEx.updateIf predicate update


updateEntryVotedWords : VoteResponse -> WebData EntryVotedWords -> WebData EntryVotedWords
updateEntryVotedWords { word, entryId, counted } entryVotedWords =
    if counted then
        entryVotedWords
    else
        case entryVotedWords of
            Success votedWords ->
                let
                    ids =
                        ListEx.remove word.id votedWords.ids
                in
                Success { votedWords | ids = ids }

            _ ->
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


sendVotesToMap : WebData (List Vote) -> Cmd Msg
sendVotesToMap entryVotes =
    case entryVotes of
        Success votes ->
            entryVotesMap votes

        _ ->
            Cmd.none


votesFromResponse : WebData VotesResponse -> FiltersConfig -> WebData (List Vote)
votesFromResponse response filtersConfig =
    case response of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure error ->
            Failure error

        Success { votes, distribution } ->
            if filtersConfig.translate then
                Success <| translateWords votes
            else
                Success votes


distributionFromResponse : WebData VotesResponse -> Maybe (List EmotionInfo)
distributionFromResponse response =
    case response of
        Success { votes, distribution } ->
            Just distribution

        _ ->
            Nothing


countNumberOfVotes : WebData EntryVotedWords -> Int
countNumberOfVotes votedWords =
    case votedWords of
        Success { ids } ->
            List.length ids

        _ ->
            0


translateWords : List Vote -> List Vote
translateWords votes =
    votes
        |> ListEx.updateIf wordTranslated (\v -> { v | word = v.wordEn })
        |> List.filter (\v -> Regex.contains (Regex.regex wordNameRegex) v.word)


wordTranslated : Vote -> Bool
wordTranslated vote =
    not (String.isEmpty vote.wordEn)



-- updateEntryVotesCounter : WebData Entry -> VoteResponse -> WebData Entry
-- updateEntryVotesCounter entry { entryId, counted } =
--     case entry of
--         Success entry ->
--             let
--                 updatedEntry =
--                     if entry.id == entryId && counted then
--                         { entry | votesCount = entry.votesCount + 1 }
--                     else
--                         entry
--             in
--             Success updatedEntry
--
--         _ ->
--             entry
