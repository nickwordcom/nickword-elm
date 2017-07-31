module Countries.Update exposing (..)

import App.Models exposing (Model)
import Countries.Messages exposing (Msg(..))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        CountriesResponse response ->
            ( { model | countries = response }, Cmd.none )
