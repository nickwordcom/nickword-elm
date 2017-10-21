module Entries.Partials.EmotionsDistribution exposing (view)

import App.Models exposing (RemoteData(..), WebData)
import App.Translations exposing (..)
import Countries.Models exposing (Country)
import Dict exposing (Dict)
import Entries.Models exposing (FiltersConfig)
import Html exposing (..)
import Html.Attributes exposing (..)
import List.Extra as ListEx
import Words.Models exposing (EmotionInfo)


view : Maybe (List EmotionInfo) -> FiltersConfig -> WebData (List Country) -> Language -> Html msg
view distribution filtersConfig countries language =
    case distribution of
        Just distribution ->
            div [ class "emotion-dist" ]
                [ div [ class "emotion-dist__head" ]
                    [ h3 [ class "emotion-dist__head-votes" ]
                        [ text <| votesAmountText distribution language ]
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


emptyDistribution : List EmotionInfo
emptyDistribution =
    [ { emotion = "negative", sum = 0, percent = 0 }
    , { emotion = "positive", sum = 0, percent = 0 }
    , { emotion = "neutral", sum = 0, percent = 0 }
    , { emotion = "none", sum = 0, percent = 0 }
    ]


votesFilterInfo : FiltersConfig -> WebData (List Country) -> Language -> Html msg
votesFilterInfo { country, emotions } countriesData language =
    let
        emotionsText =
            emotionsValue emotions language

        countryText =
            countryValue country countriesData

        filterPresent =
            (/=) emotionsText Nothing
                || (/=) countryText Nothing

        filterInfoText =
            [ countryText, emotionsText ]
                |> List.map (Maybe.withDefault "")
                |> List.filter (\t -> t /= "")
                |> String.join ", "
                |> addColon filterPresent
    in
    span [ class "emotion-dist__head-info mdl-color-text--grey-600" ]
        [ text filterInfoText ]


emotionsValue : Maybe String -> Language -> Maybe String
emotionsValue emotions language =
    let
        emotionsFilter =
            Maybe.withDefault "" emotions

        emotionsTranslation =
            case emotionsFilter of
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
        |> Maybe.map String.toLower


countryValue : Maybe String -> WebData (List Country) -> Maybe String
countryValue country countriesData =
    let
        selectedCountry =
            case ( countriesData, country ) of
                ( Success countries, Just countryCode ) ->
                    countries
                        |> ListEx.find (\c -> c.code == countryCode)

                ( _, _ ) ->
                    Nothing
    in
    Maybe.map (\c -> c.name) selectedCountry


addColon : Bool -> String -> String
addColon filterPresent filterValue =
    if filterPresent then
        String.append ": " filterValue
    else
        ""
