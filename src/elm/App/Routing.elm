module App.Routing exposing (..)

import Categories.Models exposing (CategoryId, CategorySlug)
import Entries.Models exposing (EntryId, EntrySlug)
import Navigation exposing (Location)
import UrlParser exposing (..)


-- Available routes in our application


type Route
    = EntriesRoute
    | EntriesNewRoute
    | RandomEntryRoute
    | EntryRoute EntrySlug EntryId
    | EntryCloudRoute EntrySlug EntryId
    | EntryMapRoute EntrySlug EntryId
    | EntryVotesRoute EntrySlug EntryId
    | EntryStatisticsRoute EntrySlug EntryId
    | CategoryRoute CategorySlug CategoryId
    | PopularRoute
    | SearchRoute String
    | OAuthCallbackRoute String
    | NotFoundRoute



-- Define route matchers. These parsers are provided by the url-parser library.


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map EntriesRoute top
        , map EntriesNewRoute (s "e" </> s "new")
        , map RandomEntryRoute (s "e" </> s "random")
        , map EntryCloudRoute (s "e" </> string </> string </> s "cloud")
        , map EntryMapRoute (s "e" </> string </> string </> s "map")
        , map EntryVotesRoute (s "e" </> string </> string </> s "votes")
        , map EntryStatisticsRoute (s "e" </> string </> string </> s "statistics")
        , map EntryRoute (s "e" </> string </> string)
        , map EntriesRoute (s "e")
        , map CategoryRoute (s "c" </> string </> string)
        , map PopularRoute (s "popular")
        , map SearchRoute (s "search" </> string)
        , map OAuthCallbackRoute (s "oauth" </> string)
        ]



{-
   Each time the browser location changes, the Navigation library will trigger
   a message containing a Navigation.Location record. From our main update
   we will call parseLocation with this record.
-}


parseLocation : Location -> Route
parseLocation location =
    parsePath matchers location
        |> Maybe.withDefault NotFoundRoute


routeToPath : Route -> String
routeToPath route =
    case route of
        EntriesRoute ->
            "/"

        EntriesNewRoute ->
            "/e/new"

        RandomEntryRoute ->
            "/e/random"

        EntryRoute entrySlug entryId ->
            "/e/" ++ entrySlug ++ "/" ++ entryId

        EntryCloudRoute entrySlug entryId ->
            "/e/" ++ entrySlug ++ "/" ++ entryId ++ "/cloud"

        EntryMapRoute entrySlug entryId ->
            "/e/" ++ entrySlug ++ "/" ++ entryId ++ "/map"

        EntryVotesRoute entrySlug entryId ->
            "/e/" ++ entrySlug ++ "/" ++ entryId ++ "/votes"

        EntryStatisticsRoute entrySlug entryId ->
            "/e/" ++ entrySlug ++ "/" ++ entryId ++ "/statistics"

        CategoryRoute categorySlug categoryId ->
            "/c/" ++ categorySlug ++ "/" ++ categoryId

        PopularRoute ->
            "/popular/"

        SearchRoute searchTerm ->
            "/search/" ++ searchTerm

        OAuthCallbackRoute provider ->
            "/oauth/" ++ provider

        NotFoundRoute ->
            "/"


navigateTo : Route -> Cmd msg
navigateTo route =
    Navigation.newUrl (routeToPath route)
