module Categories.ShowPage exposing (..)

import App.Translations exposing (Language, TranslationId(ErrorText, LoadMoreText, LoadingText, NumberOfEntriesText), translate)
import Categories.Models exposing (Category)
import Entries.Messages exposing (Msg(LoadMoreEntries))
import Entries.Models exposing (Entry, LoadMoreState(..))
import Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)
import Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)
import Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Material.Spinner as Spinner
import RemoteData exposing (RemoteData(..), WebData)


view : WebData (List Entry) -> Category -> Language -> LoadMoreState -> Html Msg
view categoryEntries category language loadMoreState =
    let
        title =
            category.title

        subTitle =
            NumberOfEntriesText category.entriesCount |> translate language

        gridBlock =
            case categoryEntries of
                NotAsked ->
                    [ gridBlockLoading title "" ]

                Loading ->
                    [ gridBlockLoading title (translate language LoadingText) ]

                Failure err ->
                    [ gridBlockFailure title (translate language <| ErrorText (toString err)) ]

                Success entries ->
                    [ entriesGridBlock entries title subTitle Nothing False language
                    , loadMoreButton loadMoreState language
                    ]
    in
    div [ class "entries-grid h-full-height" ]
        gridBlock


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
            span [] []
