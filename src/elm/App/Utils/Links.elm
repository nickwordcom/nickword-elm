module App.Utils.Links exposing (..)

import Array exposing (fromList, get)
import Html exposing (Attribute, Html, a)
import Html.Attributes exposing (href)
import Html.Events exposing (Options, onWithOptions)
import Json.Decode as Decode
import String exposing (contains, split)


type alias Path =
    String


linkTo : Path -> msg -> List (Attribute msg) -> List (Html msg) -> Html msg
linkTo path message attrs content =
    a ([ href path, onClickPrevent message ] ++ attrs) content


onClickPrevent : msg -> Attribute msg
onClickPrevent message =
    onWithOptions "click" preventDefault (Decode.succeed message)


preventDefault : Options
preventDefault =
    { stopPropagation = True
    , preventDefault = True
    }


getLinkHostName : String -> String
getLinkHostName imageUrl =
    let
        urlArray =
            String.split "/" imageUrl
                |> Array.fromList

        host =
            if String.contains "://" imageUrl then
                Array.get 2 urlArray
            else if String.contains "//" imageUrl then
                Array.get 2 urlArray
            else
                Array.get 0 urlArray
    in
    case host of
        Just hostName ->
            hostName

        Nothing ->
            imageUrl
