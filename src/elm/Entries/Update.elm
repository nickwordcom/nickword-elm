module Entries.Update exposing (..)

import App.Models exposing (Model)
import App.Routing exposing (Route(..), navigateTo, routeToPath)
import App.Translations exposing (Language)
import App.Utils.Title exposing (setEntryDescription, setEntryTitle)
import Categories.Update as CategoriesUpdate
import Dom.Scroll
import Entries.Commands exposing (fetchAllFromCategory)
import Entries.Messages exposing (Msg(..))
import Entries.Models exposing (Entry, FilterType(..), FiltersConfig, LoadMoreState(..))
import Entries.NewEntry.Update as NewEntryUpdate
import Material
import Material.Layout exposing (mainId)
import Navigation
import RemoteData exposing (RemoteData(..), WebData)
import Task
import Votes.Commands exposing (fetchEntryVotes, fetchEntryVotesSlim)
import Votes.Update as VotesUpdate
import Words.Commands exposing (fetchEntryWords)
import Words.Update as WordsUpdate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CategoryEntriesResponse response ->
            { model
                | allEntries = updateEntriesList response model.allEntries
                , loadMoreState = updateLoadMoreState response
            }
                ! []

        UserEntriesResponse response ->
            { model
                | allEntries = updateEntriesList response model.allEntries
                , loadMoreState = updateLoadMoreState response
            }
                ! []

        EntriesPopularResponse response ->
            { model | popularEntries = response } ! []

        EntriesFeaturedResponse response ->
            { model | featuredEntries = response } ! []

        AllPopularEntriesResponse response ->
            { model | allEntries = response } ! []

        SearchEntriesResponse response ->
            { model | allEntries = response } ! []

        EntrySimilarResponse response ->
            { model | similarEntries = response } ! []

        EntryResponse response ->
            { model | entry = response }
                ! [ modifyEntryUrl response model.route
                  , setEntryTitle response
                  , setEntryDescription response
                  ]

        PrefetchEntry entry ->
            { model | entryPrefetched = Just entry } ! []

        LoadMoreEntries ->
            let
                updatedPageNumber =
                    model.pageNumber + 1
            in
            { model
                | pageNumber = updatedPageNumber
                , loadMoreState = EntriesLoading
            }
                ! [ loadMoreEntiresCmd model.route model.appLanguage updatedPageNumber ]

        ApplyFilters filterType ->
            let
                entryFilters =
                    model.entryFilters

                updatedEntryFilters =
                    case filterType of
                        SelectFromCountry countryCode ->
                            { entryFilters | country = countryCode }

                        SelectWithEmotions emotions ->
                            { entryFilters | emotions = emotions }

                        Translate ->
                            { entryFilters | translate = not entryFilters.translate }
            in
            { model
                | entryFilters = updatedEntryFilters
                , entryWords = Loading
                , entryVotesSlim = Loading
            }
                ! [ applyEntryFilters model.route updatedEntryFilters ]

        Navigate url ->
            model ! [ Navigation.newUrl url ]

        SelectEntryTab tabId ->
            { model | entryTabIndex = tabId } ! []

        RandomEntryResponse response ->
            { model | entry = response }
                ! [ randomEntryCmd response ]

        ToggleEntryFilters ->
            let
                entryFilters =
                    model.entryFilters

                updatedEntryFilters =
                    { entryFilters | filtersExpanded = not model.entryFilters.filtersExpanded }
            in
            { model | entryFilters = updatedEntryFilters }
                ! []

        NewEntryMsg subMsg ->
            let
                ( updatedNewEntryModel, cmd ) =
                    NewEntryUpdate.update subMsg model.newEntry model.appLanguage model.user.jwt
            in
            { model | newEntry = updatedNewEntryModel }
                ! [ Cmd.map NewEntryMsg cmd ]

        WordsMsg subMsg ->
            let
                ( newModel, cmd ) =
                    WordsUpdate.update subMsg model
            in
            newModel ! [ Cmd.map WordsMsg cmd ]

        VotesMsg subMsg ->
            let
                ( newModel, cmd ) =
                    VotesUpdate.update subMsg model
            in
            newModel ! [ Cmd.map VotesMsg cmd ]

        CategoriesMsg subMsg ->
            let
                ( newModel, cmd ) =
                    CategoriesUpdate.update subMsg model
            in
            newModel ! [ Cmd.map CategoriesMsg cmd ]

        ScrollToTop ->
            model
                ! [ Dom.Scroll.toTop mainId |> Task.attempt (always NoOp) ]

        MDL msg ->
            Material.update MDL msg model


randomEntryCmd : WebData Entry -> Cmd Msg
randomEntryCmd entry =
    case entry of
        NotAsked ->
            Cmd.none

        Loading ->
            Cmd.none

        Failure err ->
            navigateTo EntriesRoute

        Success entry ->
            navigateTo (EntryRoute entry.slug entry.id)


modifyEntryUrl : WebData Entry -> Route -> Cmd Msg
modifyEntryUrl entry route =
    case entry of
        Success entry ->
            let
                ( oldSlug, entryRoute ) =
                    case route of
                        EntryRoute slug _ ->
                            ( slug, EntryRoute entry.slug entry.id )

                        EntryCloudRoute slug _ ->
                            ( slug, EntryCloudRoute entry.slug entry.id )

                        EntryMapRoute slug _ ->
                            ( slug, EntryMapRoute entry.slug entry.id )

                        EntryVotesRoute slug _ ->
                            ( slug, EntryVotesRoute entry.slug entry.id )

                        EntryStatisticsRoute slug _ ->
                            ( slug, EntryStatisticsRoute entry.slug entry.id )

                        _ ->
                            ( "", NotFoundRoute )
            in
            if entry.slug /= oldSlug then
                routeToPath entryRoute
                    |> Navigation.modifyUrl
            else
                Cmd.none

        _ ->
            Cmd.none


applyEntryFilters : Route -> FiltersConfig -> Cmd Msg
applyEntryFilters route filtersConfig =
    case route of
        EntryRoute slug id ->
            fetchEntryWords id filtersConfig |> Cmd.map WordsMsg

        EntryCloudRoute slug id ->
            fetchEntryWords id filtersConfig |> Cmd.map WordsMsg

        EntryMapRoute slug id ->
            fetchEntryVotesSlim id filtersConfig |> Cmd.map VotesMsg

        EntryVotesRoute slug id ->
            fetchEntryVotes id filtersConfig |> Cmd.map VotesMsg

        _ ->
            Cmd.none


loadMoreEntiresCmd : Route -> Language -> Int -> Cmd Msg
loadMoreEntiresCmd route language pageNumber =
    case route of
        CategoryRoute slug id ->
            fetchAllFromCategory id language pageNumber

        _ ->
            Cmd.none


updateEntriesList : WebData (List Entry) -> WebData (List Entry) -> WebData (List Entry)
updateEntriesList response allEntries =
    case ( response, allEntries ) of
        ( Success entries, Success allEntries ) ->
            Success (List.append allEntries entries)

        ( Success entries, _ ) ->
            Success entries

        ( _, Success allEntries ) ->
            Success allEntries

        _ ->
            response


updateLoadMoreState : WebData (List Entry) -> LoadMoreState
updateLoadMoreState response =
    case response of
        Success entries ->
            if List.length entries <= 24 then
                EntriesFull
            else
                EntriesNotAsked

        _ ->
            EntriesFull
