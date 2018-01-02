module App.Utils.Title exposing (..)

import App.Models exposing (RemoteData(..), WebData)
import App.Ports exposing (appDescription, appTitle)
import Categories.Models exposing (Category, CategoryId)
import Entries.Models exposing (Entry, EntryId)
import List exposing (filterMap, head)
import String exposing (length)


newAppTitle : String -> String
newAppTitle pageTitle =
    let
        base =
            "Nickword"

        newTitle =
            if String.length pageTitle == 0 then
                base
            else
                pageTitle ++ " - " ++ base
    in
    newTitle


setEntryTitle : WebData Entry -> Cmd msg
setEntryTitle entry =
    case entry of
        Loading ->
            Cmd.none

        Failure err ->
            Cmd.none

        Success entry ->
            appTitle (newAppTitle entry.title)


setCategoryTitle : WebData (List Category) -> CategoryId -> Cmd msg
setCategoryTitle categories categoryId =
    case categories of
        Loading ->
            Cmd.none

        Failure err ->
            Cmd.none

        Success categories ->
            let
                checkCategory category =
                    if category.id == categoryId then
                        Just category
                    else
                        Nothing

                category =
                    List.head (List.filterMap checkCategory categories)
            in
            case category of
                Just category ->
                    appTitle (newAppTitle category.title)

                Nothing ->
                    appTitle (newAppTitle "")


setEntryDescription : WebData Entry -> Cmd msg
setEntryDescription entry =
    case entry of
        Loading ->
            Cmd.none

        Failure err ->
            Cmd.none

        Success entry ->
            appDescription entry.description
