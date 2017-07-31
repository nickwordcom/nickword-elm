module App.Subscriptions exposing (..)

import App.Messages exposing (Msg(MDL, WordsMsg))
import App.Models exposing (Model)
import Material.Layout exposing (subs)
import Material.Menu as Menu exposing (subs)
import Words.Messages as WordsMsgs


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map WordsMsg (Menu.subs WordsMsgs.MDL model.mdl)
        , Material.Layout.subs MDL model.mdl

        -- , Time.every Time.minute RequestTimeUpdate
        ]
