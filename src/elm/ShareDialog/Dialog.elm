module ShareDialog.Dialog exposing (view)

import App.Translations exposing (Language, TranslationId(CancelText, CloseText, EditText, ShareDownloadImageText, ShareText, UpdateText), translate)
import App.Utils.Cloudinary exposing (cloudinaryPosterUrl)
import App.Utils.SocialShare exposing (facebookShareDialog, pinItLink, vkLink)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Material
import Material.Button as Button
import Material.Dialog as Dialog
import Material.Options as Options exposing (cs)
import ShareDialog.DialogEditor as DialogEditor
import ShareDialog.Messages exposing (Msg(..))
import ShareDialog.Models exposing (ShareDialog, SocialNetwork(Facebook))
import Svg
import Svg.Attributes


view : ShareDialog -> Language -> Html Msg
view dialog language =
    Dialog.view [ cs "share-dialog" ]
        [ Dialog.title []
            [ dialogTitle dialog.editing language ]
        , Dialog.content []
            [ dialogContent dialog language ]
        , Dialog.actions []
            (dialogActions dialog.editing dialog.mdl language)
        ]


dialogTitle : Bool -> Language -> Html Msg
dialogTitle editing language =
    if editing then
        translate language EditText
            |> (++) " - "
            |> (++) (translate language ShareText)
            |> text
    else
        text <| translate language ShareText


dialogContent : ShareDialog -> Language -> Html Msg
dialogContent dialog language =
    if dialog.editing then
        DialogEditor.view dialog language
    else
        linksList dialog language


dialogActions : Bool -> Material.Model -> Language -> List (Html Msg)
dialogActions editing mdlModel language =
    if editing then
        [ Button.render MDL
            [ 10 ]
            mdlModel
            [ Button.colored
            , Button.raised
            , Options.onClick UpdateShareDialog
            ]
            [ text <| translate language UpdateText ]
        , Button.render MDL
            [ 11 ]
            mdlModel
            [ Options.onClick CloseEditor
            , cs "mdl-color-text--accent"
            ]
            [ text <| translate language CancelText ]
        ]
    else
        [ Button.render MDL
            [ 12 ]
            mdlModel
            [ Dialog.closeOn "click"
            , cs "mdl-color-text--accent"
            ]
            [ text <| translate language CloseText ]
        ]


linksList : ShareDialog -> Language -> Html Msg
linksList dialog language =
    ul [ class "share-dialog__links-list" ]
        ([ imageLink dialog language, editButton language ]
            |> List.append (linksListItems dialog language)
        )


linksListItems : ShareDialog -> Language -> List (Html Msg)
linksListItems dialog language =
    [ facebookDialogLink, vkShareLink, pinterestPinItLink ]
        |> List.map
            (\link ->
                li [ class "share-dialog__links-item" ]
                    [ link dialog language ]
            )


facebookDialogLink : ShareDialog -> Language -> Html Msg
facebookDialogLink dialog language =
    let
        facebookShareLink =
            facebookShareDialog dialog language
    in
    a [ class "share-dialog__links-link", href facebookShareLink, target "_blank" ]
        [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "share-dialog__links-link-svg" ]
            [ Svg.path [ Svg.Attributes.d "M19,4V7H17A1,1 0 0,0 16,8V10H19V13H16V20H13V13H11V10H13V7.5C13,5.56 14.57,4 16.5,4M20,2H4A2,2 0 0,0 2,4V20A2,2 0 0,0 4,22H20A2,2 0 0,0 22,20V4C22,2.89 21.1,2 20,2Z" ] [] ]
        , text "Facebook"
        ]


vkShareLink : ShareDialog -> Language -> Html Msg
vkShareLink dialog language =
    let
        shareLink =
            vkLink dialog language
    in
    a [ class "share-dialog__links-link", href shareLink, target "_blank" ]
        [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "share-dialog__links-link-svg" ]
            [ Svg.path [ Svg.Attributes.d "M5,3H19A2,2 0 0,1 21,5V19A2,2 0 0,1 19,21H5A2,2 0 0,1 3,19V5A2,2 0 0,1 5,3M17.24,14.03C16.06,12.94 16.22,13.11 17.64,11.22C18.5,10.07 18.85,9.37 18.74,9.07C18.63,8.79 18,8.86 18,8.86L15.89,8.88C15.89,8.88 15.73,8.85 15.62,8.92C15.5,9 15.43,9.15 15.43,9.15C15.43,9.15 15.09,10.04 14.65,10.8C13.71,12.39 13.33,12.47 13.18,12.38C12.83,12.15 12.91,11.45 12.91,10.95C12.91,9.41 13.15,8.76 12.46,8.6C12.23,8.54 12.06,8.5 11.47,8.5C10.72,8.5 10.08,8.5 9.72,8.68C9.5,8.8 9.29,9.06 9.41,9.07C9.55,9.09 9.86,9.16 10.03,9.39C10.25,9.68 10.24,10.34 10.24,10.34C10.24,10.34 10.36,12.16 9.95,12.39C9.66,12.54 9.27,12.22 8.44,10.78C8,10.04 7.68,9.22 7.68,9.22L7.5,9L7.19,8.85H5.18C5.18,8.85 4.88,8.85 4.77,9C4.67,9.1 4.76,9.32 4.76,9.32C4.76,9.32 6.33,12.96 8.11,14.8C9.74,16.5 11.59,16.31 11.59,16.31H12.43C12.43,16.31 12.68,16.36 12.81,16.23C12.93,16.1 12.93,15.94 12.93,15.94C12.93,15.94 12.91,14.81 13.43,14.65C13.95,14.5 14.61,15.73 15.31,16.22C15.84,16.58 16.24,16.5 16.24,16.5L18.12,16.47C18.12,16.47 19.1,16.41 18.63,15.64C18.6,15.58 18.36,15.07 17.24,14.03Z" ] [] ]
        , text "VK"
        ]


pinterestPinItLink : ShareDialog -> Language -> Html Msg
pinterestPinItLink dialog language =
    let
        pinLink =
            pinItLink dialog language
    in
    a [ class "share-dialog__links-link", href pinLink, target "_blank" ]
        [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "share-dialog__links-link-svg" ]
            [ Svg.path [ Svg.Attributes.d "M13,16.2C12.2,16.2 11.43,15.86 10.88,15.28L9.93,18.5L9.86,18.69L9.83,18.67C9.64,19 9.29,19.2 8.9,19.2C8.29,19.2 7.8,18.71 7.8,18.1C7.8,18.05 7.81,18 7.81,17.95H7.8L7.85,17.77L9.7,12.21C9.7,12.21 9.5,11.59 9.5,10.73C9.5,9 10.42,8.5 11.16,8.5C11.91,8.5 12.58,8.76 12.58,9.81C12.58,11.15 11.69,11.84 11.69,12.81C11.69,13.55 12.29,14.16 13.03,14.16C15.37,14.16 16.2,12.4 16.2,10.75C16.2,8.57 14.32,6.8 12,6.8C9.68,6.8 7.8,8.57 7.8,10.75C7.8,11.42 8,12.09 8.34,12.68C8.43,12.84 8.5,13 8.5,13.2A1,1 0 0,1 7.5,14.2C7.13,14.2 6.79,14 6.62,13.7C6.08,12.81 5.8,11.79 5.8,10.75C5.8,7.47 8.58,4.8 12,4.8C15.42,4.8 18.2,7.47 18.2,10.75C18.2,13.37 16.57,16.2 13,16.2M20,2H4C2.89,2 2,2.89 2,4V20A2,2 0 0,0 4,22H20A2,2 0 0,0 22,20V4C22,2.89 21.1,2 20,2Z" ] [] ]
        , text "Pinterest"
        ]


imageLink : ShareDialog -> Language -> Html Msg
imageLink dialog language =
    let
        imageUrl =
            cloudinaryPosterUrl dialog Facebook
    in
    li [ class "share-dialog__links-item" ]
        [ a [ class "share-dialog__links-link", href imageUrl, target "_blank" ]
            [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "share-dialog__links-link-svg" ]
                [ Svg.path [ Svg.Attributes.d "M5,20H19V18H5M19,9H15V3H9V9H5L12,16L19,9Z" ] [] ]
            , text <| translate language ShareDownloadImageText
            ]
        ]


editButton : Language -> Html Msg
editButton language =
    li [ class "share-dialog__links-item" ]
        [ a [ class "share-dialog__links-link h-clickable", onClick EditDialog ]
            [ Svg.svg [ Svg.Attributes.viewBox "0 0 24 24", Svg.Attributes.class "share-dialog__links-link-svg" ]
                [ Svg.path [ Svg.Attributes.d "M20.71,7.04C21.1,6.65 21.1,6 20.71,5.63L18.37,3.29C18,2.9 17.35,2.9 16.96,3.29L15.12,5.12L18.87,8.87M3,17.25V21H6.75L17.81,9.93L14.06,6.18L3,17.25Z" ] [] ]
            , text <| translate language EditText
            ]
        ]
