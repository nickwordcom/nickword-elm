module Entries.Partials.VoteFilters exposing (view)

import App.Translations exposing (..)
import Countries.Models exposing (Country, EntryVotedCountries)
import Countries.Partials.SelectList as SelectList
import Entries.Messages exposing (Msg(ApplyFilters, MDL))
import Entries.Models exposing (FilterType(..), FiltersConfig)
import Html exposing (..)
import Html.Attributes exposing (..)
import Material
import Material.Options as Options
import Material.Toggles as Toggles
import RemoteData exposing (WebData)
import Words.Models exposing (wordEmotions)


view : WebData (List Country) -> EntryVotedCountries -> FiltersConfig -> Language -> Material.Model -> Html Msg
view countries entryVotedCountries filtersConfig language mdlModel =
    div [ class "vote-filters" ]
        [ countriesSelectList countries entryVotedCountries filtersConfig language
        , togglesOfEmotions filtersConfig language mdlModel
        , translateCheckbox filtersConfig language mdlModel
        ]


countriesSelectList : WebData (List Country) -> EntryVotedCountries -> FiltersConfig -> Language -> Html Msg
countriesSelectList countries entryVotedCountries filtersConfig language =
    div [ class "vote-filters__filter -type-country" ]
        [ h4 [ class "vote-filters__filter-title" ]
            [ text <| translate language CountryText ]
        , div [ class "vote-filters__filter-select" ]
            [ SelectList.view countries entryVotedCountries filtersConfig language ]
        ]


togglesOfEmotions : FiltersConfig -> Language -> Material.Model -> Html Msg
togglesOfEmotions { emotions } language mdlModel =
    div [ class "vote-filters__filter -type-emotions" ]
        [ h4 [ class "vote-filters__filter-title" ]
            [ text <| translate language EmotionsText ]
        , div [ class "vote-filters__filter-toggles" ]
            (List.indexedMap (emotionToggle emotions language mdlModel) <| "all" :: wordEmotions)
        ]


translateCheckbox : FiltersConfig -> Language -> Material.Model -> Html Msg
translateCheckbox filtersConfig language mdlModel =
    div [ class "vote-filters__filter -type-translate" ]
        [ div [ class "vote-filters__filter-checkbox" ]
            [ Toggles.checkbox MDL
                [ 3 ]
                mdlModel
                [ Toggles.value filtersConfig.translate
                , Toggles.ripple
                , Options.onToggle <| ApplyFilters Translate
                ]
                [ text <| translate language TranslateWordsText ]
            ]
        ]


emotionToggle : Maybe String -> Language -> Material.Model -> Int -> String -> Html Msg
emotionToggle currentEmotions language mdlModel index emotion =
    let
        mdlIndex =
            index + 10

        currentEmotionsStr =
            Maybe.withDefault "all" currentEmotions

        msgParam =
            case emotion of
                "all" ->
                    Nothing

                _ ->
                    Just emotion

        emotionsText =
            case emotion of
                "positive" ->
                    PositiveText

                "neutral" ->
                    NeutralText

                "negative" ->
                    NegativeText

                _ ->
                    AllText
    in
    div [ class "vote-filters__filter-toggle" ]
        [ Toggles.radio MDL
            [ mdlIndex ]
            mdlModel
            [ Toggles.value (emotion == currentEmotionsStr)
            , Toggles.group "EmotionsRadioGroup"
            , Options.onToggle <| ApplyFilters (SelectWithEmotions msgParam)
            ]
            [ text <| translate language emotionsText ]
        ]
