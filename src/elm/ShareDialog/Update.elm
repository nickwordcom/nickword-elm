module ShareDialog.Update exposing (..)

import Material
import ShareDialog.Messages exposing (Msg(..))
import ShareDialog.Models exposing (ShareDialog)


update : Msg -> ShareDialog -> ( ShareDialog, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            model ! []

        EditDialog ->
            let
                changes =
                    { title = model.title
                    , subTitle = model.subTitle
                    , word = model.word
                    , imageUrl = model.imageUrl
                    }
            in
            { model | changes = changes, editing = True } ! []

        UpdateEditedTitle input ->
            let
                changes =
                    model.changes

                updates =
                    { changes | title = input }
            in
            { model | changes = updates } ! []

        UpdateEditedSubtitle input ->
            let
                changes =
                    model.changes

                updates =
                    { changes | subTitle = input }
            in
            { model | changes = updates } ! []

        UpdateEditedWord input ->
            let
                changes =
                    model.changes

                updates =
                    { changes | word = input }
            in
            { model | changes = updates } ! []

        UpdateEditedImage input ->
            let
                changes =
                    model.changes

                updates =
                    { changes | imageUrl = input }
            in
            { model | changes = updates } ! []

        UpdateShareDialog ->
            { model
                | title = model.changes.title
                , subTitle = model.changes.subTitle
                , word = model.changes.word
                , imageUrl = model.changes.imageUrl
                , editing = False
            }
                ! []

        CloseEditor ->
            { model | editing = False } ! []

        MDL msg ->
            Material.update MDL msg model
