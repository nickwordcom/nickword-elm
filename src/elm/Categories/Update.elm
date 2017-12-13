module Categories.Update exposing (..)

import App.Models exposing (Model, WebData)
import App.Routing exposing (Route(CategoryRoute))
import App.Utils.Title exposing (setCategoryTitle)
import Categories.Messages exposing (Msg(..))
import Categories.Models exposing (Category)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CategoriesResponse response ->
            ( { model | categories = response }, checkAndSetCategoryTitle response model.route )


checkAndSetCategoryTitle : WebData (List Category) -> Route -> Cmd Msg
checkAndSetCategoryTitle categories route =
    case route of
        CategoryRoute categorySlug categoryId ->
            setCategoryTitle categories categoryId

        _ ->
            Cmd.none
