module Pages.SearchPage exposing (..)

import App.Translations exposing (Language, TranslationId(ErrorText, LoadingText, NumberOfEntriesText, SearchWithTermText), translate)
import Entries.Messages exposing (Msg)
import Entries.Models exposing (Entry)
import Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)
import Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)
import Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import List exposing (length)
import RemoteData exposing (RemoteData(..), WebData)


view : WebData (List Entry) -> Language -> String -> Html Msg
view entries language searchTerm =
    case entries of
        NotAsked ->
            gridBlockLoading "" ""

        Loading ->
            gridBlockLoading (translate language LoadingText) ""

        Failure error ->
            gridBlockFailure (translate language <| ErrorText (toString error)) ""

        Success entries ->
            let
                title =
                    translate language <| SearchWithTermText searchTerm

                subTitle =
                    translate language <| NumberOfEntriesText (length entries)
            in
            div [ class "entries-grid h-full-height" ]
                [ entriesGridBlock entries title subTitle Nothing False language ]
