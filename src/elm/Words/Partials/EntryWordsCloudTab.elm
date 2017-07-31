module Words.Partials.EntryWordsCloudTab exposing (view)

import App.Models exposing (RemoteData(..), WebData)
import App.Translations exposing (Language, TranslationId(ErrorText), translate)
import Html exposing (Html, div, section, text)
import Html.Attributes exposing (class, id, style)
import Material.Options exposing (cs, css)
import Material.Spinner as Spinner
import Words.Models exposing (Word)


view : WebData (List Word) -> Language -> Html a
view words language =
    case words of
        Loading ->
            wordsLoadingSpinner

        Failure err ->
            div [ class "word-cloud__text mdl-color-text--red-A700" ]
                [ text <| translate language <| ErrorText (toString err) ]

        Success _ ->
            section [ class "word-cloud" ]
                [ div
                    [ id "entry-words-cloud"
                    , class "word-cloud__block"
                    ]
                    []
                ]


wordsLoadingSpinner : Html a
wordsLoadingSpinner =
    div [ class "word-cloud__block h-text-center h-spacing-above--normal" ]
        [ Spinner.spinner
            [ Spinner.active True
            , Spinner.singleColor True
            , css "vertical-align" "middle"
            , css "margin" "2px 0"
            ]
        ]
