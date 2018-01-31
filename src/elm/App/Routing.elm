module App.Routing exposing (..)

import App.Translations exposing (Language, decryptLang)
import Categories.Models exposing (CategoryId, CategorySlug)
import Entries.Models exposing (EntryId, EntrySlug)
import Navigation exposing (Location)
import Regex
import UrlParser exposing (..)


-- Available routes in our application


type Route
    = IndexRoute
    | EntryRoute EntrySlug EntryId
    | CategoryRoute CategorySlug CategoryId
    | NewEntryRoute
    | RandomEntryRoute
    | UserEntriesRoute
    | TrendingRoute
    | SearchRoute String
    | OAuthCallbackRoute String
    | NotFoundRoute



-- Define route matchers. These parsers are provided by the url-parser library.


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map IndexRoute top
        , map EntryRoute (s "e" </> string </> string)
        , map CategoryRoute (s "c" </> string </> string)
        , map NewEntryRoute (s "new")
        , map RandomEntryRoute (s "random")
        , map UserEntriesRoute (s "my")
        , map TrendingRoute (s "popular")
        , map SearchRoute (s "search" </> string)
        , map OAuthCallbackRoute (s "oauth" </> string)
        ]



{-
   Each time the browser location changes, the Navigation library will trigger
   a message containing a Navigation.Location record. From our main update
   we will call parseLocation with this record.
-}


parseLocation : Location -> ( Route, Maybe Language )
parseLocation location =
    let
        route =
            parsePath matchers location
                |> Maybe.withDefault NotFoundRoute

        urlLang =
            parseLanguage location
    in
    ( route, urlLang )


parseLanguage : Location -> Maybe Language
parseLanguage { search } =
    case Regex.find (Regex.AtMost 1) (Regex.regex "lang=(uk|ru|es)") search of
        [ { submatches } ] ->
            submatches
                |> List.head
                |> Maybe.withDefault Nothing
                |> Maybe.withDefault ""
                |> decryptLang

        _ ->
            Nothing


routeToPath : Route -> String
routeToPath route =
    case route of
        IndexRoute ->
            "/"

        EntryRoute entrySlug entryId ->
            "/e/" ++ entrySlug ++ "/" ++ entryId

        CategoryRoute categorySlug categoryId ->
            "/c/" ++ categorySlug ++ "/" ++ categoryId

        NewEntryRoute ->
            "/new"

        RandomEntryRoute ->
            "/random"

        UserEntriesRoute ->
            "/my"

        TrendingRoute ->
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
