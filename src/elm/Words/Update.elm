module Words.Update exposing (..)

-- import Regex

import App.Models exposing (Model, RemoteData(..), WebData)
import App.Ports exposing (entryWordCloud)
import App.Routing exposing (Route(EntryCloudRoute, EntryRoute))
import App.Translations exposing (..)
import Dict
import Dict.Extra as DictEx
import Dom.Scroll as DScroll
import Entries.Models exposing (Entry, EntryId, FiltersConfig)
import List exposing (append, partition)
import List.Extra as ListEx
import Material
import Material.Helpers exposing (map1st, map2nd)
import Material.Layout exposing (mainId)
import Material.Snackbar as Snackbar
import String exposing (filter, toLower)
import Task
import Users.Models exposing (User, UserStatus(Active), UserToken)
import Votes.Commands as VotesCmds exposing (addNewVote)
import Votes.Update as VotesUpdate
import Words.Commands as WCmd exposing (addNewWord, fetchEntryWords)
import Words.Messages exposing (Msg(..))
import Words.Models exposing (..)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        EntryWordsResponse response ->
            let
                words =
                    wordsFromResponse response model.entryFilters

                distribution =
                    distributionFromResponse response

                topWord =
                    checkForTopWord words

                entryFilters =
                    model.entryFilters

                updatedEntryFilters =
                    { entryFilters | moreWordsLoading = False }
            in
            { model
                | entryWords = words
                , entryTopWord = topWord
                , entryEmotionsInfo = distribution
                , entryFilters = updatedEntryFilters
            }
                ! [ entryWordsResponseCmd words model.route ]

        EntryVotedWordsResponse response ->
            { model | entryVotedWords = response } ! []

        ShowMoreWords ->
            let
                entryFilters =
                    model.entryFilters

                updatedEntryFilters =
                    { entryFilters | limit = Just 100, moreWordsLoading = True }
            in
            { model | entryFilters = updatedEntryFilters }
                ! [ applyEntryFilters model.route updatedEntryFilters ]

        VoteForWord wordId entryId ->
            if model.user.status == Active then
                { model | entryWords = updateVotedForWord model.entryWords wordId }
                    ! [ VotesCmds.addNewVote entryId wordId model.user.jwt |> Cmd.map VotesMsg ]
            else
                let
                    logInMsg =
                        translate model.appLanguage LogInToastText

                    customToast =
                        { message = logInMsg, action = Nothing, payload = 0, timeout = 5000, fade = 250 }

                    ( snackbar, command ) =
                        Snackbar.add customToast model.snackbar
                            |> map2nd (Cmd.map Snackbar)
                in
                { model | snackbar = snackbar }
                    ! [ command ]

        UpdateWordSearchField value ->
            { model | wordSearchValue = String.toLower (String.filter (\c -> c /= ' ') value) }
                ! []

        ClearWordsSearchValue ->
            { model | wordSearchValue = "" }
                ! []

        UpdateNewWordValue value ->
            { model | newWordValue = String.filter (\c -> c /= ' ') value }
                ! []

        AddNewWord value entryId ->
            let
                tooShortMsg =
                    translate model.appLanguage ShortWord

                logInMsg =
                    translate model.appLanguage LogInToastText

                customToast =
                    { message = logInMsg, action = Nothing, payload = 0, timeout = 5000, fade = 250 }

                ( snackbar, command ) =
                    if model.user.status /= Active then
                        Snackbar.add customToast model.snackbar
                            |> map2nd (Cmd.map Snackbar)
                    else if String.length value < 2 then
                        Snackbar.add (Snackbar.toast 0 tooShortMsg) model.snackbar
                            |> map2nd (Cmd.map Snackbar)
                    else
                        ( model.snackbar, WCmd.addNewWord value entryId model.user.jwt )
            in
            { model | newWordValue = "", snackbar = snackbar }
                ! [ command ]

        AddNewWordData (Ok newWord) ->
            let
                toastMessage =
                    translate model.appLanguage (WordSuccessfullyAdded newWord.name)

                ( snackbar, snackEffect ) =
                    Snackbar.add (Snackbar.toast 0 toastMessage) model.snackbar
                        |> map2nd (Cmd.map Snackbar)
            in
            { model
                | entryWords = updateEntryWords model.entryWords newWord
                , snackbar = snackbar
            }
                ! [ snackEffect, voteForNewWordCmd model.entry newWord.id model.user.jwt ]

        AddNewWordData (Err _) ->
            let
                toastMessage =
                    translate model.appLanguage SomethingWentWrong

                ( snackbar, snackEffect ) =
                    Snackbar.add (Snackbar.toast 0 toastMessage) model.snackbar
                        |> map2nd (Cmd.map Snackbar)
            in
            { model | snackbar = snackbar }
                ! [ snackEffect ]

        UpdateShareDialogValues entry wordName ->
            let
                oldDialog =
                    model.shareDialog

                updatedDialog =
                    { oldDialog
                        | title = entry.title
                        , subTitle = translate model.appLanguage InOneWord
                        , word = wordName
                        , imageUrl = entry.image.url
                        , editing = False
                        , entrySlug = entry.slug
                        , entryId = entry.id
                    }
            in
            { model | shareDialog = updatedDialog }
                ! []

        SelectMenuItem str ->
            model ! []

        SetElevation bool ->
            { model | newWordFieldActive = bool }
                ! []

        ShowTopLoginForm ->
            { model | loginFormTopBlockOpen = True }
                ! [ DScroll.toTop mainId |> Task.attempt (always NoOp) ]

        VotesMsg subMsg ->
            let
                ( newModel, cmd ) =
                    VotesUpdate.update subMsg model
            in
            ( newModel, Cmd.map VotesMsg cmd )

        Snackbar msg ->
            Snackbar.update msg model.snackbar
                |> map1st (\s -> { model | snackbar = s })
                |> map2nd (Cmd.map Snackbar)

        MDL msg ->
            Material.update MDL msg model



-- Helpers


updateEntryWords : WebData (List Word) -> Word -> WebData (List Word)
updateEntryWords entryWords newWord =
    case entryWords of
        Loading ->
            entryWords

        Failure err ->
            entryWords

        Success entryWords ->
            let
                findWord word =
                    if word.id == newWord.id then
                        Just word
                    else
                        Nothing

                existingWord =
                    List.head (List.filterMap findWord entryWords)
            in
            case existingWord of
                Just word ->
                    Success entryWords

                Nothing ->
                    Success ({ newWord | votingFor = Just True } :: entryWords)


updateVotedForWord : WebData (List Word) -> WordId -> WebData (List Word)
updateVotedForWord entryWords wordId =
    case entryWords of
        Success entryWords ->
            Success (updateWordStatus wordId entryWords)

        _ ->
            entryWords


updateWordStatus : WordId -> List Word -> List Word
updateWordStatus wordId =
    let
        select existingWord =
            if existingWord.id == wordId then
                { existingWord | votingFor = Just True }
            else
                existingWord
    in
    List.map select


voteForNewWordCmd : WebData Entry -> WordId -> UserToken -> Cmd Msg
voteForNewWordCmd entry wordId token =
    case entry of
        Success entry ->
            Cmd.map VotesMsg <| VotesCmds.addNewVote entry.id wordId token

        _ ->
            Cmd.none


wordsFromResponse : WebData WordsResponse -> FiltersConfig -> WebData (List Word)
wordsFromResponse response filtersConfig =
    case response of
        Loading ->
            Loading

        Failure error ->
            Failure error

        Success { words, distribution } ->
            if filtersConfig.translate then
                Success <| combineEntryWords words
            else
                Success words


distributionFromResponse : WebData WordsResponse -> Maybe (List EmotionInfo)
distributionFromResponse response =
    case response of
        Loading ->
            Nothing

        Failure error ->
            Nothing

        Success { words, distribution } ->
            Just distribution


checkForTopWord : WebData (List Word) -> Maybe Word
checkForTopWord entryWords =
    case entryWords of
        Success words ->
            List.head words

        _ ->
            Nothing


entryWordsResponseCmd : WebData (List Word) -> Route -> Cmd Msg
entryWordsResponseCmd response route =
    case route of
        EntryCloudRoute _ _ ->
            sendWordsToCloud response

        _ ->
            Cmd.none


sendWordsToCloud : WebData (List Word) -> Cmd Msg
sendWordsToCloud entryWords =
    case entryWords of
        Success words ->
            entryWordCloud words

        _ ->
            Cmd.none


applyEntryFilters : Route -> FiltersConfig -> Cmd Msg
applyEntryFilters route filtersConfig =
    case route of
        EntryRoute slug id ->
            fetchEntryWords id filtersConfig

        _ ->
            Cmd.none


combineEntryWords : List Word -> List Word
combineEntryWords words =
    words
        |> ListEx.updateIf wordTranslated updateWordNameToEn
        -- |> List.filter (\w -> Regex.contains (Regex.regex wordNameRegex) w.name)
        |> List.filter (\w -> w.lang == "en")
        |> DictEx.groupBy .name
        |> Dict.map sumUpWords
        |> Dict.values
        |> List.concat
        |> List.sortBy .votesCount
        |> List.reverse


wordTranslated : Word -> Bool
wordTranslated word =
    word.lang /= "en" && not (String.isEmpty word.en)


updateWordNameToEn : Word -> Word
updateWordNameToEn word =
    { word | name = word.en, lang = "en", en = "" }


sumUpWords : String -> List Word -> List Word
sumUpWords key words =
    let
        counter =
            List.map .votesCount words
                |> List.sum

        firstWord =
            words
                |> List.head
                |> Maybe.withDefault initWord

        mainWord =
            words
                |> List.filter (\w -> w.lang == "en")
                |> List.head
                |> Maybe.withDefault firstWord
    in
    { mainWord | votesCount = counter } :: []
