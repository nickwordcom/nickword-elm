module Entries.Partials.EntryInfo exposing (..)

import App.Routing exposing (Route(CategoryRoute), routeToPath)
import App.Translations exposing (Language, TranslationId(ImageCaptionText, ImageSourceText, VotesReceivedText), translate)
import App.Utils.Cloudinary exposing (cloudinaryUrl_240)
import App.Utils.Links exposing (getLinkHostName, linkTo)
import Categories.Models exposing (Category)
import Entries.Messages exposing (Msg(Navigate, WordsMsg))
import Entries.Models exposing (Entry, EntryImage)
import Html exposing (..)
import Html.Attributes exposing (..)
import Material exposing (Model)
import RemoteData exposing (WebData)
import String exposing (isEmpty)
import Users.Models exposing (UserStatus)
import Words.Models exposing (EntryVotedWords, Word)
import Words.Partials.NewWordForm exposing (addNewWordForm)


entryInfo : Entry -> WebData EntryVotedWords -> Maybe Word -> String -> Bool -> WebData (List Category) -> UserStatus -> Language -> Material.Model -> Html Msg
entryInfo entry entryVotedWords entryTopWord newWordValue newWordFieldActive categories userStatus language mdlModel =
    div [ class "entry-page__info" ]
        [ div [ class "entry-page__info-secondary" ]
            [ entryImage entry.image.url entry.title
            , entryImageSource entry.image language
            ]
        , div [ class "entry-page__info-primary" ]
            [ h1 [ class "entry-page__title" ] [ text entry.title ]
            , categoryLink entry.category
            , span [ class "entry-page__description" ] [ text entry.description ]
            , div [ class "entry-page__word-field" ]
                [ Html.map WordsMsg (addNewWordForm newWordValue entry.id newWordFieldActive entryVotedWords entryTopWord userStatus language mdlModel) ]
            ]
        ]


entryImage : String -> String -> Html Msg
entryImage imageUrl entryTitle =
    div [ class "entry-page__profile-image mdl-shadow--2dp" ]
        [ img
            [ class "entry-page__profile-image-tag h-full-width lazyload"
            , attribute "data-src" (cloudinaryUrl_240 imageUrl)
            , src "data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=="
            , alt entryTitle
            , title entryTitle
            ]
            []
        ]


entryImageSource : EntryImage -> Language -> Html Msg
entryImageSource { url, caption } language =
    if not (isEmpty caption) && not (isEmpty url) then
        span [ class "entry-page__image-source" ]
            [ text <| translate language ImageCaptionText
            , text " "
            , text caption
            ]
    else if isEmpty caption && not (isEmpty url) then
        span [ class "entry-page__image-source h-overflow-ellipsis" ]
            [ text <| translate language ImageSourceText
            , text " "
            , a [ href url, title url, target "_blank" ] [ text (getLinkHostName url) ]
            ]
    else
        span [] []


categoryLink : Category -> Html Msg
categoryLink { id, slug, title } =
    let
        categoryPath =
            routeToPath <| CategoryRoute slug id
    in
    linkTo categoryPath
        (Navigate categoryPath)
        [ class "entry-page__category-link" ]
        [ text title ]



-- votesReceived : Int -> Language -> Html Msg
-- votesReceived votesCount language =
--     div [ class "entry-page__votes-counter" ]
--         [ div [ class "votes-counter__icon-block" ]
--             [ Icon.i "record_voice_over" ]
--         , div [ class "votes-counter__info" ]
--             [ span [ class "votes-counter__info-number", title (toString votesCount) ]
--                 [ text (convertVotes votesCount language) ]
--             , span [ class "votes-counter__info-text" ]
--                 [ text <| translate language (VotesReceivedText votesCount) ]
--             ]
--         ]
