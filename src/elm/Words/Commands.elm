module Words.Commands exposing (..)

import App.Utils.Config exposing (apiUrl)
import App.Utils.Converters exposing (fromResult)
import App.Utils.Requests exposing (encodeUrl, getWithAuth, postWithAuth)
import Entries.Models exposing (EntryId, FiltersConfig)
import Http
import Json.Decode as Decode exposing (field)
import Json.Encode as Encode
import Users.Models exposing (UserToken)
import Words.Messages exposing (..)
import Words.Models exposing (..)


-- HTTP Requests


fetchEntryWords : EntryId -> FiltersConfig -> Cmd Msg
fetchEntryWords entryId filtersConfig =
    Http.get (entryWordsUrl entryId filtersConfig) wordsResponseDecoder
        |> Http.send (EntryWordsResponse << fromResult)


fetchEntryVotedWords : EntryId -> UserToken -> Cmd Msg
fetchEntryVotedWords entryId token =
    getWithAuth (entryVotedWordsUrl entryId) entryVotedWordsDecoder token
        |> Http.send (EntryVotedWordsResponse << fromResult)


addNewWord : WordName -> EntryId -> UserToken -> Cmd Msg
addNewWord wordName entryId token =
    postWithAuth (entryWordsUrlPOST entryId) (newWordEncoded wordName) wordSingleDecoder token
        |> Http.send AddNewWordData



-- URLs


entryWordsUrl : EntryId -> FiltersConfig -> String
entryWordsUrl entryId { country, emotions, limit } =
    let
        baseUrl =
            apiUrl ++ "/entries/" ++ entryId ++ "/words"

        countryParam =
            case country of
                Just code ->
                    ( "country", code )

                Nothing ->
                    ( "", "" )

        emotionsParam =
            case emotions of
                Just emotion ->
                    ( "emotions", emotion )

                Nothing ->
                    ( "", "" )

        limitParam =
            case limit of
                Just number ->
                    ( "limit", toString number )

                Nothing ->
                    ( "", "" )

        params =
            [ countryParam, emotionsParam, limitParam ]
                |> List.filter (\p -> p /= ( "", "" ))
    in
    encodeUrl baseUrl params


entryWordsUrlPOST : EntryId -> String
entryWordsUrlPOST entryId =
    apiUrl ++ "/p/entries/" ++ entryId ++ "/words"


entryVotedWordsUrl : EntryId -> String
entryVotedWordsUrl entryId =
    apiUrl ++ "/entries/" ++ entryId ++ "/words/voted"



-- DECODERS


wordsResponseDecoder : Decode.Decoder WordsResponse
wordsResponseDecoder =
    Decode.map2 WordsResponse
        (field "data" (Decode.list wordDecoder))
        (field "distribution" (Decode.list emotionInfoDecoder))


wordSingleDecoder : Decode.Decoder Word
wordSingleDecoder =
    Decode.map identity
        (field "data" wordDecoder)


wordDecoder : Decode.Decoder Word
wordDecoder =
    Decode.map7 Word
        (field "id" Decode.string)
        (field "name" Decode.string)
        (field "en" Decode.string)
        (field "lang" Decode.string)
        (field "emotion" Decode.string)
        (field "votes_count" Decode.int)
        (Decode.maybe (field "status" Decode.bool))


emotionInfoDecoder : Decode.Decoder EmotionInfo
emotionInfoDecoder =
    Decode.map3 EmotionInfo
        (field "emotion" Decode.string)
        (field "sum" Decode.int)
        (field "pct" Decode.float)


entryVotedWordsDecoder : Decode.Decoder EntryVotedWords
entryVotedWordsDecoder =
    Decode.map identity
        (field "data" votedWordsDecoder)


votedWordsDecoder : Decode.Decoder EntryVotedWords
votedWordsDecoder =
    Decode.map2 EntryVotedWords
        (field "entry_id" Decode.string)
        (field "ids" (Decode.list Decode.string))



-- ENCODERS


newWordEncoded : WordName -> Encode.Value
newWordEncoded wordName =
    let
        newWord =
            [ ( "name", Encode.string wordName ) ]
    in
    Encode.object [ ( "word", Encode.object newWord ) ]