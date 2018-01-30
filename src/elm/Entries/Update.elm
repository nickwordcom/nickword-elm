module Entries.Update exposing (..)

import App.Models exposing (Model)
import App.Routing exposing (Route(..), navigateTo, routeToPath)
import App.Translations exposing (Language)
import App.Utils.Converters exposing (entryTabFromIndex)
import App.Utils.PageInfo exposing (entryPageInfo)
import Categories.Update as CategoriesUpdate
import Dom.Scroll
import Entries.Commands exposing (fetchAllFromCategory, fetchUserEntries)
import Entries.Messages exposing (Msg(..))
import Entries.Models exposing (Entry, EntryTab(..), FilterType(..), FiltersConfig, LoadMoreState(..))
import Entries.NewEntry.Update as NewEntryUpdate
import Material
import Material.Layout exposing (mainId)
import Navigation
import RemoteData exposing (RemoteData(..), WebData)
import Task
import Users.Models exposing (User)
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

        EntryResponse response ->
            { model | entry = response }
                ! [ modifyEntryUrl response model.route
                  , entryPageInfo response model.route model.appLanguage
                  ]

        RandomEntryResponse response ->
            { model | entry = response }
                ! [ entryPageInfo response (entryRouteFromResponse response) model.appLanguage
                  , randomEntryCmd response
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
                ! [ loadMoreEntiresCmd model.route model.user model.appLanguage updatedPageNumber ]

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
                ! [ applyEntryFilters model.entryTab model.route updatedEntryFilters ]

        SelectEntryTab index ->
            let
                entryTab =
                    entryTabFromIndex index
            in
            { model | entryTab = entryTab }
                ! [ applyEntryFilters entryTab model.route model.entryFilters ]

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

        Navigate url ->
            model ! [ Navigation.newUrl url ]

        ScrollToTop ->
            model
                ! [ Dom.Scroll.toTop mainId |> Task.attempt (always NoOp) ]

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

        Success { id, slug } ->
            navigateTo (EntryRoute slug id)


modifyEntryUrl : WebData Entry -> Route -> Cmd Msg
modifyEntryUrl entry route =
    case entry of
        Success { id, slug } ->
            let
                newRoute =
                    EntryRoute slug id
            in
            if route /= newRoute then
                Navigation.modifyUrl (routeToPath newRoute)
            else
                Cmd.none

        _ ->
            Cmd.none


applyEntryFilters : EntryTab -> Route -> FiltersConfig -> Cmd Msg
applyEntryFilters entryTab route filtersConfig =
    case route of
        EntryRoute _ entryId ->
            case entryTab of
                WordList ->
                    fetchEntryWords entryId filtersConfig |> Cmd.map WordsMsg

                WordCloud ->
                    fetchEntryWords entryId filtersConfig |> Cmd.map WordsMsg

                VotesMap ->
                    fetchEntryVotesSlim entryId filtersConfig |> Cmd.map VotesMsg

                VotesList ->
                    fetchEntryVotes entryId filtersConfig |> Cmd.map VotesMsg

        _ ->
            Cmd.none


loadMoreEntiresCmd : Route -> User -> Language -> Int -> Cmd Msg
loadMoreEntiresCmd route user language pageNumber =
    case route of
        CategoryRoute _ id ->
            fetchAllFromCategory id language pageNumber

        UserEntriesRoute ->
            fetchUserEntries user language pageNumber

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


entryRouteFromResponse : WebData Entry -> Route
entryRouteFromResponse entry =
    case entry of
        Success { slug, id } ->
            EntryRoute slug id

        _ ->
            EntriesRoute
