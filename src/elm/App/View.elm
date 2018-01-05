module App.View exposing (..)

import App.Messages exposing (Msg(..))
import App.Models exposing (Model)
import App.Partials.Drawer exposing (drawer)
import App.Partials.Footer as Footer
import App.Partials.Header exposing (appHeader)
import App.Partials.LoginLinks as LoginLinks
import App.Routing as Routing exposing (Route(..))
import App.Translations exposing (..)
import Categories.Models exposing (CategoryId, loremCategory)
import Categories.ShowPage as CategoriesShow
import Entries.IndexPage as EntriesIndex
import Entries.NewPage as EntriesNew
import Entries.ShowPage as EntriesShow
import Html exposing (..)
import Http exposing (decodeUri)
import Material.Layout as Layout
import Material.Snackbar as Snackbar
import Pages.NotFoundPage as NotFoundPage
import Pages.PopularPage as PopularPage
import Pages.SearchPage as SearchPage
import Pages.UserEntriesPage as UserEntriesPage
import RemoteData exposing (RemoteData(..))
import ShareDialog.Dialog as Dialog


view : Model -> Html Msg
view model =
    let
        dialog =
            Dialog.view model.shareDialog model.appLanguage
                |> Html.map ShareDialogMsg
    in
    Layout.render MDL
        model.mdl
        [ Layout.fixedHeader ]
        { header = appHeader model
        , drawer = drawer model.categories model.appLanguage
        , tabs = ( [], [] )
        , main = page model
        }
        |> (\view -> div [] [ view, dialog ])


page : Model -> List (Html Msg)
page model =
    let
        page =
            case model.route of
                EntriesRoute ->
                    EntriesIndex.view model.popularEntries model.featuredEntries model.categories model.appLanguage
                        |> Html.map EntriesMsg

                EntriesNewRoute ->
                    EntriesNew.view model.newEntry model.categories model.user model.appLanguage model.route
                        |> Html.map EntriesMsg

                RandomEntryRoute ->
                    EntriesShow.entryLoadingSpinner

                EntryRoute slug id ->
                    EntriesShow.view model
                        |> Html.map EntriesMsg

                EntryCloudRoute slug id ->
                    EntriesShow.view model
                        |> Html.map EntriesMsg

                EntryMapRoute slug id ->
                    EntriesShow.view model
                        |> Html.map EntriesMsg

                EntryVotesRoute slug id ->
                    EntriesShow.view model
                        |> Html.map EntriesMsg

                CategoryRoute slug id ->
                    categoryShowPage model id

                UserEntriesRoute ->
                    UserEntriesPage.view model.allEntries model.appLanguage
                        |> Html.map EntriesMsg

                PopularRoute ->
                    PopularPage.view model.allEntries model.appLanguage
                        |> Html.map EntriesMsg

                SearchRoute searchTerm ->
                    searchTerm
                        |> decodeUri
                        |> Maybe.withDefault ""
                        |> SearchPage.view model.allEntries model.appLanguage
                        |> Html.map EntriesMsg

                OAuthCallbackRoute provider ->
                    div [] []

                NotFoundRoute ->
                    NotFoundPage.view model.appLanguage
    in
    [ LoginLinks.topBlock model.user model.appLanguage model.route model.loginFormTopBlockOpen
    , page
    , Footer.view model.user model.appLanguage
    , Snackbar.view model.snackbar |> Html.map Snackbar
    ]


categoryShowPage : Model -> CategoryId -> Html Msg
categoryShowPage { categories, allEntries, appLanguage, loadMoreState } categoryId =
    let
        maybeCategory =
            case categories of
                Success categories ->
                    categories
                        |> List.filter (\category -> category.id == categoryId)
                        |> List.head

                _ ->
                    Just { loremCategory | title = translate appLanguage LoadingText }

        category =
            case maybeCategory of
                Just category ->
                    category

                Nothing ->
                    { loremCategory | title = translate appLanguage NotFound }
    in
    CategoriesShow.view allEntries category appLanguage loadMoreState
        |> Html.map EntriesMsg
