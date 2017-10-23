module Entries.Partials.EntryCategoryInfo exposing (view)

import App.Models exposing (RemoteData(..), WebData)
import App.Routing exposing (Route(CategoryRoute), routeToPath)
import App.Utils.Links exposing (linkTo)
import Categories.Models exposing (Category, CategoryId)
import Entries.Messages exposing (Msg(Navigate))
import Html exposing (..)
import Html.Attributes exposing (..)


view : WebData (List Category) -> CategoryId -> Html Msg
view categories entryCategory =
    case categories of
        Loading ->
            blankLink

        Failure err ->
            blankLink

        Success categories ->
            List.filterMap (filterCategories entryCategory) categories
                |> List.head
                |> categoryItem


filterCategories : CategoryId -> Category -> Maybe Category
filterCategories entryCategoryId category =
    if category.id == entryCategoryId then
        Just category
    else
        Nothing


categoryItem : Maybe Category -> Html Msg
categoryItem maybeCategory =
    case maybeCategory of
        Just category ->
            let
                categoryPath =
                    routeToPath <| CategoryRoute category.slug category.id
            in
            linkTo categoryPath
                (Navigate categoryPath)
                [ class "entry-page__category-link" ]
                [ text category.title ]

        Nothing ->
            blankLink


blankLink : Html Msg
blankLink =
    span [ class "entry-page__category-link" ] [ text "" ]