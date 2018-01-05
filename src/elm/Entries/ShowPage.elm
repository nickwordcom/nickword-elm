module Entries.ShowPage exposing (..)

import App.Models exposing (Model)
import App.Routing exposing (Route(EntryCloudRoute, EntryMapRoute, EntryRoute, EntryVotesRoute))
import App.Translations exposing (Language, TranslationId(ErrorText, LoadingText), translate)
import Entries.Messages exposing (Msg(WordsMsg))
import Entries.Partials.EmotionsDistribution as EmotionsDistribution
import Entries.Partials.EntryInfo exposing (entryInfo)
import Entries.Partials.EntryPrefetched as EntryPrefetched
import Entries.Partials.EntrySidebar as EntrySidebar
import Entries.Partials.EntryTabs as EntryTabs
import Entries.Partials.FiltersCollapse as FiltersCollapse
import Entries.Partials.TrendingEntriesBlock as TrendingEntriesBlock
import Html exposing (..)
import Html.Attributes exposing (..)
import Maps.EntryVotesMapTab as EntryVotesMapTab
import Material.Options exposing (css)
import Material.Spinner as Spinner
import RemoteData exposing (RemoteData(..))
import Votes.Partials.EntryVotesTab as EntryVotesTab
import Words.Partials.EntryWordsCloudTab as EntryWordsCloudTab
import Words.Partials.EntryWordsTab as EntryWordsTab


view : Model -> Html Msg
view { entry, entryPrefetched, entryWords, entryTopWord, entryVotes, entryVotesSlim, entryFilters, wordSearchValue, newWordValue, popularEntries, newWordFieldActive, user, entryVotedCountries, entryTabIndex, entryVotedWords, categories, countries, entryEmotionsInfo, route, appLanguage, mdl } =
    case entry of
        NotAsked ->
            entryLoadingSpinner

        Loading ->
            case entryPrefetched of
                Just entry ->
                    EntryPrefetched.view entry categories appLanguage

                Nothing ->
                    entryLoadingSpinner

        Failure err ->
            entryFailure <| translate appLanguage (ErrorText (toString err))

        Success entry ->
            let
                currentPageTab =
                    case route of
                        EntryRoute _ _ ->
                            EntryWordsTab.view entry entryWords entryFilters entryVotedWords appLanguage mdl
                                |> Html.map WordsMsg

                        EntryCloudRoute _ _ ->
                            EntryWordsCloudTab.view entryWords appLanguage

                        EntryMapRoute _ _ ->
                            EntryVotesMapTab.view

                        EntryVotesRoute _ _ ->
                            EntryVotesTab.votesList entryVotes appLanguage

                        _ ->
                            div [] []
            in
            div []
                [ div [ class "entry-page" ]
                    [ div [ class "entry-page__wrapper mdl-shadow--2dp" ]
                        [ entryInfo entry entryVotedWords entryTopWord newWordValue newWordFieldActive categories user.status appLanguage mdl
                        , div [ class "entry-page__entry-sidebar" ]
                            [ EntrySidebar.view countries entryVotedCountries entryFilters appLanguage mdl ]
                        , div [ class "entry-page__entry-content" ]
                            [ div [ class "entry-page__entry-tabs" ]
                                [ EntryTabs.view entry.id entry.slug entryTabIndex appLanguage mdl ]
                            , div [ class "entry-page__entry-filters-collapse" ]
                                [ FiltersCollapse.view countries entryVotedCountries entryFilters appLanguage mdl ]
                            , div [ class "entry-page__emotion-dist" ]
                                [ EmotionsDistribution.view entryEmotionsInfo entryFilters countries appLanguage ]
                            , currentPageTab
                            ]
                        ]
                    ]
                , div [ class "entries-grid" ]
                    [ TrendingEntriesBlock.view popularEntries appLanguage ]
                ]


entryLoadingSpinner : Html a
entryLoadingSpinner =
    div [ class "entry-page h-full-height" ]
        [ div [ class "entry-page__wrapper mdl-shadow--2dp overflow-auto" ]
            [ div [ class "entry-page__loading" ]
                [ Spinner.spinner
                    [ Spinner.active True
                    , Spinner.singleColor True
                    , css "vertical-align" "middle"
                    , css "margin" "2px 0"
                    ]
                ]
            ]
        ]


entryFailure : String -> Html Msg
entryFailure errorText =
    div [ class "entry-page h-full-height" ]
        [ div [ class "entry-page__wrapper mdl-shadow--2dp" ]
            [ text errorText ]
        ]
