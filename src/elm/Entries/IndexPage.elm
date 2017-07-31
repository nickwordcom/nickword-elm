module Entries.IndexPage exposing (..)

import App.Models exposing (RemoteData(..), WebData)
import App.Routing exposing (Route(CategoryRoute, PopularRoute), routeToPath)
import App.Translations exposing (..)
import Categories.Models exposing (CategoryWithEntries)
import Entries.Messages exposing (Msg)
import Entries.Models exposing (Entry)
import Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)
import Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)
import Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)
import Entries.Partials.TrendingEntriesBlock as TrendingEntriesBlock
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import List exposing (isEmpty, take)


view : WebData (List Entry) -> WebData (List CategoryWithEntries) -> Language -> Html Msg
view trendingEntries categoriesWithEntries language =
    div [ class "entries-grid h-full-height" ]
        [ TrendingEntriesBlock.view trendingEntries language
        , categoriesWithEntriesBlock categoriesWithEntries language
        ]


categoriesWithEntriesBlock : WebData (List CategoryWithEntries) -> Language -> Html Msg
categoriesWithEntriesBlock categoriesWithEntries language =
    case categoriesWithEntries of
        Loading ->
            gridBlockLoading (translate language LoadingText) ""

        Failure error ->
            gridBlockFailure (translate language <| ErrorText (toString error)) ""

        Success categories ->
            div [] (List.map (setCategoryBlock language) categories)


setCategoryBlock : Language -> CategoryWithEntries -> Html Msg
setCategoryBlock language category =
    let
        title =
            category.title

        subTitle =
            translate language <| NumberOfEntriesText category.entriesCount

        showAllUrl =
            routeToPath (CategoryRoute category.slug category.id)
    in
    -- category.entries - check if there are some featured entries in category
    if isEmpty category.entries then
        div [] []
    else
        entriesGridBlock (take 6 category.entries) title subTitle (Just showAllUrl) True language
