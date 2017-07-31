module Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)

import Entries.Messages exposing (Msg)
import Html exposing (Html, div, h2, span, text)
import Html.Attributes exposing (class)


type alias Title =
    String


type alias SubTitle =
    String


gridBlockFailure : Title -> SubTitle -> Html Msg
gridBlockFailure title subTitle =
    div [ class "entries-grid h-full-height" ]
        [ div [ class "entries-grid__block h-spacing-below--large" ]
            [ div [ class "entries-grid__header h-clearfix" ]
                [ div [ class "entries-grid__header-info" ]
                    [ h2 [ class "entries-grid__header-title" ]
                        [ text title ]
                    , span [ class "entries-grid__header-subtitle mdl-color-text--red-A700" ]
                        [ text subTitle ]
                    ]
                ]
            ]
        ]
