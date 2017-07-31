module App.Partials.Drawer exposing (drawer)

import App.Messages exposing (Msg(MDL, Navigate))
import App.Models exposing (RemoteData(..), WebData)
import App.Routing exposing (Route(CategoryRoute, PopularRoute), routeToPath)
import App.Translations exposing (..)
import App.Utils.Links exposing (linkTo)
import Categories.Models exposing (Category, loremCategory)
import Html exposing (Html, a, div, header, nav, span, text)
import Html.Attributes exposing (class, tabindex)
import Html.Events exposing (onMouseUp)
import List exposing (append, filterMap)
import Material.Layout as Layout


drawer : WebData (List Category) -> Language -> List (Html Msg)
drawer categories language =
    [ Layout.title [] [ text <| translate language CategoriesText ]
    , Layout.navigation [] (categoryLinks categories language)
    ]


categoryLinks : WebData (List Category) -> Language -> List (Html Msg)
categoryLinks categories language =
    let
        allCategories =
            case categories of
                Loading ->
                    [ { loremCategory | title = translate language LoadingText } ]

                Failure error ->
                    [ { loremCategory | title = translate language <| ErrorText (toString error) } ]

                Success categories ->
                    categories

        activeCategories =
            List.filterMap withEntries allCategories

        popularPath =
            routeToPath PopularRoute

        popularLink =
            linkTo popularPath
                (Navigate popularPath)
                [ class "mdl-navigation__link"
                , onMouseUp (Layout.toggleDrawer MDL)
                , tabindex 1
                ]
                [ text <| translate language TrendingTitle ]
    in
    List.append [ popularLink ] <| List.map categoryLink activeCategories


categoryLink : Category -> Html Msg
categoryLink category =
    let
        categoryPath =
            routeToPath <| CategoryRoute category.slug category.id
    in
    linkTo categoryPath
        (Navigate categoryPath)
        [ class "mdl-navigation__link"
        , onMouseUp (Layout.toggleDrawer MDL)
        , tabindex 1
        ]
        [ text category.title ]


withEntries : Category -> Maybe Category
withEntries category =
    if category.entriesCount > 0 then
        Just category
    else
        Nothing
