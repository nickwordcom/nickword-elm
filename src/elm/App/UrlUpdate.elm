module App.UrlUpdate exposing (..)

import App.Messages exposing (Msg(..))
import App.Models exposing (Model, RemoteData(..), WebData)
import App.Ports exposing (appDescription, appTitle, updateGA)
import App.Routing exposing (..)
import App.Translations exposing (..)
import App.Utils.Title exposing (..)
import Categories.Commands as CategoriesCmds
import Categories.Models exposing (Category, CategoryWithEntries)
import Countries.Commands as CountriesCmds
import Countries.Models exposing (Country, EntryVotedCountries)
import Dom.Scroll
import Entries.Commands as EntriesCmds
import Entries.Models exposing (Entry, EntryId, FiltersConfig, filtersConfigInit)
import Entries.NewEntry.Models exposing (newEntryModelInit)
import Http exposing (decodeUri)
import Material.Layout
import Navigation exposing (newUrl)
import OAuth.Parser exposing (..)
import String exposing (isEmpty)
import Task
import Users.Commands as UsersCmds
import Users.Models as UserModels exposing (User)
import Users.Utils exposing (userIsActive, userIsUnknown)
import Votes.Commands as VotesCmds
import Words.Commands as WordsCmds
import Words.Models exposing (EntryVotedWords)


-- The last Cmd in Cmd.batch is executed first.


urlUpdate : Navigation.Location -> Model -> ( Model, Cmd Msg )
urlUpdate location model =
    let
        ( popularEntries, popularEntriesCmd ) =
            checkPopularEntries model.popularEntries model.appLanguage

        ( categoriesWithEntries, categoriesWithEntriesCmd ) =
            checkCategoriesWEntries model.categoriesWithEntries model.appLanguage

        ( categories, categoriesCmd ) =
            checkCategories model.categories model.appLanguage

        ( countries, countriesCmd ) =
            checkCountries model.countries model.appLanguage

        entryVotedCountriesCmd entryId =
            checkEntryVotedCountries model.entryVotedCountries entryId

        scrollToTop =
            Dom.Scroll.toTop Material.Layout.mainId |> Task.attempt (always NoOp)
    in
    case model.route of
        EntriesRoute ->
            { model
                | popularEntries = popularEntries
                , categories = categories
                , categoriesWithEntries = categoriesWithEntries
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , categoriesWithEntriesCmd
                  , popularEntriesCmd
                  , categoriesCmd
                  , scrollToTop
                  , materialCmd
                  , appTitle (newAppTitle "")
                  ]

        EntriesNewRoute ->
            { model
                | categories = categories
                , newEntry = newEntryModelInit
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , categoriesCmd
                  , materialCmd
                  , scrollToTop
                  , appTitle (newAppTitle <| translate model.appLanguage CreateEntryText)
                  ]

        RandomEntryRoute ->
            { model
                | categories = categories
                , entryFilters = filtersConfigInit
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , EntriesCmds.fetchRandom model.appLanguage |> Cmd.map EntriesMsg
                  , scrollToTop
                  , materialCmd
                  ]

        UserEntriesRoute ->
            let
                userEntriesCmd =
                    EntriesCmds.fetchUserEntries model.user model.appLanguage 1
                        |> Cmd.map EntriesMsg

                userCmd =
                    if userIsActive model.user then
                        userEntriesCmd
                    else
                        navigateTo EntriesNewRoute

                updatedAppTitle =
                    newAppTitle <| translate model.appLanguage MyEntriesText

                updatedAppDescription =
                    translate model.appLanguage MyEntriesDescText
            in
            { model
                | categories = categories
                , allEntries = Loading
                , pageNumber = 1
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , userCmd
                  , categoriesCmd
                  , scrollToTop
                  , appTitle updatedAppTitle
                  , appDescription updatedAppDescription
                  , materialCmd
                  ]

        EntryRoute entrySlug entryId ->
            let
                ( entry, entryCmd ) =
                    checkEntry model.entry entryId model.appLanguage

                ( entryVotedWords, entryVotedWordsCmd ) =
                    checkEntryVotedWords model.entryVotedWords entryId model.user

                updatedPrefetchedEntry =
                    checkPrefetchedEntry model.entryPrefetched entryId

                updatedEntryFilters =
                    checkEntryFilters model.entry entryId model.entryFilters

                entryWordsCmd =
                    Cmd.map WordsMsg <| WordsCmds.fetchEntryWords entryId updatedEntryFilters
            in
            { model
                | entry = entry
                , entryPrefetched = updatedPrefetchedEntry
                , popularEntries = popularEntries
                , countries = countries
                , similarEntries = Loading
                , entryWords = Loading
                , entryVotedWords = entryVotedWords
                , categories = categories
                , entryTabIndex = 0
                , entryFilters = updatedEntryFilters
                , wordSearchValue = ""
                , newWordValue = ""
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False

                -- , entryEmotionsInfo = Nothing
            }
                ! [ updateGA (routeToPath model.route)
                  , popularEntriesCmd
                  , entryVotedCountriesCmd entryId
                  , entryVotedWordsCmd
                  , entryWordsCmd
                  , countriesCmd
                  , categoriesCmd
                  , setEntryTitle entry
                  , setEntryDescription entry
                  , entryCmd
                  , materialCmd
                  ]

        EntryCloudRoute entrySlug entryId ->
            let
                ( entry, entryCmd ) =
                    checkEntry model.entry entryId model.appLanguage

                entryWordsCmd =
                    Cmd.map WordsMsg <| WordsCmds.fetchEntryWords entryId model.entryFilters
            in
            { model
                | entry = entry
                , categories = categories
                , countries = countries
                , entryTabIndex = 1
                , newWordValue = ""
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
                , entryWords = Loading
                , popularEntries = popularEntries
            }
                ! [ updateGA (routeToPath model.route)
                  , popularEntriesCmd
                  , entryVotedCountriesCmd entryId
                  , entryWordsCmd
                  , countriesCmd
                  , categoriesCmd
                  , setEntryTitle entry
                  , entryCmd
                  , materialCmd
                  ]

        EntryMapRoute entrySlug entryId ->
            let
                ( entry, entryCmd ) =
                    checkEntry model.entry entryId model.appLanguage

                entryVotesSlimCmd =
                    Cmd.map VotesMsg <| VotesCmds.fetchEntryVotesSlim entryId model.entryFilters
            in
            { model
                | entry = entry
                , categories = categories
                , countries = countries
                , entryTabIndex = 2
                , newWordValue = ""
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
                , entryVotesSlim = Loading
                , popularEntries = popularEntries
            }
                ! [ updateGA (routeToPath model.route)
                  , popularEntriesCmd
                  , entryVotedCountriesCmd entryId
                  , entryVotesSlimCmd
                  , countriesCmd
                  , categoriesCmd
                  , setEntryTitle entry
                  , entryCmd
                  , materialCmd
                  ]

        EntryVotesRoute entrySlug entryId ->
            let
                ( entry, entryCmd ) =
                    checkEntry model.entry entryId model.appLanguage

                entryVotesCmd =
                    Cmd.map VotesMsg <| VotesCmds.fetchEntryVotes entryId model.entryFilters
            in
            { model
                | entry = entry
                , entryVotes = Loading
                , categories = categories
                , countries = countries
                , popularEntries = popularEntries
                , similarEntries = Loading
                , entryTabIndex = 3
                , newWordValue = ""
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , popularEntriesCmd
                  , entryVotedCountriesCmd entryId
                  , entryVotesCmd
                  , countriesCmd
                  , categoriesCmd
                  , setEntryTitle entry
                  , entryCmd
                  , materialCmd
                  ]

        EntryStatisticsRoute entrySlug entryId ->
            let
                ( entry, entryCmd ) =
                    checkEntry model.entry entryId model.appLanguage
            in
            { model
                | entry = entry
                , categories = categories
                , countries = countries
                , entryTabIndex = 4
                , newWordValue = ""
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , entryVotedCountriesCmd entryId
                  , countriesCmd
                  , categoriesCmd
                  , setEntryTitle entry
                  , entryCmd
                  , materialCmd
                  ]

        CategoryRoute categorySlug categoryId ->
            let
                categoryEntriesCmd =
                    EntriesCmds.fetchAllFromCategory categoryId model.appLanguage 1
                        |> Cmd.map EntriesMsg
            in
            { model
                | categories = categories
                , allEntries = Loading
                , pageNumber = 1
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , categoryEntriesCmd
                  , setCategoryTitle categories categoryId
                  , categoriesCmd
                  , scrollToTop
                  , materialCmd
                  ]

        PopularRoute ->
            let
                popularEntriesCmd =
                    Cmd.map EntriesMsg <| EntriesCmds.fetchAllPopular model.appLanguage

                updatedAppTitle =
                    newAppTitle <| translate model.appLanguage TrendingTitle
            in
            { model
                | allEntries = Loading
                , categories = categories
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , popularEntriesCmd
                  , categoriesCmd
                  , scrollToTop
                  , appTitle updatedAppTitle
                  , materialCmd
                  ]

        SearchRoute term ->
            let
                searchTerm =
                    term
                        |> decodeUri
                        |> Maybe.withDefault ""

                searchEntriesCmd =
                    Cmd.map EntriesMsg <| EntriesCmds.searchEntries searchTerm model.appLanguage

                updatedAppTitle =
                    newAppTitle <| translate model.appLanguage (SearchWithTermText searchTerm)
            in
            { model
                | allEntries = Loading
                , categories = categories
                , loginFormTopBlockOpen = False
                , searchValue = searchTerm
            }
                ! [ updateGA (routeToPath model.route)
                  , searchEntriesCmd
                  , categoriesCmd
                  , scrollToTop
                  , appTitle updatedAppTitle
                  , materialCmd
                  ]

        OAuthCallbackRoute provider ->
            let
                ( user, userCmd ) =
                    authorizeUser location provider model.user
            in
            { model | user = user } ! [ userCmd, scrollToTop, materialCmd ]

        NotFoundRoute ->
            model ! [ scrollToTop, materialCmd ]


materialCmd : Cmd Msg
materialCmd =
    Material.Layout.sub0 MDL


checkPopularEntries : WebData (List Entry) -> Language -> ( WebData (List Entry), Cmd Msg )
checkPopularEntries entries language =
    case entries of
        Loading ->
            ( Loading, Cmd.map EntriesMsg <| EntriesCmds.fetchPopular language )

        Failure error ->
            ( Failure error, Cmd.map EntriesMsg <| EntriesCmds.fetchPopular language )

        Success entries ->
            ( Success entries, Cmd.none )


checkCategories : WebData (List Category) -> Language -> ( WebData (List Category), Cmd Msg )
checkCategories categories language =
    case categories of
        Loading ->
            ( Loading, Cmd.map CategoriesMsg <| CategoriesCmds.fetchAll language )

        Failure error ->
            ( Failure error, Cmd.map CategoriesMsg <| CategoriesCmds.fetchAll language )

        Success categories ->
            ( Success categories, Cmd.none )


checkCountries : WebData (List Country) -> Language -> ( WebData (List Country), Cmd Msg )
checkCountries countries language =
    case countries of
        Loading ->
            ( Loading, Cmd.map CountriesMsg <| CountriesCmds.fetchAll language )

        Failure error ->
            ( Failure error, Cmd.map CountriesMsg <| CountriesCmds.fetchAll language )

        Success countries ->
            ( Success countries, Cmd.none )


checkCategoriesWEntries : WebData (List CategoryWithEntries) -> Language -> ( WebData (List CategoryWithEntries), Cmd Msg )
checkCategoriesWEntries categoriesWithEntries language =
    case categoriesWithEntries of
        Loading ->
            ( Loading, Cmd.map CategoriesMsg <| CategoriesCmds.fetchAllWE language )

        Failure error ->
            ( Failure error, Cmd.map CategoriesMsg <| CategoriesCmds.fetchAllWE language )

        Success categoriesWithEntries ->
            ( Success categoriesWithEntries, Cmd.none )


checkEntry : WebData Entry -> EntryId -> Language -> ( WebData Entry, Cmd Msg )
checkEntry entry currentEntryId language =
    let
        fetchCmd =
            Cmd.map EntriesMsg <| EntriesCmds.fetchEntry currentEntryId language
    in
    case entry of
        Loading ->
            ( Loading, fetchCmd )

        Failure error ->
            ( Failure error, fetchCmd )

        Success entry ->
            if entry.id == currentEntryId then
                ( Success entry, Cmd.none )
            else
                ( Loading, fetchCmd )


checkPrefetchedEntry : Maybe Entry -> EntryId -> Maybe Entry
checkPrefetchedEntry entryPrefetched entryId =
    case entryPrefetched of
        Just entry ->
            if entry.id == entryId then
                entryPrefetched
            else
                Nothing

        Nothing ->
            entryPrefetched


checkEntryVotedWords : WebData EntryVotedWords -> EntryId -> User -> ( WebData EntryVotedWords, Cmd Msg )
checkEntryVotedWords entryVotedWords entryId user =
    let
        fetchCmd =
            if userIsActive user then
                Cmd.map WordsMsg <| WordsCmds.fetchEntryVotedWords entryId user.jwt
            else
                Cmd.none
    in
    case entryVotedWords of
        Loading ->
            ( entryVotedWords, fetchCmd )

        Failure error ->
            ( entryVotedWords, fetchCmd )

        Success votedIds ->
            if votedIds.entryId == entryId then
                ( entryVotedWords, Cmd.none )
            else
                ( Loading, fetchCmd )


checkEntryVotedCountries : EntryVotedCountries -> EntryId -> Cmd Msg
checkEntryVotedCountries entryVotedCountries entryId =
    if entryVotedCountries.entryId == entryId then
        Cmd.none
    else
        Cmd.map VotesMsg <| VotesCmds.fetchEntryVotedCountries entryId


checkEntryFilters : WebData Entry -> EntryId -> FiltersConfig -> FiltersConfig
checkEntryFilters entry currentEntryId entryFilters =
    case entry of
        Success { id } ->
            if id == currentEntryId then
                entryFilters
            else
                filtersConfigInit

        _ ->
            filtersConfigInit


authorizeUser : Navigation.Location -> String -> User -> ( User, Cmd Msg )
authorizeUser location provider user =
    let
        hash =
            location.hash

        oauthResponse =
            { state = getFieldFromHash hash "state"
            , provider = provider
            , token = getFieldFromHash hash "access_token"
            }

        oauthResponsePresent =
            isEmpty provider
                || isEmpty oauthResponse.token
                || isEmpty oauthResponse.state
                |> not

        newUrlCmd =
            if oauthResponsePresent then
                decodeUri oauthResponse.state
                    |> Maybe.withDefault ""
                    |> newUrl
            else
                newUrl "/"
    in
    if userIsUnknown user && oauthResponsePresent then
        { user | status = UserModels.Loading }
            ! [ newUrlCmd, UsersCmds.authorizeUser oauthResponse ]
    else
        ( user, newUrlCmd )
