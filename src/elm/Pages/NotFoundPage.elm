module Pages.NotFoundPage exposing (..)

import App.Messages exposing (Msg(Navigate))
import App.Translations exposing (Language, TranslationId(HomePageText, PageNotFoundDescription, PageNotFoundText), translate)
import App.Utils.Links exposing (linkTo)
import Html exposing (Html, a, div, h2, text)
import Html.Attributes exposing (class, href)


view : Language -> Html Msg
view language =
    div [ class "wrapper" ]
        [ div [ class "mdl-grid" ]
            [ div [ class "mdl-cell mdl-card mdl-cell--12-col-desktop mdl-cell--8-col-tablet mdl-cell--4-col-phone mdl-shadow--2dp" ]
                [ div [ class "mdl-card__title mdl-card--expand not-found__title" ]
                    [ h2 [ class "mdl-card__title-text not-found__title-text" ]
                        [ text <| translate language PageNotFoundText ]
                    ]
                , div [ class "mdl-card__supporting-text" ]
                    [ text <| translate language PageNotFoundDescription ]
                , div [ class "mdl-card__actions mdl-card--border" ]
                    [ linkTo "/"
                        (Navigate "/")
                        [ class "mdl-button mdl-button--colored mdl-js-button mdl-js-ripple-effect" ]
                        [ text <| translate language HomePageText ]
                    ]
                ]
            ]
        ]
