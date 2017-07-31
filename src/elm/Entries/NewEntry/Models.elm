module Entries.NewEntry.Models exposing (..)

import Categories.Models exposing (CategoryId)
import Material


type alias NewEntryModel =
    { title : String
    , categoryId : Maybe CategoryId
    , description : String
    , imageUrl : String
    , imageCaption : String
    , titleError : String
    , descriptionError : String
    , imageUrlError : String
    , formSubmitted : Bool
    , mdl : Material.Model
    }


newEntryModelInit : NewEntryModel
newEntryModelInit =
    { title = ""
    , categoryId = Nothing
    , description = ""
    , imageUrl = ""
    , imageCaption = ""
    , titleError = ""
    , descriptionError = ""
    , imageUrlError = ""
    , formSubmitted = False
    , mdl = Material.model
    }
