module App.Utils.PageInfo exposing (..)

import App.Models exposing (PageInfo)
import App.Ports exposing (pageInfo)
import App.Routing exposing (Route(..), routeToPath)
import App.Translations exposing (..)
import App.Utils.Config exposing (mainTitle, rootUrl)
import Categories.Models exposing (Category)
import Entries.Models exposing (Entry)
import Http exposing (decodeUri)
import List
import RemoteData exposing (RemoteData(..), WebData)
import String exposing (length)


pageInfoInit : PageInfo
pageInfoInit =
    { title = mainTitle
    , description = translate English DescribeIOWText
    , url = rootUrl
    , imageUrl = rootUrl ++ "/android-chrome-256x256.png"
    }


appTitle : String -> String
appTitle pageTitle =
    if length pageTitle == 0 then
        mainTitle
    else
        pageTitle ++ " - " ++ mainTitle


entryPageInfo : WebData Entry -> Route -> Cmd msg
entryPageInfo entry route =
    case entry of
        Success { title, description, image } ->
            { pageInfoInit
                | title = appTitle title
                , description = description
                , url = rootUrl ++ routeToPath route
                , imageUrl = image.url
            }
                |> pageInfo

        _ ->
            Cmd.none


routePageInfo : Route -> Language -> Cmd msg
routePageInfo route language =
    let
        info =
            case route of
                EntriesNewRoute ->
                    { pageInfoInit
                        | title = appTitle <| translate language CreateEntryText
                        , description = translate language CreateEntryText
                        , url = rootUrl ++ routeToPath route
                    }

                UserEntriesRoute ->
                    { pageInfoInit
                        | title = appTitle <| translate language MyEntriesText
                        , description = translate language MyEntriesDescText
                        , url = rootUrl ++ routeToPath route
                    }

                RandomEntryRoute ->
                    { pageInfoInit
                        | title = appTitle <| translate language RandomEntryText
                        , url = rootUrl ++ routeToPath route
                    }

                PopularRoute ->
                    { pageInfoInit
                        | title = appTitle <| translate language TrendingNowText
                        , description = translate language TrendingNowSubTitle
                        , url = rootUrl ++ routeToPath route
                    }

                SearchRoute query ->
                    let
                        searchTerm =
                            query
                                |> decodeUri
                                |> Maybe.withDefault ""
                    in
                    { pageInfoInit
                        | title = appTitle <| translate language (SearchWithTermText searchTerm)
                        , url = rootUrl ++ routeToPath route
                    }

                NotFoundRoute ->
                    { pageInfoInit
                        | title = appTitle <| translate language PageNotFoundText
                        , description = translate language PageNotFoundDescription
                        , url = rootUrl ++ routeToPath route
                    }

                _ ->
                    pageInfoInit
    in
    pageInfo info


categoryPageInfo : WebData (List Category) -> Route -> Cmd msg
categoryPageInfo webCategories route =
    case ( webCategories, route ) of
        ( Success categories, CategoryRoute slug id ) ->
            let
                category =
                    List.head (List.filterMap checkCategory categories)

                checkCategory category =
                    if category.id == id then
                        Just category
                    else
                        Nothing

                info =
                    case category of
                        Just { title } ->
                            { pageInfoInit
                                | title = appTitle title
                                , url = rootUrl ++ routeToPath route
                            }

                        Nothing ->
                            pageInfoInit
            in
            pageInfo info

        _ ->
            Cmd.none
