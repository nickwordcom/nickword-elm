module Entries.Partials.FiltersCollapse exposing (view)

import App.Models exposing (WebData)
import App.Translations exposing (Language, TranslationId(FiltersText, HideText, ShowText), translate)
import Countries.Models exposing (Country, EntryVotedCountries)
import Entries.Messages exposing (Msg(ToggleEntryFilters))
import Entries.Models exposing (FiltersConfig)
import Entries.Partials.VoteFilters as VoteFilters
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Material


view : WebData (List Country) -> EntryVotedCountries -> FiltersConfig -> Language -> Material.Model -> Html Msg
view countries entryVotedCountries ({ filtersExpanded } as filtersConfig) language mdlModel =
    div [ class "filters-collapse mdl-shadow--2dp" ]
        [ div
            [ class "filters-collapse__head h-clearfix h-clickable"
            , onClick ToggleEntryFilters
            ]
            [ h4 [ class "filters-collapse__head-title" ]
                [ text <| translate language FiltersText ]
            , span [ classList [ ( "filters-collapse__head-action", True ), ( "is-visible", not filtersExpanded ) ] ]
                [ text <| translate language ShowText ]
            , span [ classList [ ( "filters-collapse__head-action", True ), ( "is-visible", filtersExpanded ) ] ]
                [ text <| translate language HideText ]
            ]
        , div [ classList [ ( "filters-collapse__content", True ), ( "is-visible", filtersExpanded ) ] ]
            [ VoteFilters.view countries entryVotedCountries filtersConfig language mdlModel ]
        ]
