module Countries.Partials.SelectList exposing (view)

import App.Translations exposing (Language, TranslationId(AllWorldText), translate)
import Countries.Models exposing (..)
import Entries.Messages exposing (Msg(ApplyFilters))
import Entries.Models exposing (FilterType(SelectFromCountry), FiltersConfig)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue)
import Json.Decode as Json
import List
import Material.Icon as Icon
import Material.Options exposing (cs)
import RemoteData exposing (RemoteData(..), WebData)
import String exposing (isEmpty, toLower)


view : WebData (List Country) -> EntryVotedCountries -> FiltersConfig -> Language -> Html Msg
view countries votedCountries { country } language =
    let
        countryCodeStr =
            Maybe.withDefault "" country
    in
    div [ class "countries-select" ]
        [ flagImg countryCodeStr
        , select
            [ on "change" (Json.map (\a -> ApplyFilters (SelectFromCountry a)) targetDecoder)
            , class "countries-select__select-tag select-tag"
            ]
            (countryOptions countries votedCountries countryCodeStr language)
        ]


countryOptions : WebData (List Country) -> EntryVotedCountries -> CountryCode -> Language -> List (Html Msg)
countryOptions countries entryVotedCountries countryCodeStr language =
    let
        allWorldOption =
            option [ value "", selected (isEmpty countryCodeStr) ]
                [ text <| translate language AllWorldText ]
    in
    case countries of
        Success countries ->
            countries
                |> filterCountries entryVotedCountries.countries
                |> List.map (selectOption countryCodeStr)
                |> (::) allWorldOption

        _ ->
            [ allWorldOption ]


selectOption : CountryCode -> Country -> Html Msg
selectOption countryCodeStr country =
    option [ value country.code, selected (country.code == countryCodeStr) ] [ text country.name ]


filterCountries : List CountryWithVotes -> List Country -> List Country
filterCountries votedCountries countries =
    if List.isEmpty votedCountries then
        countries
    else
        countries
            |> List.filterMap (filterOnlyVoted (List.map .code votedCountries))


filterOnlyVoted : List String -> Country -> Maybe Country
filterOnlyVoted votedCountries country =
    if List.member country.code votedCountries then
        Just country
    else
        Nothing


targetDecoder : Json.Decoder (Maybe String)
targetDecoder =
    targetValue
        |> Json.andThen checkTargetValue


checkTargetValue : String -> Json.Decoder (Maybe String)
checkTargetValue val =
    case isEmpty val of
        True ->
            Json.succeed Nothing

        False ->
            Json.succeed (Just val)


flagUrl : CountryCode -> String
flagUrl countryCodeStr =
    "https://flagicon.netlify.com/16/" ++ toLower countryCodeStr ++ ".png"


flagImg : CountryCode -> Html Msg
flagImg countryCodeStr =
    if isEmpty countryCodeStr then
        Icon.view "language" [ cs "countries-select__flag" ]
    else
        img [ src (flagUrl countryCodeStr), class "countries-select__flag" ] []
