module Main exposing (..)

import App.Messages exposing (Msg(OnLocationChange))
import App.Models exposing (Flags, Model, initialModel)
import App.Routing as Routing exposing (Route)
import App.Subscriptions exposing (subscriptions)
import App.Translations exposing (Language)
import App.Update exposing (update)
import App.UrlUpdate exposing (urlUpdate)
import App.Utils.Converters exposing (determineLanguage)
import App.View exposing (view)
import Navigation exposing (Location)
import Users.Models exposing (User)
import Users.Utils exposing (checkUserJWT)


init : Flags -> Location -> ( Model, Cmd Msg )
init { localLanguage, localJWT } location =
    let
        ( currentRoute, urlLang ) =
            Routing.parseLocation location

        currentLanguage : Language
        currentLanguage =
            determineLanguage localLanguage urlLang

        currentUser : User
        currentUser =
            checkUserJWT localJWT
    in
    initialModel currentRoute currentUser currentLanguage
        |> urlUpdate location


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
