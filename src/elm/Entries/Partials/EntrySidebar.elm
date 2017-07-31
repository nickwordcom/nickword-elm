module Entries.Partials.EntrySidebar exposing (..)

import App.Models exposing (WebData)
import App.Translations exposing (Language, TranslationId(FiltersText), translate)
import Countries.Models exposing (Country, EntryVotedCountries)
import Entries.Messages exposing (Msg)
import Entries.Models exposing (FiltersConfig)
import Entries.Partials.VoteFilters as VoteFilters
import Html exposing (..)
import Html.Attributes exposing (..)
import Material


view : WebData (List Country) -> EntryVotedCountries -> FiltersConfig -> Language -> Material.Model -> Html Msg
view countries entryVotedCountries filtersConfig language mdlModel =
    div [ class "entry-sidebar" ]
        [ div [ class "entry-sidebar__section" ]
            [ h3 [ class "entry-sidebar__section-title h-overflow-ellipsis" ]
                [ text <| translate language FiltersText ]
            , div [ class "entry-sidebar__section-content" ]
                [ VoteFilters.view countries entryVotedCountries filtersConfig language mdlModel ]
            ]
        ]
