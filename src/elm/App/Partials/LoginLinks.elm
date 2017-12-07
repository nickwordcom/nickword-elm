module App.Partials.LoginLinks exposing (..)

import App.Routing exposing (Route, routeToPath)
import App.Translations exposing (..)
import Html exposing (Html, a, div, h3, p, span, text)
import Html.Attributes exposing (class, classList, href)
import OAuth.Config exposing (..)
import Svg
import Svg.Attributes
import Users.Models exposing (User)
import Users.Utils exposing (userIsUnknown)


view : User -> Language -> Route -> Html msg
view user language route =
    if userIsUnknown user then
        loginForm (routeToPath route) language
    else
        div [] []


topBlock : User -> Language -> Route -> Bool -> Html msg
topBlock user language route blockOpen =
    div
        [ classList
            [ ( "mdl-color--blue-grey-900 mdl-color-text--white", True )
            , ( "mdl-shadow--2dp h-padding", True )
            , ( "h-hidden", not blockOpen )
            ]
        ]
        [ view user language route ]


loginForm : String -> Language -> Html msg
loginForm path language =
    div [ class "login-form" ]
        [ div [ class "login-form__wrapper" ]
            [ div [ class "login-form__header" ]
                [ h3 [ class "login-form__header-title" ]
                    [ text <| translate language LoginFormHeader ]
                ]
            , p [ class "login-form__description h-font-size-16" ]
                [ text <| translate language ItIsSecureAndReliable ]
            , p [ class "login-form__description" ]
                [ text <| translate language LoginFormPrimaryDescr ]
            , div [ class "login-form__actions h-spacing-above--small h-spacing-below--small" ]
                [ a
                    [ href <| buildAuthUrl (facebookAuthClient path)
                    , class "login-form__action facebook h-overflow-ellipsis"
                    ]
                    [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "login-form__action-icon" ]
                        [ Svg.path [ Svg.Attributes.d "M19,4V7H17A1,1 0 0,0 16,8V10H19V13H16V20H13V13H11V10H13V7.5C13,5.56 14.57,4 16.5,4M20,2H4A2,2 0 0,0 2,4V20A2,2 0 0,0 4,22H20A2,2 0 0,0 22,20V4C22,2.89 21.1,2 20,2Z" ] [] ]
                    , span [ class "login-form__action-label" ]
                        [ text <| translate language ContWtFacebookText ]
                    ]
                , a
                    [ href <| buildAuthUrl (vkAuthClient path)
                    , class "login-form__action vk h-overflow-ellipsis"
                    ]
                    [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "login-form__action-icon" ]
                        [ Svg.path [ Svg.Attributes.d "M5,3H19A2,2 0 0,1 21,5V19A2,2 0 0,1 19,21H5A2,2 0 0,1 3,19V5A2,2 0 0,1 5,3M17.24,14.03C16.06,12.94 16.22,13.11 17.64,11.22C18.5,10.07 18.85,9.37 18.74,9.07C18.63,8.79 18,8.86 18,8.86L15.89,8.88C15.89,8.88 15.73,8.85 15.62,8.92C15.5,9 15.43,9.15 15.43,9.15C15.43,9.15 15.09,10.04 14.65,10.8C13.71,12.39 13.33,12.47 13.18,12.38C12.83,12.15 12.91,11.45 12.91,10.95C12.91,9.41 13.15,8.76 12.46,8.6C12.23,8.54 12.06,8.5 11.47,8.5C10.72,8.5 10.08,8.5 9.72,8.68C9.5,8.8 9.29,9.06 9.41,9.07C9.55,9.09 9.86,9.16 10.03,9.39C10.25,9.68 10.24,10.34 10.24,10.34C10.24,10.34 10.36,12.16 9.95,12.39C9.66,12.54 9.27,12.22 8.44,10.78C8,10.04 7.68,9.22 7.68,9.22L7.5,9L7.19,8.85H5.18C5.18,8.85 4.88,8.85 4.77,9C4.67,9.1 4.76,9.32 4.76,9.32C4.76,9.32 6.33,12.96 8.11,14.8C9.74,16.5 11.59,16.31 11.59,16.31H12.43C12.43,16.31 12.68,16.36 12.81,16.23C12.93,16.1 12.93,15.94 12.93,15.94C12.93,15.94 12.91,14.81 13.43,14.65C13.95,14.5 14.61,15.73 15.31,16.22C15.84,16.58 16.24,16.5 16.24,16.5L18.12,16.47C18.12,16.47 19.1,16.41 18.63,15.64C18.6,15.58 18.36,15.07 17.24,14.03Z" ] [] ]
                    , span [ class "login-form__action-label" ]
                        [ text <| translate language ContWtVkText ]
                    ]
                , a
                    [ href <| buildAuthUrl (googleAuthClient path)
                    , class "login-form__action google h-overflow-ellipsis"
                    ]
                    [ Svg.svg [ Svg.Attributes.viewBox "0 0 25 25", Svg.Attributes.class "login-form__action-icon", Svg.Attributes.width "24", Svg.Attributes.height "24" ]
                        [ Svg.g [ Svg.Attributes.fill "none", Svg.Attributes.fillRule "evenodd" ]
                            [ Svg.path [ Svg.Attributes.fill "#4285F4", Svg.Attributes.d "M20.66 12.693c0-.603-.054-1.182-.155-1.738H12.5v3.287h4.575a3.91 3.91 0 0 1-1.697 2.566v2.133h2.747c1.608-1.48 2.535-3.65 2.535-6.24z" ] []
                            , Svg.path [ Svg.Attributes.fill "#34A853", Svg.Attributes.d "M12.5 21c2.295 0 4.22-.76 5.625-2.06l-2.747-2.132c-.76.51-1.734.81-2.878.81-2.214 0-4.088-1.494-4.756-3.503h-2.84v2.202A8.498 8.498 0 0 0 12.5 21z" ] []
                            , Svg.path [ Svg.Attributes.fill "#FBBC05", Svg.Attributes.d "M7.744 14.115c-.17-.51-.267-1.055-.267-1.615s.097-1.105.267-1.615V8.683h-2.84A8.488 8.488 0 0 0 4 12.5c0 1.372.328 2.67.904 3.817l2.84-2.202z" ] []
                            , Svg.path [ Svg.Attributes.fill "#EA4335", Svg.Attributes.d "M12.5 7.38c1.248 0 2.368.43 3.25 1.272l2.437-2.438C16.715 4.842 14.79 4 12.5 4a8.497 8.497 0 0 0-7.596 4.683l2.84 2.202c.668-2.01 2.542-3.504 4.756-3.504z" ] []
                            ]
                        ]
                    , span [ class "login-form__action-label" ]
                        [ text <| translate language ContWtGoogleText ]
                    ]
                ]
            , p [ class "login-form__description" ]
                [ text <| translate language LoginFormSecondaryDescr ]
            ]
        ]
