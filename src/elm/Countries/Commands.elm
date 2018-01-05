module Countries.Commands exposing (..)

import App.Translations exposing (Language(..), decodeLang)
import App.Utils.Config exposing (apiUrl)
import App.Utils.Requests exposing (encodeUrl)
import Countries.Messages exposing (Msg(..))
import Countries.Models exposing (Country)
import Http
import Json.Decode as Decode exposing (field)
import RemoteData


-- HTTP Requests


fetchAll : Language -> Cmd Msg
fetchAll language =
    Http.get (countriesUrl language) countriesListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map CountriesResponse



-- URLs


countriesUrl : Language -> String
countriesUrl language =
    let
        baseUrl =
            apiUrl ++ "/countries"
    in
    encodeUrl baseUrl [ ( "locale", decodeLang language ) ]



-- DECODERS


countriesListDecoder : Decode.Decoder (List Country)
countriesListDecoder =
    Decode.map identity
        (field "data" (Decode.list countryDecoder))


countryDecoder : Decode.Decoder Country
countryDecoder =
    Decode.map2 Country
        (field "code" Decode.string)
        (field "name" Decode.string)
