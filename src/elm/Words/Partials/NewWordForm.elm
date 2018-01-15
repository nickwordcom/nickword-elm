module Words.Partials.NewWordForm exposing (..)

import App.Translations exposing (Language, TranslationId(DescribeIOWText, DescribeText, IEJustText, LoginText, NewWordFormWarning, YourWordText), translate)
import Entries.Models exposing (EntryId)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (map)
import Material exposing (Model)
import Material.Button as Button
import Material.Icon as Icon
import Material.Options as Options exposing (cs, nop, onClick)
import RemoteData exposing (RemoteData(Success), WebData)
import Users.Models exposing (UserStatus(..))
import Words.Messages exposing (Msg(AddNewWord, MDL, NoOp, SetElevation, ShowTopLoginForm, UpdateNewWordValue))
import Words.Models exposing (EntryVotedWords, Word)


addNewWordForm : String -> EntryId -> Bool -> WebData EntryVotedWords -> Maybe Word -> UserStatus -> Language -> Material.Model -> Html Msg
addNewWordForm newWordValue entryId newWordFieldActive entryVotedWords entryTopWord userStatus language mdlModel =
    let
        maxVotes =
            reachedVotesLimit entryId entryVotedWords

        showShadow =
            if maxVotes then
                False
            else
                not newWordFieldActive

        inputFieldClasses =
            classList
                [ ( "new-word-field__input-field", True )
                , ( "mdl-shadow--4dp", newWordFieldActive )
                , ( "mdl-shadow--2dp", showShadow )
                , ( "h-cursor-default", maxVotes )
                ]

        addNewWordMsg =
            if maxVotes then
                NoOp
            else
                AddNewWord newWordValue entryId
    in
    section [ class "new-word-field" ]
        [ div [ class "new-word-field__wrapper" ]
            [ div [ class "new-word-field__input-block" ]
                [ input
                    [ id "new-word-field"
                    , inputFieldClasses
                    , onInput UpdateNewWordValue
                    , onEnter addNewWordMsg
                    , onFocus (SetElevation True)
                    , onBlur (SetElevation False)
                    , value newWordValue
                    , type_ "text"
                    , placeholder <| translate language DescribeIOWText
                    , disabled maxVotes
                    ]
                    []
                ]
            , label [ for "new-word-field", class "new-word-field__input-icon mdl-color-text--grey-600" ]
                [ Icon.i "record_voice_over" ]
            , Button.render MDL
                [ 1 ]
                mdlModel
                [ Button.fab
                , Button.ripple
                , Button.colored
                , if maxVotes then
                    Button.disabled
                  else
                    nop
                , Options.onClick addNewWordMsg
                , cs "new-word-field__button-add"
                ]
                [ Icon.i "add" ]
            ]
        , newWordDescription newWordFieldActive entryTopWord userStatus language
        ]


newWordDescription : Bool -> Maybe Word -> UserStatus -> Language -> Html Msg
newWordDescription newWordFieldActive entryTopWord userStatus language =
    case ( userStatus, entryTopWord ) of
        ( Unknown, _ ) ->
            span
                [ classList
                    [ ( "new-word-field__description", True )
                    , ( "-type-warning", newWordFieldActive )
                    ]
                ]
                [ text <| translate language NewWordFormWarning
                , text ". "
                , span
                    [ class "new-word-field__login-text mdl-color-text--primary h-clickable"
                    , Html.Events.onClick ShowTopLoginForm
                    ]
                    [ text <| translate language LoginText ]
                ]

        ( Active, Just word ) ->
            span [ class "new-word-field__description" ]
                [ text <| translate language IEJustText
                , span [ class "new-word-field__description-word" ]
                    [ text word.name ]
                ]

        _ ->
            text ""


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        tagger code =
            if code == 13 then
                msg
            else
                NoOp
    in
    on "keydown" (Json.map tagger keyCode)


reachedVotesLimit : EntryId -> WebData EntryVotedWords -> Bool
reachedVotesLimit entryId entryVotedWords =
    case entryVotedWords of
        Success votedIds ->
            if (entryId == votedIds.entryId) && (List.length votedIds.ids >= 5) then
                True
            else
                False

        _ ->
            False
