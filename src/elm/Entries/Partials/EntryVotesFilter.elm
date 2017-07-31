module Entries.Partials.EntryVotesFilter exposing (view)

import App.Models exposing (WebData)
import App.Translations exposing (..)
import Countries.Models exposing (..)
import Countries.Partials.SelectList as SelectList
import Entries.Messages exposing (Msg)
import Html exposing (..)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import String exposing (isEmpty, toLower)


type alias EntryVotesCount =
    Int


type alias CountryVotesCount =
    Int


view : Maybe CountryCode -> WebData (List Country) -> EntryVotedCountries -> EntryVotesCount -> Maybe CountryVotesCount -> Language -> Bool -> Html Msg
view selectedCountryCode countries entryVotedCountries entryVotesCount countryVotesCount language isVotesTab =
    let
        countryCodeStr =
            withDefault "" selectedCountryCode
    in
    div [ class "entry-page__votes-filter" ]
        [ div [ class "votes-filter" ]
            [ span [ class "votes-filter__label" ]
                [ text <| translate language IncludeVotesFromText ]
            , div [ class "votes-filter__select-wrapper" ]
                [ SelectList.view countries entryVotedCountries countryCodeStr language ]
            , countryVotesCountTag entryVotesCount countryVotesCount countryCodeStr isVotesTab language
            ]
        ]


countryVotesCountTag : EntryVotesCount -> Maybe CountryVotesCount -> String -> Bool -> Language -> Html Msg
countryVotesCountTag entryVotesCount countryVotesCount countryCodeStr isVotesTab language =
    let
        numberOfVotes =
            Maybe.withDefault 0 countryVotesCount

        ( primaryText, secondaryText ) =
            if numberOfVotes == 0 || entryVotesCount == 0 then
                ( ""
                , translate language NoVotesText
                )
            else if isVotesTab && (numberOfVotes == 100 || entryVotesCount == 100) then
                ( translate language <| LatestHundredText
                , ""
                )
            else if isEmpty countryCodeStr then
                ( toString numberOfVotes
                , ""
                )
            else
                ( toString numberOfVotes
                , translate language <| NVotesFromText (toString entryVotesCount)
                )
    in
    case countryVotesCount of
        Just number ->
            span [ class "votes-filter__votes-count" ]
                [ b [] [ text primaryText ]
                , text secondaryText
                ]

        Nothing ->
            span [] []
