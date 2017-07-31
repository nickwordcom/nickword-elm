module Entries.Partials.EmotionsDistribution exposing (view)

import App.Translations exposing (..)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Words.Models exposing (EmotionInfo)


view : Maybe (List EmotionInfo) -> Language -> Html msg
view distribution language =
    case distribution of
        Just distribution ->
            div [ class "emotion-dist" ]
                [ h3 [ class "emotion-dist__head" ]
                    [ text <| votesAmountText distribution language ]
                , distStats language <| normalizePct distribution
                ]

        Nothing ->
            div [] []


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
    div [ class "emotion-dist__wrapper" ]
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
