module App.Utils.PageInfo exposing (..)

import App.Models exposing (PageInfo)
import App.Ports exposing (pageInfo)
import App.Routing exposing (Route(..), routeToPath)
import App.Translations exposing (..)
import App.Utils.Cloudinary exposing (cloudinaryEntryPosterUrl)
import App.Utils.Config exposing (appName, rootUrl)
import Categories.Models exposing (Category)
import Entries.Models exposing (Entry)
import Http exposing (decodeUri)
import List
import RemoteData exposing (RemoteData(..), WebData)


pageInfoInit : Language -> PageInfo
pageInfoInit language =
    { title = appName ++ ". " ++ translate language DescribeIOWText
    , description = translate language AppFullDescription
    , url = rootUrl
    , imageUrl = rootUrl ++ "/android-chrome-256x256.png"
    }


pageTitle : String -> String
pageTitle title =
    title ++ " | " ++ appName


entryPageInfo : WebData Entry -> Route -> Language -> Cmd msg
entryPageInfo entry route language =
    case entry of
        Success { title, description, image, votesCount } ->
            { title = entryPageTitle title language
            , description = entryPageDescription title description votesCount language
            , url = rootUrl ++ routeToPath route
            , imageUrl = cloudinaryEntryPosterUrl title image.url language
            }
                |> pageInfo

        _ ->
            Cmd.none


routePageInfo : Route -> Language -> Cmd msg
routePageInfo route language =
    let
        pageInfoLang =
            pageInfoInit language

        info =
            case route of
                NewEntryRoute ->
                    { pageInfoLang
                        | title = pageTitle <| translate language CreateEntryText
                        , url = rootUrl ++ routeToPath route
                    }

                UserEntriesRoute ->
                    { pageInfoLang
                        | title = pageTitle <| translate language MyEntriesText
                        , description = translate language MyEntriesDescText
                        , url = rootUrl ++ routeToPath route
                    }

                RandomEntryRoute ->
                    { pageInfoLang
                        | title = pageTitle <| translate language RandomEntryText
                        , url = rootUrl ++ routeToPath route
                    }

                PopularRoute ->
                    { pageInfoLang
                        | title = pageTitle <| translate language TrendingNowText
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
                    { pageInfoLang
                        | title = pageTitle <| translate language (SearchWithTermText searchTerm)
                        , url = rootUrl ++ routeToPath route
                    }

                NotFoundRoute ->
                    { pageInfoLang
                        | title = pageTitle <| translate language PageNotFoundText
                        , description = translate language PageNotFoundDescription
                        , url = rootUrl ++ routeToPath route
                    }

                _ ->
                    pageInfoLang
    in
    pageInfo info


categoryPageInfo : WebData (List Category) -> Route -> Language -> Cmd msg
categoryPageInfo webCategories route language =
    case ( webCategories, route ) of
        ( Success categories, CategoryRoute slug id ) ->
            let
                pageInfoLang =
                    pageInfoInit language

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
                            { pageInfoLang
                                | title = pageTitle title
                                , url = rootUrl ++ routeToPath route
                            }

                        Nothing ->
                            pageInfoLang
            in
            pageInfo info

        _ ->
            Cmd.none


entryPageTitle : String -> Language -> String
entryPageTitle title language =
    translate language DescribeIOWText
        |> String.toLower
        |> (++) " - "
        |> (++) title
        |> pageTitle


entryPageDescription : String -> String -> Int -> Language -> String
entryPageDescription title description votes language =
    description
        |> (++) (title ++ " - ")
        |> (++) ". "
        |> (++) (translate language SubmitWordCTA)
        |> (++) ". "
        |> (++) (translate language (NumberOfVotesText votes))
