module Maps.EntryVotesMapTab exposing (view)

import Html exposing (Html, div, section)
import Html.Attributes exposing (class, id, style)


view : Html a
view =
    section [ class "entry-map" ]
        [ div [ id "entry-map-votes" ] []
        ]
