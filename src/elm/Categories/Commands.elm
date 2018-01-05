module Categories.Commands exposing (..)

import App.Translations exposing (Language(..), decodeLang)
import App.Utils.Config exposing (apiUrl)
import App.Utils.Requests exposing (encodeUrl)
import Categories.Messages exposing (Msg(..))
import Categories.Models exposing (Category, CategoryId)
import Http
import Json.Decode as Decode exposing (field)
import RemoteData


-- HTTP Requests


fetchAll : Language -> Cmd Msg
fetchAll language =
    Http.get (categoriesUrl False language) categoryListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map CategoriesResponse



-- URLs


categoriesUrl : Bool -> Language -> String
categoriesUrl includeEntries language =
    let
        baseUrl =
            apiUrl ++ "/categories"

        localeParam =
            if language == English then
                ( "locale", "en" )
            else
                ( "locale", decodeLang language )
    in
    encodeUrl baseUrl [ localeParam ]



-- DECODERS


categoryListDecoder : Decode.Decoder (List Category)
categoryListDecoder =
    Decode.map identity
        (field "data" (Decode.list categoryDecoder))


categoryDecoder : Decode.Decoder Category
categoryDecoder =
    Decode.map4 Category
        (field "id" Decode.string)
        (field "slug" Decode.string)
        (field "title" Decode.string)
        (field "entries_count" Decode.int)
