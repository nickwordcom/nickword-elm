module Entries.NewEntry.Update exposing (..)

import App.Routing exposing (Route(EntriesRoute, EntryRoute), routeToPath)
import App.Translations exposing (Language)
import App.Utils.Checkers exposing (..)
import Dom.Scroll
import Entries.NewEntry.Commands exposing (prepareAndSendEntry)
import Entries.NewEntry.Messages exposing (Msg(..))
import Entries.NewEntry.Models exposing (NewEntryModel)
import Material
import Material.Layout exposing (mainId)
import Navigation exposing (newUrl)
import Task
import Users.Models exposing (UserToken)


update : Msg -> NewEntryModel -> Language -> UserToken -> ( NewEntryModel, Cmd Msg )
update msg model appLanguage token =
    case msg of
        NoOp ->
            model ! []

        -- HANDLING CHANGES
        ChangeTitleInput input ->
            { model | title = input } ! []

        ChangeCategoryIdValue input ->
            { model | categoryId = input } ! []

        ChangeDescriptionInput input ->
            { model | description = input } ! []

        ChangeImageUrlInput input ->
            { model | imageUrl = input, imageUrlError = checkForImageUrlError input appLanguage } ! []

        ChangeImageCaptionInput input ->
            { model | imageCaption = input } ! []

        -- CHECK USER INPUT
        CheckTitleInput ->
            { model | titleError = checkForTitleError model.title appLanguage } ! []

        CheckDescriptionInput ->
            { model | descriptionError = checkForDescriptionError model.description appLanguage } ! []

        CheckImageUrlInput ->
            { model | imageUrlError = checkForImageUrlError model.imageUrl appLanguage } ! []

        -- ADD NEW ENTRY
        AddNewEntry ->
            { model | formSubmitted = True } ! [ prepareAndSendEntry model token ]

        AddNewEntryData (Ok entry) ->
            model
                ! [ newUrl (routeToPath (EntryRoute entry.slug entry.id))
                  , Dom.Scroll.toTop mainId |> Task.attempt (always NoOp)
                  ]

        AddNewEntryData (Err error) ->
            model ! [ newUrl (routeToPath EntriesRoute) ]

        -- Material
        MDL msg ->
            Material.update MDL msg model
