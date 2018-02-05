module App.UrlUpdate exposing (..)

import App.Messages exposing (Msg(..))
import App.Models exposing (Model)
import App.Ports exposing (updateGA)
import App.Routing exposing (..)
import App.Translations exposing (..)
import App.Utils.PageInfo exposing (..)
import Categories.Commands as CategoriesCmds
import Categories.Models exposing (Category)
import Countries.Commands as CountriesCmds
import Countries.Models exposing (Country, EntryVotedCountries)
import Dom.Scroll
import Entries.Commands as EntriesCmds
import Entries.Models exposing (Entry, EntryId, EntryTab(WordList), FiltersConfig, filtersConfigInit)
import Entries.NewEntry.Models exposing (newEntryModelInit)
import Http exposing (decodeUri)
import Material.Layout
import Navigation exposing (newUrl)
import OAuth.Parser exposing (..)
import RemoteData exposing (RemoteData(..), WebData)
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

        ( featuredEntries, featuredEntriesCmd ) =
            checkFeaturedEntries model.featuredEntries model.appLanguage

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
        IndexRoute ->
            { model
                | popularEntries = popularEntries
                , categories = categories
                , featuredEntries = featuredEntries
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , featuredEntriesCmd
                  , popularEntriesCmd
                  , categoriesCmd
                  , routePageInfo model.route model.appLanguage
                  , scrollToTop
                  , materialCmd
                  ]

        NewEntryRoute ->
            { model
                | categories = categories
                , newEntry = newEntryModelInit
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , categoriesCmd
                  , routePageInfo model.route model.appLanguage
                  , materialCmd
                  , scrollToTop
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
                  , routePageInfo model.route model.appLanguage
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
                        navigateTo NewEntryRoute
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
                  , routePageInfo model.route model.appLanguage
                  , scrollToTop
                  , materialCmd
                  ]

        EntryRoute entrySlug entryId ->
            let
                ( entry, entryCmd ) =
                    checkEntry model.entry entryId model.route model.appLanguage

                ( entryVotedWords, entryVotedWordsCmd ) =
                    checkEntryVotedWords model.entryVotedWords entryId model.user

                updatedEntryFilters =
                    checkEntryFilters model.entry entryId model.entryFilters

                entryWordsCmd =
                    Cmd.map WordsMsg <| WordsCmds.fetchEntryWords entryId updatedEntryFilters
            in
            { model
                | entry = entry
                , popularEntries = popularEntries
                , countries = countries
                , entryWords = Loading
                , entryVotes = Loading
                , entryVotedWords = entryVotedWords
                , entryEmotionsInfo = Nothing
                , categories = categories
                , entryTab = WordList
                , entryFilters = updatedEntryFilters
                , wordSearchValue = ""
                , newWordValue = ""
                , loginFormTopBlockOpen = False
                , searchValue = ""
                , searchDialogOpen = False
            }
                ! [ updateGA (routeToPath model.route)
                  , popularEntriesCmd
                  , entryVotedCountriesCmd entryId
                  , entryVotedWordsCmd
                  , entryWordsCmd
                  , countriesCmd
                  , categoriesCmd
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
                  , categoryPageInfo categories model.route model.appLanguage
                  , categoriesCmd
                  , scrollToTop
                  , materialCmd
                  ]

        TrendingRoute ->
            let
                popularEntriesCmd =
                    Cmd.map EntriesMsg <| EntriesCmds.fetchAllPopular model.appLanguage
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
                  , routePageInfo model.route model.appLanguage
                  , scrollToTop
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
                  , routePageInfo model.route model.appLanguage
                  , scrollToTop
                  , materialCmd
                  ]

        OAuthCallbackRoute provider ->
            let
                ( user, userCmd ) =
                    authorizeUser location provider model.user
            in
            { model | user = user } ! [ userCmd, scrollToTop, materialCmd ]

        NotFoundRoute ->
            model
                ! [ scrollToTop
                  , routePageInfo model.route model.appLanguage
                  , materialCmd
                  ]


materialCmd : Cmd Msg
materialCmd =
    Material.Layout.sub0 MDL


checkPopularEntries : WebData (List Entry) -> Language -> ( WebData (List Entry), Cmd Msg )
checkPopularEntries entries language =
    case entries of
        Success entries ->
            ( Success entries, Cmd.none )

        _ ->
            ( entries, Cmd.map EntriesMsg <| EntriesCmds.fetchPopular language )


checkFeaturedEntries : WebData (List Entry) -> Language -> ( WebData (List Entry), Cmd Msg )
checkFeaturedEntries entries language =
    case entries of
        Success entries ->
            ( Success entries, Cmd.none )

        _ ->
            ( entries, Cmd.map EntriesMsg <| EntriesCmds.fetchFeatured language )


checkCategories : WebData (List Category) -> Language -> ( WebData (List Category), Cmd Msg )
checkCategories categories language =
    case categories of
        Success categories ->
            ( Success categories, Cmd.none )

        _ ->
            ( categories, Cmd.map CategoriesMsg <| CategoriesCmds.fetchAll language )


checkCountries : WebData (List Country) -> Language -> ( WebData (List Country), Cmd Msg )
checkCountries countries language =
    case countries of
        Success countries ->
            ( Success countries, Cmd.none )

        _ ->
            ( countries, Cmd.map CountriesMsg <| CountriesCmds.fetchAll language )


checkEntry : WebData Entry -> EntryId -> Route -> Language -> ( WebData Entry, Cmd Msg )
checkEntry oldEntry currentEntryId route language =
    let
        fetchCmd =
            Cmd.map EntriesMsg <| EntriesCmds.fetchEntry currentEntryId language
    in
    case oldEntry of
        Success entry ->
            if entry.id == currentEntryId then
                ( oldEntry, entryPageInfo oldEntry route language )
            else
                ( Loading, fetchCmd )

        _ ->
            ( oldEntry, fetchCmd )


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
        Success votedIds ->
            if votedIds.entryId == entryId then
                ( entryVotedWords, Cmd.none )
            else
                ( Loading, fetchCmd )

        _ ->
            ( entryVotedWords, fetchCmd )


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
