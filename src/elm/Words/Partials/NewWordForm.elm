module Words.Partials.NewWordForm exposing (..)

import App.Models exposing (RemoteData(Success), WebData)
import App.Translations exposing (Language, TranslationId(DescribeIOWText, DescribeText, IEJustText, NewWordFormWarning, YourWordText), translate)
import Entries.Models exposing (EntryId)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json exposing (map)
import Material exposing (Model)
import Material.Button as Button
import Material.Options as Options exposing (cs, nop, onClick)
import Users.Models exposing (UserStatus(..))
import Words.Messages exposing (Msg(AddNewWord, MDL, NoOp, SetElevation, UpdateNewWordValue))
import Words.Models exposing (EntryVotedWords, Word)


addNewWordForm : String -> EntryId -> Bool -> WebData EntryVotedWords -> Maybe Word -> UserStatus -> Language -> Material.Model -> Html Msg
addNewWordForm newWordValue entryId newWordFieldActive entryVotedWords entryTopWord userStatus language mdlModel =
    let
        inputBlockClasses =
            classList
                [ ( "new-word-field__wrapper", True )
                , ( "mdl-shadow--4dp", newWordFieldActive )
                , ( "mdl-shadow--2dp", not newWordFieldActive )
                ]

        maxVotes =
            reachedVotesLimit entryId entryVotedWords

        addNewWordMsg =
            if maxVotes then
                NoOp
            else
                AddNewWord newWordValue entryId
    in
    section [ class "new-word-field" ]
        [ label [ for "new-word-field", class "new-word-field__label" ]
            [ text <| translate language DescribeIOWText ]
        , div [ inputBlockClasses ]
            [ input
                [ class "new-word-field__input"
                , id "new-word-field"
                , onInput UpdateNewWordValue
                , onEnter addNewWordMsg
                , onFocus (SetElevation True)
                , onBlur (SetElevation False)
                , value newWordValue
                , type_ "text"
                , placeholder <| translate language YourWordText
                , disabled maxVotes
                ]
                []
            , Button.render MDL
                [ 1 ]
                mdlModel
                [ Button.raised
                , Button.colored
                , if maxVotes then
                    Button.disabled
                  else
                    nop
                , Options.onClick addNewWordMsg
                , cs "new-word-field__add-btn"
                ]
                [ text <| translate language DescribeText ]
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
                [ text <| translate language NewWordFormWarning ]

        ( Active, Just word ) ->
            span [ class "new-word-field__description" ]
                [ text <| translate language IEJustText
                , span [ class "new-word-field__description-word" ]
                    [ text word.name ]
                ]

        _ ->
            span [ class "new-word-field__description" ] []


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
