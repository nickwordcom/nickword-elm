module Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)

import App.Routing exposing (Route(EntryRoute), routeToPath)
import App.Translations exposing (Language, TranslationId(NumberOfVotesText, ShowAllText), translate)
import App.Utils.Cloudinary exposing (cloudinaryUrl_240)
import App.Utils.Links exposing (linkTo)
import Entries.Messages exposing (Msg(Navigate, PrefetchEntry, ScrollToTop))
import Entries.Models exposing (Entry)
import Html exposing (Html, a, div, h2, h3, h4, img, li, span, text, ul)
import Html.Attributes exposing (class, href, src, style, title)
import Html.Events exposing (onMouseUp)
import Material.Icon as Icon


type alias Title =
    String


type alias SubTitle =
    String


type alias ShowAllUrl =
    String


entriesGridBlock : List Entry -> Title -> SubTitle -> Maybe ShowAllUrl -> Bool -> Language -> Html Msg
entriesGridBlock entries title subTitle showAllUrl crop language =
    div [ class (gridBlockClass crop) ]
        [ div [ class "entries-grid__header h-clearfix" ]
            [ div [ class "entries-grid__header-info" ]
                [ h2 [ class "entries-grid__header-title" ]
                    [ text title ]
                , span [ class "entries-grid__header-subtitle" ]
                    [ text subTitle ]
                ]
            , div [ class "entries-grid__header-actions" ]
                [ showAllButton showAllUrl language ]
            ]
        , ul [ class "entries-grid__list" ]
            (List.map (entryItem language) entries)
        ]


gridBlockClass : Bool -> String
gridBlockClass crop =
    let
        base =
            "entries-grid__block"
    in
    if crop then
        base ++ " cropped"
    else
        base


entryItem : Language -> Entry -> Html Msg
entryItem language entry =
    let
        entryPath =
            routeToPath (EntryRoute entry.slug entry.id)

        entryImgSrc =
            cloudinaryUrl_240 entry.image.url
    in
    li
        [ class "egrid-item"
        , onMouseUp (PrefetchEntry entry)
        ]
        [ linkTo entryPath
            (Navigate entryPath)
            [ onMouseUp ScrollToTop
            , class "egrid-item__link"
            ]
            [ img
                [ class "egrid-item__img h-full-width h-absolute-position"
                , src entryImgSrc
                ]
                []
            , div [ class "egrid-item__caption" ]
                [ h2 [ class "egrid-item__caption-title h-overflow-ellipsis", title entry.title ]
                    [ text entry.title ]
                , h3 [ class "egrid-item__caption-subtitle h-overflow-ellipsis" ]
                    [ text <| translate language <| NumberOfVotesText entry.votesCount ]
                ]
            ]
        ]


showAllButton : Maybe ShowAllUrl -> Language -> Html Msg
showAllButton showAllUrl language =
    case showAllUrl of
        Just url ->
            linkTo url
                (Navigate url)
                [ class "entries-grid__all-btn" ]
                [ span [ class "entries-grid__all-btn-text" ]
                    [ text <| translate language ShowAllText ]
                , span [ class "entries-grid__all-btn-icon" ]
                    [ Icon.i "arrow_forward" ]
                ]

        Nothing ->
            span [] []
