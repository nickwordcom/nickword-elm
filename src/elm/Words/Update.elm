module Words.Update exposing (..)

import App.Models exposing (Model)
import App.Ports exposing (entryWordCloud)
import App.Translations exposing (..)
import Dom.Scroll as DScroll
import Entries.Models exposing (Entry, EntryId, EntryTab(WordCloud), FiltersConfig)
import List exposing (append, partition)
import List.Extra as ListEx
import Material
import Material.Helpers exposing (map1st, map2nd)
import Material.Layout exposing (mainId)
import Material.Snackbar as Snackbar
import RemoteData exposing (RemoteData(..), WebData)
import String exposing (filter, toLower)
import Task
import Users.Models exposing (User, UserToken)
import Users.Utils exposing (userIsActive)
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
                    wordsFromResponse response

                distribution =
                    distributionFromResponse response

                -- TODO: remove then top word will be with entry response
                topWord =
                    checkForTopWord words

                entryFilters =
                    model.entryFilters

                updatedEntryFilters =
                    { entryFilters | showOnlyTopWords = True }
            in
            { model
                | entryWords = words
                , entryTopWord = topWord
                , entryEmotionsInfo = distribution
                , entryFilters = updatedEntryFilters
            }
                ! [ entryWordsResponseCmd words model.entryTab ]

        EntryVotedWordsResponse response ->
            { model | entryVotedWords = response } ! []

        ShowMoreWords ->
            let
                entryFilters =
                    model.entryFilters

                updatedEntryFilters =
                    { entryFilters | showOnlyTopWords = False }
            in
            { model | entryFilters = updatedEntryFilters } ! []

        VoteForWord wordId entryId ->
            if userIsActive model.user then
                { model | entryVotedWords = updateEntryVotedWords wordId model.entryVotedWords }
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
                    if not (userIsActive model.user) then
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

                voteCmd =
                    voteForNewWordCmd model.entry newWord.id model.user.jwt

                ( snackbar, snackEffect ) =
                    Snackbar.add (Snackbar.toast 0 toastMessage) model.snackbar
                        |> map2nd (Cmd.map Snackbar)
            in
            { model
                | entryWords = pushWordToList newWord model.entryWords
                , entryVotedWords = updateEntryVotedWords newWord.id model.entryVotedWords
                , snackbar = snackbar
            }
                ! [ snackEffect, voteCmd ]

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
                        , subTitle = translate model.appLanguage InOneWordText
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


updateEntryVotedWords : String -> WebData EntryVotedWords -> WebData EntryVotedWords
updateEntryVotedWords wordId entryVotedWords =
    case entryVotedWords of
        Success votedIds ->
            Success { votedIds | ids = wordId :: votedIds.ids }

        _ ->
            entryVotedWords


pushWordToList : Word -> WebData (List Word) -> WebData (List Word)
pushWordToList newWord entryWords =
    case entryWords of
        Success words ->
            case ListEx.find (\w -> w.id == newWord.id) words of
                Just word ->
                    entryWords

                Nothing ->
                    Success (newWord :: words)

        _ ->
            entryWords


voteForNewWordCmd : WebData Entry -> WordId -> UserToken -> Cmd Msg
voteForNewWordCmd entry wordId token =
    case entry of
        Success entry ->
            Cmd.map VotesMsg <| VotesCmds.addNewVote entry.id wordId token

        _ ->
            Cmd.none


wordsFromResponse : WebData WordsResponse -> WebData (List Word)
wordsFromResponse response =
    case response of
        NotAsked ->
            NotAsked

        Loading ->
            Loading

        Failure error ->
            Failure error

        Success { words, distribution } ->
            Success words


distributionFromResponse : WebData WordsResponse -> Maybe (List EmotionInfo)
distributionFromResponse response =
    case response of
        Success { words, distribution } ->
            Just distribution

        _ ->
            Nothing


checkForTopWord : WebData (List Word) -> Maybe Word
checkForTopWord entryWords =
    case entryWords of
        Success words ->
            List.head words

        _ ->
            Nothing


entryWordsResponseCmd : WebData (List Word) -> EntryTab -> Cmd Msg
entryWordsResponseCmd response entryTab =
    case entryTab of
        WordCloud ->
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



-- combineEntryWords : List Word -> List Word
-- combineEntryWords words =
--     words
--         |> ListEx.updateIf wordTranslated updateWordNameToEn
--         -- |> List.filter (\w -> Regex.contains (Regex.regex wordNameRegex) w.name)
--         |> List.filter (\w -> w.lang == "en")
--         |> DictEx.groupBy .name
--         |> Dict.map sumUpWords
--         |> Dict.values
--         |> List.concat
--         |> List.sortBy .votesCount
--         |> List.reverse
--
--
-- wordTranslated : Word -> Bool
-- wordTranslated word =
--     word.lang /= "en" && not (String.isEmpty word.en)
--
--
-- updateWordNameToEn : Word -> Word
-- updateWordNameToEn word =
--     { word | name = word.en, lang = "en", en = "" }
--
--
-- sumUpWords : String -> List Word -> List Word
-- sumUpWords key words =
--     let
--         counter =
--             List.map .votesCount words
--                 |> List.sum
--
--         firstWord =
--             words
--                 |> List.head
--                 |> Maybe.withDefault initWord
--
--         mainWord =
--             words
--                 |> List.filter (\w -> w.lang == "en")
--                 |> List.head
--                 |> Maybe.withDefault firstWord
--     in
--     { mainWord | votesCount = counter } :: []
