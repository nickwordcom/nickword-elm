module Entries.Partials.EntriesGridBlockEmpty exposing (gridBlockEmpty)

import App.Routing exposing (Route(EntriesNewRoute), routeToPath)
import App.Translations exposing (Language, TranslationId(CreateEntryText), translate)
import App.Utils.Links exposing (linkTo)
import Entries.Messages exposing (Msg(Navigate))
import Html exposing (Html, div, h2, span, text)
import Html.Attributes exposing (class)


type alias Title =
    String


type alias SubTitle =
    String


gridBlockEmpty : Title -> SubTitle -> Language -> Html Msg
gridBlockEmpty title subTitle language =
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
            , div [ class "h-text-center h-spacing-above--normal h-spacing-below--normal" ]
                [ linkTo newEntryPath
                    (Navigate newEntryPath)
                    [ class "mdl-button mdl-button--colored mdl-button--raised" ]
                    [ text <| translate language CreateEntryText ]
                ]
            ]
        ]


newEntryPath : String
newEntryPath =
    routeToPath EntriesNewRoute
