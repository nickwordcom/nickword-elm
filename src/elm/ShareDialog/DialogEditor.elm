module ShareDialog.DialogEditor exposing (view)

import App.Translations exposing (Language, TranslationId(ImageUrlText, SubtitleText, TitleText, WordText), translate)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
import Material.Options as Options exposing (cs)
import Material.Textfield as Textfield
import ShareDialog.Messages exposing (Msg(..))
import ShareDialog.Models exposing (ShareDialog)


view : ShareDialog -> Language -> Html Msg
view dialog language =
    div [ class "share-dialog__editor" ]
        [ div [ class "share-dialog__field-block" ]
            [ Textfield.render MDL
                [ 1 ]
                dialog.mdl
                [ Textfield.label <| translate language TitleText
                , Textfield.floatingLabel
                , Textfield.value dialog.changes.title
                , Options.onInput UpdateEditedTitle
                ]
                []
            ]
        , div [ class "share-dialog__field-block" ]
            [ Textfield.render MDL
                [ 2 ]
                dialog.mdl
                [ Textfield.label <| translate language SubtitleText
                , Textfield.floatingLabel
                , Textfield.value dialog.changes.subTitle
                , Options.onInput UpdateEditedSubtitle
                ]
                []
            ]
        , div [ class "share-dialog__field-block" ]
            [ Textfield.render MDL
                [ 3 ]
                dialog.mdl
                [ Textfield.label <| translate language WordText
                , Textfield.floatingLabel
                , Textfield.value dialog.changes.word
                , Options.onInput UpdateEditedWord
                ]
                []
            ]
        , div [ class "share-dialog__field-block" ]
            [ Textfield.render MDL
                [ 4 ]
                dialog.mdl
                [ Textfield.label <| translate language ImageUrlText
                , Textfield.floatingLabel
                , Textfield.value dialog.changes.imageUrl
                , Options.onInput UpdateEditedImage
                ]
                []
            ]
        ]
