module OAuth.Config exposing (..)

import App.Routing exposing (Route(OAuthCallbackRoute), routeToPath)
import App.Utils.Config exposing (rootUrl)
import App.Utils.Requests exposing (encodeUrl)
import String exposing (join)


type alias OAuthConfig =
    { authServerUrl : String
    , redirect_uri : String
    , clientId : String
    , scopes : List String
    , state : String
    }


type alias OAuthResponse =
    { provider : String
    , token : String
    , state : String
    }


facebookAuthClient : String -> OAuthConfig
facebookAuthClient state =
    { authServerUrl = "https://www.facebook.com/v2.8/dialog/oauth"
    , redirect_uri = rootUrl ++ routeToPath (OAuthCallbackRoute "facebook")
    , clientId = "1615182685453505"
    , scopes = [ "public_profile" ]
    , state = state
    }


googleAuthClient : String -> OAuthConfig
googleAuthClient state =
    { authServerUrl = "https://accounts.google.com/o/oauth2/v2/auth"
    , redirect_uri = rootUrl ++ routeToPath (OAuthCallbackRoute "google")
    , clientId = "63322969080-et4f1k6cp8b00arjkgja36vuj90qiai7.apps.googleusercontent.com"
    , scopes = [ "profile" ]
    , state = state
    }


vkAuthClient : String -> OAuthConfig
vkAuthClient state =
    { authServerUrl = "https://oauth.vk.com/authorize"
    , redirect_uri = rootUrl ++ routeToPath (OAuthCallbackRoute "vk")
    , clientId = "5762902"
    , scopes = [ "offline" ]
    , state = state
    }


buildAuthUrl : OAuthConfig -> String
buildAuthUrl config =
    encodeUrl
        config.authServerUrl
        [ ( "client_id", config.clientId )
        , ( "redirect_uri", config.redirect_uri )
        , ( "response_type", "token" )
        , ( "scope", join " " config.scopes )
        , ( "state", config.state )
        ]
