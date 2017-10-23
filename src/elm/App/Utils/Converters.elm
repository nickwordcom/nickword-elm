module App.Utils.Converters exposing (..)

import App.Models exposing (RemoteData(..), WebData)
import App.Translations exposing (Language(..), TranslationId(VotesAmountK), translate)
import List
import Result
import String
import Votes.Models exposing (Vote, VoteSlim)
import Words.Models exposing (EmotionInfo, Word)


determineLanguage : Maybe String -> Language
determineLanguage maybeLanguage =
    let
        language =
            Maybe.withDefault "English" maybeLanguage
    in
    case language of
        "Ukrainian" ->
            Ukrainian

        "Russian" ->
            Russian

        "Spanish" ->
            Spanish

        _ ->
            English



-- Convert votes number to string with suffix 'K' if n >= 1000


convertVotes : Int -> Language -> String
convertVotes votes language =
    if votes > 999 then
        let
            votesString =
                toString (toFloat votes / 1000)

            -- "216.432"
            dotIndex =
                String.indexes "." votesString

            -- [3] : List Int
            maybeDot =
                List.head dotIndex

            -- Just 3 : Maybe.Maybe Int
            newVotes =
                case maybeDot of
                    Just n ->
                        votesString
                            |> String.toList
                            |> List.take (n + 2)
                            |> String.fromList

                    Nothing ->
                        votesString

            votesStr =
                if String.endsWith "0" newVotes then
                    String.dropRight 2 newVotes
                else
                    newVotes
        in
        translate language <| VotesAmountK votesStr
    else
        toString votes


wordsVotesCount : WebData (List Word) -> Maybe Int
wordsVotesCount words =
    case words of
        Loading ->
            Nothing

        Failure err ->
            Nothing

        Success words ->
            words
                |> List.map (\w -> w.votesCount)
                |> List.sum
                |> Just


votesSize : WebData (List Vote) -> Maybe Int
votesSize votes =
    case votes of
        Loading ->
            Nothing

        Failure err ->
            Nothing

        Success votes ->
            votes
                |> List.length
                |> Just


votesSlimSize : WebData (List VoteSlim) -> Maybe Int
votesSlimSize votes =
    case votes of
        Loading ->
            Nothing

        Failure err ->
            Nothing

        Success votes ->
            votes
                |> List.length
                |> Just


increaseEntryEmotions : Word -> List EmotionInfo -> List EmotionInfo
increaseEntryEmotions word entryEmotions =
    let
        votesAmount =
            entryEmotions
                |> List.map (\e -> e.sum)
                |> List.foldr (+) 1
    in
    entryEmotions
        |> List.map (increaseEmotionSum word)
        |> List.map (recalculateEmotionPct votesAmount)


increaseEmotionSum : Word -> EmotionInfo -> EmotionInfo
increaseEmotionSum word emotionInfo =
    if emotionInfo.emotion == word.emotion then
        { emotionInfo | sum = emotionInfo.sum + 1 }
    else
        emotionInfo


recalculateEmotionPct : Int -> EmotionInfo -> EmotionInfo
recalculateEmotionPct votesAmount emotionInfo =
    let
        newPct =
            toFloat (emotionInfo.sum * 100) / toFloat votesAmount
    in
    { emotionInfo | percent = newPct }


{-| Convert a `Result Error`, probably produced from elm-http, to a RemoteData value.
-}
fromResult : Result e a -> RemoteData e a
fromResult result =
    case result of
        Err e ->
            Failure e

        Ok x ->
            Success x



{--
  import Time exposing (Time, second)
  import Date exposing (Date)
  import Date.Extra exposing (diff, Interval(..))

  Convert Date from String to "Time ago"
--}
-- dateToAgo : String -> Time -> String
-- dateToAgo dateStr currentTime =
--   let
--     timeAgo =
--       case Date.fromString dateStr of
--         Ok pastDate ->
--           toRelTime (Date.fromTime currentTime) pastDate
--         Err error ->
--           ""
--   in
--     timeAgo
--
--
-- -- Convert Date to "Time ago"
--
-- toRelTime : Date -> Date -> String
-- toRelTime curDate prevDate =
--   let
--     diffMinute =
--       diff Minute prevDate curDate
--     diffHour =
--       diff Hour prevDate curDate
--     diffDay =
--       diff Day prevDate curDate
--     diffMonth =
--       diff Month prevDate curDate
--     diffYear =
--       diff Year prevDate curDate
--     sDiff =
--       if diffMinute == 1 then
--           "a minute"
--       else if diffMinute < 2 then
--           "2 minutes"
--       else if diffHour < 2 then
--           (toString diffMinute) ++ " minutes"
--       else if diffDay < 2 then
--           (toString diffHour) ++ " hours"
--       else if diffMonth < 2 then
--           (toString diffDay) ++ " days"
--       else if diffYear < 2 then
--           (toString diffMonth) ++ " months"
--       else
--           (toString diffYear) ++ " years"
--     suffixAgo = "ago"
--   in
--     sDiff ++ " " ++ suffixAgo