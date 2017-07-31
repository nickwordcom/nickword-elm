module Entries.Partials.EntryTabs exposing (view)

import App.Routing exposing (Route(EntryCloudRoute, EntryMapRoute, EntryRoute), routeToPath)
import App.Translations exposing (..)
import App.Utils.Links exposing (linkTo)
import Entries.Messages exposing (Msg(MDL, Navigate))
import Entries.Models exposing (EntryId, EntrySlug)
import Html exposing (Html, span, text)
import Html.Attributes exposing (class)
import Material exposing (Model)
import Material.Options exposing (cs)
import Material.Tabs as Tabs


view : EntryId -> EntrySlug -> Int -> Language -> Material.Model -> Html Msg
view entryId entrySlug entryTabIndex language mdlModel =
    let
        entryWordsPath =
            routeToPath (EntryRoute entrySlug entryId)

        entryCloudPath =
            routeToPath (EntryCloudRoute entrySlug entryId)

        entryMapPath =
            routeToPath (EntryMapRoute entrySlug entryId)
    in
    Tabs.render MDL
        [ 1 ]
        mdlModel
        [ Tabs.activeTab entryTabIndex ]
        [ Tabs.label [ cs "h-clickable" ]
            [ span [ class "entry-page__tab-text--long" ] [ text <| translate language WordsTabText ]
            , span [ class "entry-page__tab-text--short" ] [ text <| translate language WordsTabText ]
            , linkTo entryWordsPath
                (Navigate entryWordsPath)
                [ class "click-block" ]
                []
            ]
        , Tabs.label [ cs "h-clickable" ]
            [ span [ class "entry-page__tab-text--long" ] [ text <| translate language CloudTabLongText ]
            , span [ class "entry-page__tab-text--short" ] [ text <| translate language CloudTabShortText ]
            , linkTo entryCloudPath
                (Navigate entryCloudPath)
                [ class "click-block" ]
                []
            ]
        , Tabs.label [ cs "h-clickable" ]
            [ span [ class "entry-page__tab-text--long" ] [ text <| translate language MapTabLongText ]
            , span [ class "entry-page__tab-text--short" ] [ text <| translate language MapTabShortText ]
            , linkTo entryMapPath
                (Navigate entryMapPath)
                [ class "click-block" ]
                []
            ]

        -- , Tabs.label [ cs "h-clickable" ]
        --     [ span [ class "entry-page__tab-text--long" ] [ text <| translate language VotesTabLongText ]
        --     , span [ class "entry-page__tab-text--short" ] [ text <| translate language VotesTabShortText ]
        --     , span [ onClick (Navigate entryMapPath), class "click-block" ] [] ]
        ]
        []
