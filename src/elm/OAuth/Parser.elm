module OAuth.Parser exposing (getFieldFromHash)

import Dict
import String


{- getFieldFromHash based on elm-oauth heplers
   https://github.com/tiziano88/elm-oauth/blob/master/src/OAuth.elm#L129
-}


getFieldFromHash : String -> String -> String
getFieldFromHash hash fieldName =
    case String.indexes (fieldName ++ "=") hash of
        [ n ] ->
            String.dropLeft n hash
                |> parseUrlParams
                |> Dict.get fieldName
                |> Maybe.withDefault ""

        [] ->
            ""

        _ :: rest ->
            ""


parseUrlParams : String -> Dict.Dict String String
parseUrlParams params =
    params
        |> String.split "&"
        |> List.map parseSingleParam
        |> Dict.fromList


parseSingleParam : String -> ( String, String )
parseSingleParam p =
    let
        s =
            String.split "=" p
    in
    case s of
        [ s1, s2 ] ->
            ( s1, s2 )

        _ ->
            ( "", "" )
