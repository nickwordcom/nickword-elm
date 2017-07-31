module Entries.NewEntry.Messages exposing (..)

import Categories.Models exposing (CategoryId)
import Entries.Models exposing (Entry)
import Http exposing (Error)
import Material


type Msg
    = NoOp
      -- HANDLING CHANGES
    | ChangeTitleInput String
    | ChangeCategoryIdValue (Maybe CategoryId)
    | ChangeDescriptionInput String
    | ChangeImageUrlInput String
    | ChangeImageCaptionInput String
      -- CHECK USER INPUT
    | CheckTitleInput
    | CheckDescriptionInput
    | CheckImageUrlInput
      -- ADD NEW ENTRY
    | AddNewEntry
    | AddNewEntryData (Result Error Entry)
      -- Material
    | MDL (Material.Msg Msg)
