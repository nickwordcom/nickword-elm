module Categories.Commands exposing (..)

import App.Translations exposing (Language(..), decodeLang)
import App.Utils.Config exposing (apiUrl)
import App.Utils.Converters exposing (fromResult)
import App.Utils.Requests exposing (encodeUrl)
import Categories.Messages exposing (Msg(..))
import Categories.Models exposing (Category, CategoryId, CategoryWithEntries)
import Entries.Commands exposing (entryDecoder)
import Http
import Json.Decode as Decode exposing (field)


-- HTTP Requests


fetchAll : Language -> Cmd Msg
fetchAll language =
    Http.get (categoriesUrl False language) categoryListDecoder
        |> Http.send (CategoriesResponse << fromResult)


fetchAllWE : Language -> Cmd Msg
fetchAllWE language =
    Http.get (categoriesUrl True language) categoryWEListDecoder
        |> Http.send (CategoriesWithEntriesResponse << fromResult)



-- URLs


categoriesUrl : Bool -> Language -> String
categoriesUrl includeEntries language =
    let
        baseUrl =
            apiUrl ++ "/categories"

        includeParam =
            if includeEntries then
                ( "include", "entries" )
            else
                ( "", "" )

        localeParam =
            if language /= English then
                ( "locale", decodeLang language )
            else
                ( "", "" )

        params =
            [ includeParam, localeParam ]
                |> List.filter (\p -> p /= ( "", "" ))
    in
    encodeUrl baseUrl params



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


categoryWEListDecoder : Decode.Decoder (List CategoryWithEntries)
categoryWEListDecoder =
    Decode.map identity
        (field "data" (Decode.list categoryWEDecoder))


categoryWEDecoder : Decode.Decoder CategoryWithEntries
categoryWEDecoder =
    Decode.map5 CategoryWithEntries
        (field "id" Decode.string)
        (field "slug" Decode.string)
        (field "title" Decode.string)
        (field "entries_count" Decode.int)
        (field "entries" (Decode.list entryDecoder))
