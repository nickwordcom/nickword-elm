module Words.Partials.EntryWordsTab exposing (view)

-- import Html.Events exposing (onClick, onInput)

import App.Models exposing (RemoteData(..), WebData)
import App.Translations exposing (..)
import Entries.Models exposing (Entry, EntryId, FiltersConfig)
import FNV exposing (hashString)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import Material
import Material.Button as Button
import Material.Dialog as Dialog
import Material.Icon as Icon
import Material.Options as Options exposing (cs, css)
import Material.Spinner as Spinner
import String
import Svg exposing (path, svg)
import Svg.Attributes exposing (d, viewBox)
import Words.Messages exposing (Msg(..))
import Words.Models exposing (EntryVotedWords, Word, WordId, WordName)


view : Entry -> WebData (List Word) -> FiltersConfig -> WebData EntryVotedWords -> Language -> Material.Model -> Html Msg
view entry entryWords entryFilters entryVotedWords language mdlModel =
    let
        listItem maxVotes =
            wordRow entry entryVotedWords maxVotes language mdlModel

        wordsContent =
            case entryWords of
                Loading ->
                    wordsLoadingSpinner

                Failure err ->
                    div [ class "entry-words__text mdl-color-text--red-A700" ]
                        [ text <| translate language <| ErrorText (toString err) ]

                Success words ->
                    if List.isEmpty words then
                        div [ class "entry-words__text" ]
                            [ text <| translate language WordListEmptyText ]
                    else
                        div []
                            [ ol [ class "entry-words__list" ]
                                (List.map (listItem (votesMaxNumber words)) words)
                            , showMoreWordsButton words entryFilters language mdlModel
                            ]
    in
    section [ class "entry-words" ]
        [ wordsContent ]


showMoreWordsButton : List Word -> FiltersConfig -> Language -> Material.Model -> Html Msg
showMoreWordsButton words entryFilters language mdlModel =
    if entryFilters.moreWordsLoading then
        wordsLoadingSpinner
    else if List.length words == 10 && entryFilters.limit == Just 10 then
        div [ class "h-spacing-above--small h-text-center" ]
            [ Button.render MDL
                [ 2 ]
                mdlModel
                [ Button.raised
                , Button.colored
                , Options.onClick ShowMoreWords
                ]
                [ text <| translate language ShowMoreText ]
            ]
    else
        div [] []


wordRow : Entry -> WebData EntryVotedWords -> Maybe Int -> Language -> Material.Model -> Word -> Html Msg
wordRow entry entryVotedWords maxVotes language mdlModel word =
    li
        [ classList [ ( "entry-words__item", True ) ]
        , id word.id
        ]
        [ div [ class "entry-words__item-top" ]
            [ h3 [ class "entry-words__item-name h-overflow-ellipsis", title word.en ]
                [ text word.name ]
            , wordActions word entryVotedWords entry mdlModel
            ]
        , div [ class "entry-words__item-bottom h-clearfix" ]
            [ div [ class "word-progress h-float-left" ]
                [ div [ class "word-progress__background" ]
                    [ div
                        [ classList [ ( "word-progress__active", True ), ( wordEmotionType word.emotion, True ) ]
                        , style [ ( "width", calcPercent maxVotes word.votesCount ) ]
                        ]
                        []
                    ]
                ]
            , wordVotesCounter language word.votesCount
            ]
        ]


wordVotesCounter : Language -> Int -> Html Msg
wordVotesCounter language votesCount =
    let
        pluralizedText =
            NumberOfVotesText votesCount
                |> translate language
                |> String.words
                |> List.reverse
                |> List.head
                |> Maybe.withDefault ""
    in
    span [ class "entry-words__item-votes h-float-right h-overflow-ellipsis" ]
        [ b [] [ text (toString votesCount) ]
        , text " "
        , text pluralizedText
        ]


wordActions : Word -> WebData EntryVotedWords -> Entry -> Material.Model -> Html Msg
wordActions word entryVotedWords entry mdlModel =
    div [ class "entry-words__item-actions" ]
        [ voteForWordButton word entry.id entryVotedWords mdlModel
        , openShareModal entry word.name mdlModel
        ]


filterWords : List Word -> String -> List Word
filterWords words query =
    List.filter (\w -> String.contains query (String.toLower w.name)) words


votesMaxNumber : List Word -> Maybe Int
votesMaxNumber words =
    words
        |> List.take 5
        |> List.map (\w -> w.votesCount)
        |> List.maximum


calcPercent : Maybe Int -> Int -> String
calcPercent maxVotes votesCount =
    let
        pct =
            case maxVotes of
                Just max ->
                    votesCount * 100 // max

                Nothing ->
                    0
    in
    toString pct ++ "%"


wordEmotionType : String -> String
wordEmotionType emotion =
    case emotion of
        "positive" ->
            "-type-positive"

        "negative" ->
            "-type-negative"

        _ ->
            "-type-neutral"


voteForWordButton : Word -> EntryId -> WebData EntryVotedWords -> Material.Model -> Html Msg
voteForWordButton word entryId entryVotedWords mdlModel =
    let
        wordVotedBtn =
            Button.render MDL
                [ 3, hashString word.id ]
                mdlModel
                [ Button.icon
                , cs "entry-words__item-action mdl-color-text--primary-dark"
                ]
                [ Icon.i "thumb_up" ]

        wordSimpleBtn =
            Button.render MDL
                [ 4, hashString word.id ]
                mdlModel
                [ Button.icon
                , Options.onClick (VoteForWord word.id entryId)
                , cs "entry-words__item-action"
                ]
                [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "entry-words__item-action-svg" ]
                    [ Svg.path [ Svg.Attributes.d "M5,9V21H1V9H5M9,21A2,2 0 0,1 7,19V9C7,8.45 7.22,7.95 7.59,7.59L14.17,1L15.23,2.06C15.5,2.33 15.67,2.7 15.67,3.11L15.64,3.43L14.69,8H21C22.11,8 23,8.9 23,10V10.09L23,12C23,12.26 22.95,12.5 22.86,12.73L19.84,19.78C19.54,20.5 18.83,21 18,21H9M9,19H18.03L21,12V10H12.21L13.34,4.68L9,9.03V19Z" ] [] ]
                ]

        spinner =
            Spinner.spinner
                [ Spinner.active True
                , Spinner.singleColor True
                , css "vertical-align" "middle"
                , css "margin" "2px 0"
                ]
    in
    case entryVotedWords of
        Loading ->
            wordSimpleBtn

        Failure err ->
            wordSimpleBtn

        Success votedIds ->
            if List.member word.id votedIds.ids && (entryId == votedIds.entryId) then
                wordVotedBtn
            else if word.votingFor == Just True then
                spinner
            else if List.length votedIds.ids < 5 then
                wordSimpleBtn
            else
                span [] []


openShareModal : Entry -> WordName -> Material.Model -> Html Msg
openShareModal entry wordName mdlModel =
    Button.render MDL
        [ 5 ]
        mdlModel
        [ Button.icon
        , Options.onClick (UpdateShareDialogValues entry wordName)
        , Dialog.openOn "click"
        , cs "entry-words__item-action"
        ]
        [ Icon.i "share" ]


wordsLoadingSpinner : Html Msg
wordsLoadingSpinner =
    div [ class "entry-words__loading h-text-center h-spacing-above--normal" ]
        [ Spinner.spinner
            [ Spinner.active True
            , Spinner.singleColor True
            ]
        ]
