module App.Utils.Requests exposing (..)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value, encode)
import String exposing (join)
import Users.Models exposing (UserToken)


postWithAuth : String -> Encode.Value -> Decoder value -> UserToken -> Http.Request value
postWithAuth url json decoder token =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = url
        , body = Http.jsonBody json
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


getWithAuth : String -> Decode.Decoder a -> UserToken -> Http.Request a
getWithAuth url decoder token =
    Http.request
        { method = "GET"
        , headers = [ Http.header "Authorization" ("Bearer " ++ token) ]
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


{-| Create a properly encoded URL with a [query string][qs].
encodeUrl "<http://example.com/users"> [ ("name", "john doe"), ("age", "30") ]
-- <http://example.com/users?name=john+doe&age=30>
-}
encodeUrl : String -> List ( String, String ) -> String
encodeUrl baseUrl args =
    case args of
        [] ->
            baseUrl

        _ ->
            baseUrl ++ "?" ++ String.join "&" (List.map queryPair args)


queryPair : ( String, String ) -> String
queryPair ( key, value ) =
    Http.encodeUri key ++ "=" ++ Http.encodeUri value
