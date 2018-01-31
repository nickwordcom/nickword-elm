module App.Utils.PageInfo exposing (..)

import App.Models exposing (PageInfo)
import App.Ports exposing (pageInfo)
import App.Routing exposing (Route(..), routeToPath)
import App.Translations exposing (..)
import App.Utils.Cloudinary exposing (cloudinaryEntryPosterUrl)
import App.Utils.Config exposing (appName, rootUrl)
import App.Utils.Requests exposing (encodeUrl)
import Categories.Models exposing (Category)
import Entries.Models exposing (Entry)
import Http exposing (decodeUri)
import List
import RemoteData exposing (RemoteData(..), WebData)


pageInfoInit : Language -> PageInfo
pageInfoInit language =
    { title = appName ++ ". " ++ translate language DescribeIOWText
    , description = translate language AppFullDescription
    , url = routeURL IndexRoute language
    , imageUrl = rootUrl ++ "/android-chrome-256x256.png"
    , language = encryptLang language
    }


entryPageInfo : WebData Entry -> Route -> Language -> Cmd msg
entryPageInfo entry route language =
    case entry of
        Success { title, description, image, votesCount } ->
            { title = entryPageTitle title language
            , description = entryPageDescription title description votesCount language
            , url = routeURL route language
            , imageUrl = cloudinaryEntryPosterUrl title image.url language
            , language = encryptLang language
            }
                |> pageInfo

        _ ->
            Cmd.none


routePageInfo : Route -> Language -> Cmd msg
routePageInfo route language =
    let
        pageInfoLang =
            pageInfoInit language

        translateText =
            translate language

        title textID =
            pageTitle (translateText textID)

        url =
            routeURL route language

        info =
            case route of
                NewEntryRoute ->
                    { pageInfoLang
                        | title = title CreateEntryText
                        , url = url
                    }

                UserEntriesRoute ->
                    { pageInfoLang
                        | title = title MyEntriesText
                        , description = translateText MyEntriesDescText
                        , url = url
                    }

                RandomEntryRoute ->
                    { pageInfoLang
                        | title = title RandomEntryText
                        , url = url
                    }

                TrendingRoute ->
                    { pageInfoLang
                        | title = title TrendingNowText
                        , description = translateText TrendingNowSubTitle
                        , url = url
                    }

                SearchRoute query ->
                    let
                        searchTerm =
                            query
                                |> decodeUri
                                |> Maybe.withDefault ""
                    in
                    { pageInfoLang
                        | title = title (SearchWithTermText searchTerm)
                        , url = url
                    }

                NotFoundRoute ->
                    { pageInfoLang
                        | title = title PageNotFoundText
                        , description = translateText PageNotFoundDescription
                        , url = url
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
                                , url = routeURL route language
                            }

                        Nothing ->
                            pageInfoLang
            in
            pageInfo info

        _ ->
            Cmd.none


pageTitle : String -> String
pageTitle title =
    title ++ " | " ++ appName


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


routeURL : Route -> Language -> String
routeURL route language =
    encodeUrl (rootUrl ++ routeToPath route) (urlParams language)


urlParams : Language -> List ( String, String )
urlParams language =
    if language /= English then
        [ ( "lang", encryptLang language ) ]
    else
        []
