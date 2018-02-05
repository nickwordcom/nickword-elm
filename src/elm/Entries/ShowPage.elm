module Entries.ShowPage exposing (..)

import App.Models exposing (Model)
import App.Translations exposing (Language, TranslationId(ErrorText, LoadingText), translate)
import Entries.Messages exposing (Msg(WordsMsg))
import Entries.Models exposing (Entry, EntryTab(..), FiltersConfig)
import Entries.Partials.EmotionsDistribution as EmotionsDistribution
import Entries.Partials.EntryInfo exposing (entryInfo)
import Entries.Partials.EntrySidebar as EntrySidebar
import Entries.Partials.EntryTabs as EntryTabs
import Entries.Partials.FiltersCollapse as FiltersCollapse
import Entries.Partials.TrendingEntriesBlock as TrendingEntriesBlock
import Html exposing (..)
import Html.Attributes exposing (..)
import Material
import Material.Options exposing (css)
import Material.Spinner as Spinner
import RemoteData exposing (RemoteData(..), WebData)
import Votes.Partials.EntryVotesMapTab as EntryVotesMapTab
import Words.Models exposing (EntryVotedWords, Word)
import Words.Partials.EntryWordsCloudTab as EntryWordsCloudTab
import Words.Partials.EntryWordsTab as EntryWordsTab


view : Model -> Html Msg
view model =
    case model.entry of
        NotAsked ->
            entryLoadingSpinner

        Loading ->
            entryLoadingSpinner

        Failure err ->
            entryFailure <| translate model.appLanguage (ErrorText (toString err))

        Success entry ->
            div []
                [ entryPageBlock entry model
                , div [ class "entries-grid" ]
                    [ TrendingEntriesBlock.view model.popularEntries model.appLanguage ]
                ]


entryPageBlock : Entry -> Model -> Html Msg
entryPageBlock entry { entryWords, entryTopWord, entryFilters, newWordValue, popularEntries, newWordFieldActive, user, entryVotedCountries, entryTab, entryVotedWords, categories, countries, entryEmotionsInfo, appLanguage, mdl } =
    div [ class "entry-page" ]
        [ div [ class "entry-page__wrapper mdl-shadow--2dp" ]
            [ entryInfo entry entryVotedWords entryTopWord newWordValue newWordFieldActive categories user.status appLanguage mdl
            , div [ class "entry-page__entry-sidebar" ]
                [ EntrySidebar.view countries entryVotedCountries entryFilters appLanguage mdl ]
            , div [ class "entry-page__entry-content" ]
                [ div [ class "entry-page__entry-tabs" ]
                    [ EntryTabs.view entryTab appLanguage mdl ]
                , div [ class "entry-page__entry-filters-collapse" ]
                    [ FiltersCollapse.view countries entryVotedCountries entryFilters appLanguage mdl ]
                , div [ class "entry-page__emotion-dist" ]
                    [ EmotionsDistribution.view entryEmotionsInfo entryFilters countries appLanguage ]
                , currentEntryTab entry entryTab entryWords entryFilters entryVotedWords appLanguage mdl
                ]
            ]
        ]


currentEntryTab : Entry -> EntryTab -> WebData (List Word) -> FiltersConfig -> WebData EntryVotedWords -> Language -> Material.Model -> Html Msg
currentEntryTab entry entryTab entryWords entryFilters entryVotedWords appLanguage mdl =
    case entryTab of
        WordList ->
            EntryWordsTab.view entry entryWords entryFilters entryVotedWords appLanguage mdl
                |> Html.map WordsMsg

        WordCloud ->
            EntryWordsCloudTab.view entryWords appLanguage

        VotesMap ->
            EntryVotesMapTab.view

        VotesList ->
            text "EntryVotesTab.votesList entryVotes appLanguage"


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
