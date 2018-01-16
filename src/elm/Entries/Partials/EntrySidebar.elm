module Entries.Partials.EntrySidebar exposing (..)

import App.Translations exposing (Language, TranslationId(FilterText), translate)
import Countries.Models exposing (Country, EntryVotedCountries)
import Entries.Messages exposing (Msg)
import Entries.Models exposing (FiltersConfig)
import Entries.Partials.VoteFilters as VoteFilters
import Html exposing (..)
import Html.Attributes exposing (..)
import Material
import Material.Icon as Icon
import RemoteData exposing (WebData)


view : WebData (List Country) -> EntryVotedCountries -> FiltersConfig -> Language -> Material.Model -> Html Msg
view countries entryVotedCountries filtersConfig language mdlModel =
    div [ class "entry-sidebar" ]
        [ div [ class "entry-sidebar__section" ]
            [ div [ class "entry-sidebar__section-head h-overflow-ellipsis" ]
                [ Icon.i "filter_list"
                , h3 [ class "entry-sidebar__section-title" ]
                    [ text <| translate language FilterText ]
                ]
            , div [ class "entry-sidebar__section-content" ]
                [ VoteFilters.view countries entryVotedCountries filtersConfig language mdlModel ]
            ]
        ]
