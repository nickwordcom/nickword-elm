module Entries.Partials.EntryPrefetched exposing (view)

import App.Translations exposing (Language)
import Categories.Models exposing (Category)
import Entries.Messages exposing (Msg)
import Entries.Models exposing (Entry)
import Entries.Partials.EntryCategoryInfo as CategoryInfo
import Entries.Partials.EntryInfo exposing (entryImage, entryImageSource)
import Html exposing (..)
import Html.Attributes exposing (..)
import Material.Options exposing (css)
import Material.Spinner as Spinner
import RemoteData exposing (WebData)


view : Entry -> WebData (List Category) -> Language -> Html Msg
view entry categories language =
    div [ class "entry-page h-full-height" ]
        [ div [ class "entry-page__wrapper mdl-shadow--2dp" ]
            [ div [ class "entry-page__info" ]
                [ div [ class "entry-page__info-secondary" ]
                    [ entryImage entry.image.url entry.title
                    , entryImageSource entry.image language
                    ]
                , div [ class "entry-page__info-primary" ]
                    [ h1 [ class "entry-page__title" ] [ text entry.title ]
                    , CategoryInfo.view categories entry.categoryId
                    , span [ class "entry-page__description" ] [ text entry.description ]
                    ]
                ]
            , div [ class "h-text-center" ]
                [ Spinner.spinner
                    [ Spinner.active True
                    , Spinner.singleColor True
                    , css "vertical-align" "middle"
                    , css "margin" "2px 0"
                    ]
                ]
            ]
        ]
