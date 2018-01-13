module Pages.UserEntriesPage exposing (view)

import App.Translations exposing (Language, TranslationId(ErrorText, LoadMoreText, LoadingText, MyEntriesDescText, MyEntriesText), translate)
import Entries.Messages exposing (Msg(LoadMoreEntries))
import Entries.Models exposing (Entry, LoadMoreState(..))
import Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)
import Entries.Partials.EntriesGridBlockEmpty exposing (gridBlockEmpty)
import Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)
import Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Material.Spinner as Spinner
import RemoteData exposing (RemoteData(..), WebData)


view : WebData (List Entry) -> LoadMoreState -> Language -> Html Msg
view userEntries loadMoreState language =
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
                    div []
                        [ entriesGridBlock entries title subTitle Nothing False language
                        , loadMoreButton loadMoreState language
                        ]
    in
    div [ class "entries-grid h-full-height" ]
        [ gridBlock ]


loadMoreButton : LoadMoreState -> Language -> Html Msg
loadMoreButton loadMoreState language =
    case loadMoreState of
        EntriesNotAsked ->
            div
                [ class "entries-grid__load-more mdl-color--primary mdl-color-text--white mdl-shadow--2dp h-clickable"
                , onClick LoadMoreEntries
                ]
                [ text <| translate language LoadMoreText ]

        EntriesLoading ->
            div [ class "entries-grid__loading" ]
                [ Spinner.spinner
                    [ Spinner.active True
                    , Spinner.singleColor True
                    ]
                ]

        EntriesFull ->
            text ""
