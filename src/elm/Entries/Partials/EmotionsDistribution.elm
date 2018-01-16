module Entries.Partials.EmotionsDistribution exposing (view)

import App.Translations exposing (..)
import Countries.Models exposing (Country)
import Dict exposing (Dict)
import Entries.Messages exposing (Msg(ApplyFilters))
import Entries.Models exposing (FilterType(..), FiltersConfig)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra as ListEx
import Material.Chip as Chip
import Material.Color as Color
import Material.Options as Options
import RemoteData exposing (RemoteData(..), WebData)
import Words.Models exposing (EmotionInfo)


view : Maybe (List EmotionInfo) -> FiltersConfig -> WebData (List Country) -> Language -> Html Msg
view distribution filtersConfig countries language =
    case distribution of
        Just distribution ->
            div [ class "emotion-dist" ]
                [ div [ class "emotion-dist__head" ]
                    [ votesAmountChip distribution language
                    , votesFilterInfo filtersConfig countries language
                    ]
                , distStats language <| normalizePct distribution
                ]

        Nothing ->
            div [ class "emotion-dist" ]
                [ h3 [ class "emotion-dist__head emotion-dist__head--placeholder" ] []
                , distStats language <| normalizePct emptyDistribution
                ]


distStats : Language -> Dict String String -> Html msg
distStats language emotionsPct =
    let
        positivePct =
            Dict.get "positive" emotionsPct |> Maybe.withDefault "0"

        neutralPct =
            Dict.get "neutral" emotionsPct |> Maybe.withDefault "0"

        negativePct =
            Dict.get "negative" emotionsPct |> Maybe.withDefault "0"
    in
    div [ class "emotion-dist__data" ]
        [ div [ class "emotion-dist__stats" ]
            [ div [ class "emotion-dist__stats-item" ]
                [ span [ class "emotion-dist__stats-item-color -type-positive" ] []
                , span [ class "emotion-dist__stats-item-pct" ]
                    [ text <| pctSign <| roundPct positivePct ]
                , span [ class "emotion-dist__stats-item-name" ]
                    [ text <| translate language PositiveText ]
                ]
            , div [ class "emotion-dist__stats-item" ]
                [ span [ class "emotion-dist__stats-item-color -type-neutral" ] []
                , span [ class "emotion-dist__stats-item-pct" ]
                    [ text <| pctSign <| roundPct neutralPct ]
                , span [ class "emotion-dist__stats-item-name" ]
                    [ text <| translate language NeutralText ]
                ]
            , div [ class "emotion-dist__stats-item" ]
                [ span [ class "emotion-dist__stats-item-color -type-negative" ] []
                , span [ class "emotion-dist__stats-item-pct" ]
                    [ text <| pctSign <| roundPct negativePct ]
                , span [ class "emotion-dist__stats-item-name" ]
                    [ text <| translate language NegativeText ]
                ]
            ]
        , div [ class "emotion-dist__progress" ]
            [ span [ class "emotion-dist__progress-item -type-positive", style [ ( "width", pctSign positivePct ) ] ] []
            , span [ class "emotion-dist__progress-item -type-neutral", style [ ( "width", pctSign neutralPct ) ] ] []
            , span [ class "emotion-dist__progress-item -type-negative", style [ ( "width", pctSign negativePct ) ] ] []
            ]
        ]


normalizePct : List EmotionInfo -> Dict String String
normalizePct distribution =
    let
        distributionDict =
            distribution
                |> List.map (\e -> ( e.emotion, e.percent ))
                |> Dict.fromList

        addValueFrom from value =
            Maybe.map2 (+) value (Dict.get from distributionDict)
    in
    distributionDict
        |> Dict.update "neutral" (addValueFrom "none")
        |> Dict.map (\k v -> toString v)


roundPct : String -> String
roundPct pct =
    pct
        |> String.toFloat
        |> Result.withDefault 0
        |> round
        |> toString


votesAmountChip : List EmotionInfo -> Language -> Html Msg
votesAmountChip distribution language =
    Chip.span
        [ Color.background Color.primary
        , Color.text Color.white
        ]
        [ Chip.content
            [ Options.css "font-size" "14px"
            , Options.css "font-weight" "500"
            ]
            [ text <| votesAmountText distribution language ]
        ]


votesAmountText : List EmotionInfo -> Language -> String
votesAmountText distribution language =
    let
        votesSum =
            distribution
                |> List.map (\e -> e.sum)
                |> List.sum
    in
    translate language (NumberOfVotesText votesSum)


pctSign : String -> String
pctSign pct =
    pct ++ "%"


emptyDistribution : List EmotionInfo
emptyDistribution =
    [ { emotion = "negative", sum = 0, percent = 0 }
    , { emotion = "positive", sum = 0, percent = 0 }
    , { emotion = "neutral", sum = 0, percent = 0 }
    , { emotion = "none", sum = 0, percent = 0 }
    ]


votesFilterInfo : FiltersConfig -> WebData (List Country) -> Language -> Html Msg
votesFilterInfo { country, emotions } countriesData language =
    span [ class "emotion-dist__head-filters" ]
        [ countryFilterChip country countriesData
        , emotionsFilterChip emotions language
        ]


countryFilterChip : Maybe String -> WebData (List Country) -> Html Msg
countryFilterChip country countriesData =
    case country of
        Just country_ ->
            ApplyFilters (SelectFromCountry Nothing)
                |> filterChip (countryValue country_ countriesData)

        Nothing ->
            text ""


emotionsFilterChip : Maybe String -> Language -> Html Msg
emotionsFilterChip emotions language =
    case emotions of
        Just emotions_ ->
            ApplyFilters (SelectWithEmotions Nothing)
                |> filterChip (emotionsValue emotions_ language)

        Nothing ->
            text ""


filterChip : String -> Msg -> Html Msg
filterChip filterText filterMsg =
    Chip.span
        [ Chip.deleteIcon "cancel"
        , Chip.deleteClick filterMsg
        ]
        [ Chip.text [] filterText ]


emotionsValue : String -> Language -> String
emotionsValue emotions language =
    let
        emotionsTranslation =
            case emotions of
                "positive" ->
                    Just PositiveText

                "neutral" ->
                    Just NeutralText

                "negative" ->
                    Just NegativeText

                _ ->
                    Nothing
    in
    emotionsTranslation
        |> Maybe.map (\t -> translate language t)
        |> Maybe.withDefault ""
        |> String.toLower


countryValue : String -> WebData (List Country) -> String
countryValue country countriesData =
    case countriesData of
        Success countries ->
            countries
                |> ListEx.find (\c -> c.code == country)
                |> Maybe.andThen (\c -> Just c.name)
                |> Maybe.withDefault ""

        _ ->
            ""
