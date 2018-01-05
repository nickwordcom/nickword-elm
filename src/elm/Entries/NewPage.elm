module Entries.NewPage exposing (view)

import App.Partials.LoginLinks as LoginLinks
import App.Routing exposing (Route)
import App.Translations exposing (Language, TranslationId(CreateEntryText), translate)
import Categories.Models exposing (Category)
import Entries.Messages exposing (Msg(NewEntryMsg))
import Entries.NewEntry.Form as NewEntryForm
import Entries.NewEntry.Models exposing (NewEntryModel)
import Html exposing (Html, div, h1, span, text)
import Html.Attributes exposing (class)
import RemoteData exposing (WebData)
import Users.Models exposing (User)


view : NewEntryModel -> WebData (List Category) -> User -> Language -> Route -> Html Msg
view newEntry categories user language route =
    div [ class "new-entry__wrapper" ]
        [ div [ class "new-entry__block mdl-shadow--2dp" ]
            [ h1 [ class "new-entry__headline" ]
                [ text <| translate language CreateEntryText ]
            , div [ class "new-entry__login-form" ]
                [ LoginLinks.view user language route ]
            , Html.map NewEntryMsg (NewEntryForm.view newEntry categories user language)
            ]
        ]
