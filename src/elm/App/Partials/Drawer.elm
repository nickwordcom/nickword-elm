module App.Partials.Drawer exposing (drawer)

import App.Messages exposing (Msg(MDL, Navigate))
import App.Routing exposing (Route(CategoryRoute, PopularRoute, UserEntriesRoute), routeToPath)
import App.Translations exposing (..)
import App.Utils.Links exposing (linkTo)
import Categories.Models exposing (Category, loremCategory)
import Html exposing (Html, a, div, header, nav, span, text)
import Html.Attributes exposing (class, tabindex)
import Html.Events exposing (onMouseUp)
import List exposing (append, filterMap)
import Material.Layout as Layout
import RemoteData exposing (RemoteData(..), WebData)


drawer : WebData (List Category) -> Language -> List (Html Msg)
drawer categories language =
    [ Layout.title [] [ text <| translate language CategoriesText ]
    , Layout.navigation [] (navLinks categories language)
    ]


navLinks : WebData (List Category) -> Language -> List (Html Msg)
navLinks categories language =
    categoryLinks categories language
        |> (::) (popularLink language)
        |> appendToEnd (userEntriesLink language)


categoryLinks : WebData (List Category) -> Language -> List (Html Msg)
categoryLinks categories language =
    let
        allCategories =
            case categories of
                NotAsked ->
                    [ loremCategory ]

                Loading ->
                    [ { loremCategory | title = translate language LoadingText } ]

                Failure error ->
                    [ { loremCategory | title = translate language <| ErrorText (toString error) } ]

                Success categories ->
                    categories

        activeCategories =
            List.filterMap withEntries allCategories
    in
    List.map categoryLink activeCategories


navLink : String -> String -> Html Msg
navLink linkPath linkText =
    linkTo linkPath
        (Navigate linkPath)
        [ class "mdl-navigation__link"
        , onMouseUp (Layout.toggleDrawer MDL)
        , tabindex 1
        ]
        [ text linkText ]


categoryLink : Category -> Html Msg
categoryLink category =
    category.title
        |> navLink (routeToPath <| CategoryRoute category.slug category.id)


popularLink : Language -> Html Msg
popularLink language =
    translate language TrendingTitle
        |> navLink (routeToPath PopularRoute)


userEntriesLink : Language -> Html Msg
userEntriesLink language =
    translate language MyEntriesText
        |> navLink (routeToPath UserEntriesRoute)


withEntries : Category -> Maybe Category
withEntries category =
    if category.entriesCount > 0 then
        Just category
    else
        Nothing


appendToEnd : link -> List link -> List link
appendToEnd link list =
    List.append list [ link ]
