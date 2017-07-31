module Users.Commands exposing (..)

import App.Messages exposing (Msg(UserAuthorization))
import App.Utils.Config exposing (apiUrl)
import App.Utils.Requests exposing (postWithAuth)
import Http
import Json.Decode as Decode exposing (field)
import Json.Encode as Encode
import OAuth.Config exposing (OAuthResponse)


-- HTTP Requests


authorizeUser : OAuthResponse -> Cmd Msg
authorizeUser oauthResponse =
    postWithAuth usersUrl (tokenEncoded oauthResponse) tokenStringDecoder ""
        |> Http.send UserAuthorization



-- URLs


usersUrl : String
usersUrl =
    apiUrl ++ "/users"



-- Decoders


tokenStringDecoder : Decode.Decoder String
tokenStringDecoder =
    Decode.map identity
        (field "jwt" Decode.string)



-- ENCODERS


tokenEncoded : OAuthResponse -> Encode.Value
tokenEncoded oauthResponse =
    let
        tokenData =
            [ ( "token", Encode.string oauthResponse.token )
            , ( "provider", Encode.string oauthResponse.provider )
            ]
    in
    Encode.object [ ( "token_data", Encode.object tokenData ) ]
