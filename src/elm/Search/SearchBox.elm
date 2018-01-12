module Search.SearchBox exposing (searchBox)

import App.Messages exposing (Msg(ClearSearchField, NoOp, SearchEntries, UpdateSearchField))
import App.Translations exposing (..)
import Html exposing (Attribute, Html, input, label, text)
import Html.Attributes exposing (class, for, id, placeholder, type_, value)
import Html.Events exposing (keyCode, on, onInput)
import Json.Decode as Json exposing (map)
import Material.Icon as Icon
import Material.Layout exposing (link)
import Material.Options as Options exposing (cs, css, div, nop, span)
import String exposing (length)


searchBox : Bool -> String -> Language -> Html Msg
searchBox searchOpen searchInputValue language =
    let
        clearIcon =
            if length searchInputValue > 0 then
                link
                    [ cs "searchbox__clear-icon h-clickable"
                    , Options.onClick ClearSearchField
                    ]
                    [ Icon.i "clear" ]
            else
                span [] []
    in
    div
        [ cs "searchbox"
        , if searchOpen then
            cs "is-open"
          else
            nop
        ]
        [ div [ cs "searchbox__field" ]
            [ input
                [ type_ "text"
                , value searchInputValue
                , onInput UpdateSearchField
                , onEnter (SearchEntries searchInputValue)
                , class "searchbox__input mdl-color--grey-50"
                , id "searchbox-input"
                , placeholder <| translate language SearchPlaceholder
                ]
                []
            , span [ cs "searchbox__search-icon" ]
                [ label [ for "searchbox-input" ] [ Icon.i "search" ] ]
            , clearIcon
            ]
        , div [ cs "searchbox__suggestions" ] []
        ]


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
