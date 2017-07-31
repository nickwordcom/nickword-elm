module ShareDialog.Messages exposing (..)

import Material


type Msg
    = NoOp
    | EditDialog
    | UpdateEditedTitle String
    | UpdateEditedSubtitle String
    | UpdateEditedWord String
    | UpdateEditedImage String
    | UpdateShareDialog
    | CloseEditor
    | MDL (Material.Msg Msg)
