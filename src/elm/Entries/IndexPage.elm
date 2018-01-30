module Entries.IndexPage exposing (..)

import App.Routing exposing (Route(CategoryRoute), routeToPath)
import App.Translations exposing (..)
import Categories.Models exposing (..)
import Dict
import Dict.Extra as DictEx
import Entries.Messages exposing (Msg)
import Entries.Models exposing (Entry)
import Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)
import Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)
import Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)
import Entries.Partials.TrendingEntriesBlock as TrendingEntriesBlock
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import List exposing (isEmpty, take)
import List.Extra as ListEx
import RemoteData exposing (RemoteData(..), WebData)


view : WebData (List Entry) -> WebData (List Entry) -> WebData (List Category) -> Language -> Html Msg
view trendingEntries featuredEntries categories language =
    div [ class "entries-grid h-full-height" ]
        [ TrendingEntriesBlock.view trendingEntries language
        , featuredEntriesBlock featuredEntries categories language
        ]


featuredEntriesBlock : WebData (List Entry) -> WebData (List Category) -> Language -> Html Msg
featuredEntriesBlock featuredEntries categoriesData language =
    case ( featuredEntries, categoriesData ) of
        ( Success entries, Success categories ) ->
            let
                groupedEntries =
                    DictEx.groupBy (\c -> c.categoryId) entries
                        |> Dict.toList
            in
            div [] (List.map (setCategoryBlock language categories) groupedEntries)

        ( Failure error, _ ) ->
            gridBlockFailure (translate language <| ErrorText (toString error)) ""

        ( _, _ ) ->
            gridBlockLoading (translate language LoadingText) ""


setCategoryBlock : Language -> List Category -> ( CategoryId, List Entry ) -> Html Msg
setCategoryBlock language categories ( categoryId, entries ) =
    let
        category =
            categories
                |> ListEx.find (\c -> c.id == categoryId)
                |> Maybe.withDefault loremCategory

        title =
            category.title

        subTitle =
            translate language <| NumberOfEntriesText category.entriesCount

        showAllUrl =
            routeToPath (CategoryRoute category.slug category.id)
    in
    entriesGridBlock (take 6 entries) title subTitle (Just showAllUrl) True language
