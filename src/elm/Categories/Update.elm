module Categories.Update exposing (..)

import App.Models exposing (Model)
import App.Utils.PageInfo exposing (categoryPageInfo)
import Categories.Messages exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        CategoriesResponse response ->
            { model | categories = response }
                ! [ categoryPageInfo response model.route model.appLanguage ]
