module Pages.UserEntriesPage exposing (view)

import App.Translations exposing (Language, TranslationId(ErrorText, LoadingText, MyEntriesDescText, MyEntriesText), translate)
import Entries.Messages exposing (Msg)
import Entries.Models exposing (Entry)
import Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)
import Entries.Partials.EntriesGridBlockEmpty exposing (gridBlockEmpty)
import Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)
import Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import RemoteData exposing (RemoteData(..), WebData)


view : WebData (List Entry) -> Language -> Html Msg
view userEntries language =
    let
        title =
            translate language MyEntriesText

        subTitle =
            translate language MyEntriesDescText

        gridBlock =
            case userEntries of
                NotAsked ->
                    gridBlockLoading title ""

                Loading ->
                    gridBlockLoading title (translate language LoadingText)

                Failure err ->
                    gridBlockFailure title (translate language <| ErrorText (toString err))

                Success [] ->
                    gridBlockEmpty title subTitle language

                Success entries ->
                    entriesGridBlock entries title subTitle Nothing False language
    in
    div [ class "entries-grid h-full-height" ]
        [ gridBlock ]
