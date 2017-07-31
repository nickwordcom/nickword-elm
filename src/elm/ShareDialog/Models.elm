module ShareDialog.Models exposing (..)

import Entries.Models exposing (EntryId)
import Material


type SocialNetwork
    = Facebook
    | VK
    | Pinterest


type alias ShareDialog =
    { title : String
    , subTitle : String
    , word : String
    , imageUrl : String
    , entrySlug : String
    , entryId : EntryId
    , editing : Bool
    , changes : ShareDialogChanges
    , mdl : Material.Model
    }


type alias ShareDialogChanges =
    { title : String
    , subTitle : String
    , word : String
    , imageUrl : String
    }


initShareDialog : ShareDialog
initShareDialog =
    { title = ""
    , subTitle = ""
    , word = ""
    , imageUrl = ""
    , entrySlug = ""
    , entryId = ""
    , editing = False
    , changes = ShareDialogChanges "" "" "" ""
    , mdl = Material.model
    }
