module App.Update exposing (..)

import App.Messages exposing (Msg(..))
import App.Models exposing (Model, RemoteData(..))
import App.Ports exposing (removeLocalJWT, setLocalJWT, setLocalLanguage)
import App.Routing exposing (Route(EntryRoute, SearchRoute), navigateTo, parseLocation, routeToPath)
import App.UrlUpdate exposing (urlUpdate)
import Categories.Update as CategoriesUpdate
import Countries.Update as CountriesUpdate
import Dom
import Dom.Scroll
import Entries.Update as EntriesUpdate
import Material
import Material.Helpers exposing (map1st, map2nd)
import Material.Layout exposing (mainId)
import Material.Snackbar as Snackbar
import Navigation
import ShareDialog.Update as ShareDialogUpdate
import String exposing (length)
import Task
import Users.Models exposing (UserToken, userInitialModel)
import Users.Utils exposing (activateUser)
import Votes.Update as VotesUpdate
import Words.Commands as WordsCmds
import Words.Update as WordsUpdate


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnLocationChange location ->
            let
                currentRoute =
                    parseLocation location
            in
            urlUpdate location { model | route = currentRoute }

        EntriesMsg subMsg ->
            let
                ( newModel, cmd ) =
                    EntriesUpdate.update subMsg model
            in
            ( newModel, Cmd.map EntriesMsg cmd )

        WordsMsg subMsg ->
            let
                ( newModel, cmd ) =
                    WordsUpdate.update subMsg model
            in
            ( newModel, Cmd.map WordsMsg cmd )

        VotesMsg subMsg ->
            let
                ( newModel, cmd ) =
                    VotesUpdate.update subMsg model
            in
            ( newModel, Cmd.map VotesMsg cmd )

        CategoriesMsg subMsg ->
            let
                ( newModel, cmd ) =
                    CategoriesUpdate.update subMsg model
            in
            ( newModel, Cmd.map CategoriesMsg cmd )

        CountriesMsg subMsg ->
            let
                ( newModel, cmd ) =
                    CountriesUpdate.update subMsg model
            in
            ( newModel, Cmd.map CountriesMsg cmd )

        ShareDialogMsg subMsg ->
            let
                ( shareDialog, cmd ) =
                    ShareDialogUpdate.update subMsg model.shareDialog
            in
            { model | shareDialog = shareDialog }
                ! [ Cmd.map ShareDialogMsg cmd ]

        UserAuthorization (Ok jwt) ->
            { model | user = activateUser jwt }
                ! [ setLocalJWT jwt
                  , fetchUserVotedWords model.route jwt
                  ]

        UserAuthorization (Err _) ->
            { model | user = userInitialModel } ! []

        RemoveLocalJWT ->
            { model | user = userInitialModel, entryVotedWords = Loading }
                ! [ removeLocalJWT () ]

        Navigate url ->
            model ! [ Navigation.newUrl url ]

        ToggleTopLoginForm ->
            let
                cmd =
                    if model.loginFormTopBlockOpen then
                        Cmd.none
                    else
                        Dom.Scroll.toTop mainId |> Task.attempt (always NoOp)
            in
            { model | loginFormTopBlockOpen = not model.loginFormTopBlockOpen }
                ! [ cmd ]

        ToggleSearchDialog ->
            let
                searchFocus =
                    if not model.searchDialogOpen then
                        Dom.focus "searchbox-input" |> Task.attempt (\_ -> NoOp)
                    else
                        Cmd.none
            in
            { model | searchDialogOpen = not model.searchDialogOpen, searchValue = "" }
                ! [ searchFocus ]

        UpdateSearchField value ->
            ( { model | searchValue = value }, Cmd.none )

        ClearSearchField ->
            ( { model | searchValue = "" }, Cmd.none )

        SearchEntries searchTerm ->
            if length searchTerm == 0 then
                ( model, Cmd.none )
            else
                ( model, navigateTo (SearchRoute searchTerm) )

        ChangeLanguage language ->
            { model
                | appLanguage = language
                , entry = Loading
                , countries = Loading
                , categories = Loading
                , categoriesWithEntries = Loading
                , popularEntries = Loading
            }
                ! [ setLocalLanguage <| toString language
                  , Navigation.modifyUrl <| routeToPath model.route
                  ]

        ScrollToTop ->
            model
                ! [ Dom.Scroll.toTop mainId |> Task.attempt (always NoOp) ]

        -- Boilerplate: MDL action handler.
        MDL msg ->
            Material.update MDL msg model

        Snackbar msg ->
            Snackbar.update msg model.snackbar
                |> map1st (\s -> { model | snackbar = s })
                |> map2nd (Cmd.map Snackbar)

        NoOp ->
            ( model, Cmd.none )


fetchUserVotedWords : Route -> UserToken -> Cmd Msg
fetchUserVotedWords route token =
    case route of
        EntryRoute entrySlug entryId ->
            Cmd.map WordsMsg <| WordsCmds.fetchEntryVotedWords entryId token

        _ ->
            Cmd.none
