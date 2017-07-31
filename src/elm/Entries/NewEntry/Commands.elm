module Entries.NewEntry.Commands exposing (..)

import App.Utils.Config exposing (apiUrl)
import App.Utils.Requests exposing (postWithAuth)
import Entries.Commands exposing (entrySingleDecoder)
import Entries.Models exposing (NewEntry, newEntryInit)
import Entries.NewEntry.Messages exposing (Msg(AddNewEntryData))
import Entries.NewEntry.Models exposing (NewEntryModel)
import Http
import Json.Encode as Encode
import String.Extra exposing (stripTags)
import Users.Models exposing (UserToken)


-- HTTP Requests


addNewEntry : NewEntry -> UserToken -> Cmd Msg
addNewEntry newEntry token =
    postWithAuth entriesUrlPOST (newEntryEncoded newEntry) entrySingleDecoder token
        |> Http.send AddNewEntryData



-- URLs


entriesUrlPOST : String
entriesUrlPOST =
    apiUrl ++ "/p/entries"



-- ENCODERS


newEntryEncoded : NewEntry -> Encode.Value
newEntryEncoded entry =
    let
        newEntry =
            [ ( "title", Encode.string entry.title )
            , ( "description", Encode.string entry.description )
            , ( "image_url", Encode.string entry.imageUrl )
            , ( "image_caption", Encode.string entry.imageCaption )
            , ( "category_id", Encode.string entry.categoryId )

            -- , ("category_ids", Encode.list (List.map (\id -> Encode.int id) entry.categoryIds) )
            ]
    in
    Encode.object [ ( "entry", Encode.object newEntry ) ]



-- HELPERS


prepareAndSendEntry : NewEntryModel -> UserToken -> Cmd Msg
prepareAndSendEntry model token =
    let
        newModel =
            { newEntryInit
                | title = stripTags model.title
                , description = stripTags model.description
                , categoryId = Maybe.withDefault "" model.categoryId
                , imageUrl = stripTags model.imageUrl
                , imageCaption = stripTags model.imageCaption
            }
    in
    addNewEntry newModel token
