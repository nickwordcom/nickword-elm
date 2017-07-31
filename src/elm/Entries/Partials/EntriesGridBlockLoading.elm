module Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)

import Entries.Messages exposing (Msg)
import Html exposing (Html, div, h2, span, text)
import Html.Attributes exposing (class)
import Material.Options exposing (css)
import Material.Spinner as Spinner


type alias Title =
    String


type alias SubTitle =
    String


gridBlockLoading : Title -> SubTitle -> Html Msg
gridBlockLoading title subTitle =
    div [ class "entries-grid h-full-height" ]
        [ div [ class "entries-grid__block" ]
            [ div [ class "entries-grid__header h-clearfix" ]
                [ div [ class "entries-grid__header-info" ]
                    [ h2 [ class "entries-grid__header-title" ]
                        [ text title ]
                    , span [ class "entries-grid__header-subtitle" ]
                        [ text subTitle ]
                    ]
                ]
            , div [ class "entries-grid__loading" ]
                [ Spinner.spinner
                    [ Spinner.active True
                    , Spinner.singleColor True
                    , css "vertical-align" "middle"
                    , css "margin" "2px 0"
                    ]
                ]
            ]
        ]
