module Entries.Partials.EntryTabs exposing (view)

import App.Translations exposing (..)
import App.Utils.Converters exposing (entryTabToIndex)
import Entries.Messages exposing (Msg(MDL, SelectEntryTab))
import Entries.Models exposing (EntryTab)
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Material exposing (Model)
import Material.Options as Options exposing (cs)
import Material.Tabs as Tabs


view : EntryTab -> Language -> Material.Model -> Html Msg
view entryTab language mdlModel =
    Tabs.render MDL
        [ 1 ]
        mdlModel
        [ Tabs.activeTab (entryTabToIndex entryTab)
        , Tabs.onSelectTab SelectEntryTab
        ]
        [ Tabs.label [ cs "h-clickable" ]
            [ Options.span [ cs "entry-page__tab-text--long" ]
                [ text <| translate language WordsTabText ]
            , Options.span [ cs "entry-page__tab-text--short" ]
                [ text <| translate language WordsTabText ]
            ]
        , Tabs.label [ cs "h-clickable" ]
            [ Options.span [ cs "entry-page__tab-text--long" ]
                [ text <| translate language CloudTabLongText ]
            , Options.span [ cs "entry-page__tab-text--short" ]
                [ text <| translate language CloudTabShortText ]
            ]
        , Tabs.label [ cs "h-clickable" ]
            [ Options.span [ cs "entry-page__tab-text--long" ]
                [ text <| translate language MapTabLongText ]
            , Options.span [ cs "entry-page__tab-text--short" ]
                [ text <| translate language MapTabShortText ]
            ]
        ]
        []
