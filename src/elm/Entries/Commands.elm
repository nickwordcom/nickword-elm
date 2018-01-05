module Entries.Commands exposing (..)

import App.Translations exposing (Language(English), decodeLang)
import App.Utils.Config exposing (apiUrl)
import App.Utils.Requests exposing (encodeUrl, getWithAuth)
import Categories.Models exposing (CategoryId)
import Entries.Messages exposing (..)
import Entries.Models exposing (Entry, EntryId, EntryImage)
import Http
import Json.Decode as Decode exposing (field)
import RemoteData
import Users.Models exposing (User)


-- HTTP Requests


fetchAllFromCategory : CategoryId -> Language -> Int -> Cmd Msg
fetchAllFromCategory categoryId language pageNumber =
    Http.get (categoryEntriesUrl categoryId language pageNumber) entryListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map CategoryEntriesResponse


fetchUserEntries : User -> Language -> Int -> Cmd Msg
fetchUserEntries { jwt } language pageNumber =
    getWithAuth (userEntriesUrl language pageNumber) entryListDecoder jwt
        |> RemoteData.sendRequest
        |> Cmd.map UserEntriesResponse


fetchPopular : Language -> Cmd Msg
fetchPopular language =
    Http.get (entriesPopularUrl (Just 6) language) entryListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntriesPopularResponse


fetchAllPopular : Language -> Cmd Msg
fetchAllPopular language =
    Http.get (entriesPopularUrl Nothing language) entryListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map AllPopularEntriesResponse


fetchFeatured : Language -> Cmd Msg
fetchFeatured language =
    Http.get (entriesFeaturedUrl language) entryListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntriesFeaturedResponse


fetchEntry : EntryId -> Language -> Cmd Msg
fetchEntry entryId language =
    Http.get (entryUrl entryId language) entrySingleDecoder
        |> RemoteData.sendRequest
        |> Cmd.map EntryResponse


fetchRandom : Language -> Cmd Msg
fetchRandom language =
    Http.get (entriesRandomUrl language) entrySingleDecoder
        |> RemoteData.sendRequest
        |> Cmd.map RandomEntryResponse


searchEntries : String -> Language -> Cmd Msg
searchEntries query language =
    Http.get (searchUrl query language) entryListDecoder
        |> RemoteData.sendRequest
        |> Cmd.map SearchEntriesResponse



-- URLs


entriesUrl : String
entriesUrl =
    apiUrl ++ "/entries"


entryUrl : EntryId -> Language -> String
entryUrl entryId language =
    let
        baseUrl =
            entriesUrl ++ "/" ++ entryId

        params =
            [ ( "locale", decodeLang language ) ]
    in
    encodeUrl baseUrl params


entriesPopularUrl : Maybe Int -> Language -> String
entriesPopularUrl maybeLimit language =
    let
        baseUrl =
            entriesUrl ++ "/popular"

        limitParam =
            case maybeLimit of
                Just limit ->
                    ( "limit", toString limit )

                Nothing ->
                    ( "", "" )

        localeParam =
            ( "locale", decodeLang language )

        params =
            [ limitParam, localeParam ]
                |> List.filter (\p -> p /= ( "", "" ))
    in
    encodeUrl baseUrl params


entriesFeaturedUrl : Language -> String
entriesFeaturedUrl language =
    let
        baseUrl =
            entriesUrl ++ "/featured"

        params =
            [ ( "locale", decodeLang language ) ]
    in
    encodeUrl baseUrl params


categoryEntriesUrl : CategoryId -> Language -> Int -> String
categoryEntriesUrl categoryId language pageNumber =
    let
        baseUrl =
            apiUrl ++ "/categories/" ++ categoryId ++ "/entries"

        params =
            [ ( "locale", decodeLang language )
            , ( "page", toString pageNumber )
            ]
    in
    encodeUrl baseUrl params


userEntriesUrl : Language -> Int -> String
userEntriesUrl language pageNumber =
    let
        baseUrl =
            entriesUrl ++ "/my"

        params =
            [ ( "locale", decodeLang language )
            , ( "page", toString pageNumber )
            ]
    in
    encodeUrl baseUrl params


entriesRandomUrl : Language -> String
entriesRandomUrl language =
    let
        baseUrl =
            entriesUrl ++ "/random"

        params =
            [ ( "locale", decodeLang language ) ]
    in
    encodeUrl baseUrl params


searchUrl : String -> Language -> String
searchUrl query language =
    let
        baseUrl =
            entriesUrl ++ "/search"

        params =
            [ ( "locale", decodeLang language )
            , ( "title", query )
            ]
    in
    encodeUrl baseUrl params



-- DECODERS


entryListDecoder : Decode.Decoder (List Entry)
entryListDecoder =
    Decode.map identity
        (field "data" (Decode.list entryDecoder))


entrySingleDecoder : Decode.Decoder Entry
entrySingleDecoder =
    Decode.map identity
        (field "data" entryDecoder)


entryDecoder : Decode.Decoder Entry
entryDecoder =
    Decode.map7 Entry
        (field "id" Decode.string)
        (field "slug" Decode.string)
        (field "title" Decode.string)
        (field "description" Decode.string)
        (field "image" entryImageDecoder)
        (field "category_id" Decode.string)
        (field "votes_count" Decode.int)


entryImageDecoder : Decode.Decoder EntryImage
entryImageDecoder =
    Decode.map2 EntryImage
        (field "url" Decode.string)
        (field "caption" Decode.string)
