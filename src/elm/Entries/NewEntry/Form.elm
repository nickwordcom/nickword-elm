module Entries.NewEntry.Form exposing (view)

import App.Models exposing (RemoteData(..), WebData)
import App.Translations exposing (..)
import Categories.Models exposing (Category, CategoryId)
import Entries.NewEntry.Messages exposing (Msg(..))
import Entries.NewEntry.Models exposing (NewEntryModel)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onBlur, onClick, onInput, onMouseDown, targetValue)
import Html.Events.Extra exposing (targetValueMaybe)
import Json.Decode as Json
import List
import Material.Button as Button
import Material.Options as Options exposing (cs, css)
import Material.Spinner as Spinner
import String
import String.Extra exposing (isBlank)


view : NewEntryModel -> WebData (List Category) -> Language -> Html Msg
view newEntry categories language =
    div [ class "new-entry__form" ]
        [ -- TITLE
          div [ class "new-entry__field-block" ]
            [ label [ class "new-entry__field-label is-required", for "new-entry-title-input" ]
                [ text <| translate language TitleText ]
            , input
                [ class "new-entry__field-input"
                , id "new-entry-title-input"
                , value newEntry.title
                , onInput ChangeTitleInput
                , onBlur CheckTitleInput
                , type_ "text"
                , placeholder <| translate language TitlePlaceholder
                , disabled newEntry.formSubmitted
                ]
                []
            , span [ class "new-entry__field-info -type-error" ]
                [ text newEntry.titleError ]
            , span [ class "new-entry__field-info" ]
                [ text "" ]
            ]

        -- CATEGORY
        , div [ class "new-entry__field-block" ]
            [ label [ class "new-entry__field-label is-required", for "new-entry-category-input" ]
                [ text <| translate language CategoryText ]
            , select
                [ on "change" (Json.map ChangeCategoryIdValue targetValueMaybe)
                , id "new-entry-category-input"
                , class "new-entry__categories-select"
                , disabled newEntry.formSubmitted
                ]
                (categoryOptions categories newEntry.categoryId language)
            ]

        -- DESCRIPTION
        , div [ class "new-entry__field-block" ]
            [ label [ class "new-entry__field-label is-required", for "new-entry-description-input" ]
                [ text <| translate language DescriptionText ]
            , textarea
                [ class "new-entry__field-input -type-textarea"
                , id "new-entry-description-input"
                , value newEntry.description
                , maxlength 140
                , rows 3
                , onInput ChangeDescriptionInput
                , onBlur CheckDescriptionInput
                , placeholder <| translate language DescriptionPlaceholder
                , disabled newEntry.formSubmitted
                ]
                []
            , span [ class "new-entry__field-info -type-error" ]
                [ text newEntry.descriptionError ]
            , span [ class "new-entry__field-info" ]
                [ text (toString (descriptionCharCounter newEntry.description)) ]
            ]

        -- IMAGE URL
        , div [ class "new-entry__field-block" ]
            [ label [ class "new-entry__field-label", for "new-entry-image-url-input" ]
                [ text <| translate language ImageUrlText ]
            , input
                [ class "new-entry__field-input"
                , id "new-entry-image-url-input"
                , value newEntry.imageUrl
                , onInput ChangeImageUrlInput
                , type_ "url"
                , placeholder <| translate language <| IEText "http://website.com/image.jpg"
                , disabled newEntry.formSubmitted
                ]
                []
            , span [ class "new-entry__field-info -type-error" ]
                [ text newEntry.imageUrlError ]
            , span [ class "new-entry__field-info" ]
                [ text <| translate language ImageUrlInfoText
                , a [ href ("https://www.google.com/search?tbm=isch&q=" ++ newEntry.title), target "_blank" ]
                    [ text <| translate language GoogleImagesText ]
                ]
            ]

        -- IMAGE CAPTION
        , imageCaptionField newEntry language

        -- TODO: Add link to terms page
        , div [ class "new-entry__submit-block" ]
            [ submitButton newEntry language
            , Spinner.spinner
                [ Spinner.active newEntry.formSubmitted
                , css "vertical-align" "middle"
                , css "margin-left" "20px"
                ]
            ]
        ]


imageCaptionField : NewEntryModel -> Language -> Html Msg
imageCaptionField newEntry language =
    if not (isBlank newEntry.imageUrl) && isBlank newEntry.imageUrlError then
        div [ class "new-entry__field-block" ]
            [ label [ class "new-entry__field-label", for "new-entry-image-caption-input" ]
                [ text <| translate language ImageCaptionFieldText ]
            , input
                [ class "new-entry__field-input"
                , id "new-entry-image-caption-input"
                , value newEntry.imageCaption
                , onInput ChangeImageCaptionInput
                , type_ "text"
                , disabled newEntry.formSubmitted
                ]
                []
            ]
    else
        span [] []


categoryOptions : WebData (List Category) -> Maybe CategoryId -> Language -> List (Html Msg)
categoryOptions categories currentCategoryId language =
    let
        selectedCategoryId =
            Maybe.withDefault "" currentCategoryId

        defaultValue =
            option [ value "", disabled True, selected True, style [ ( "display", "none" ) ] ]
                [ text <| translate language SelectCategoryText ]
    in
    case categories of
        Loading ->
            [ defaultValue ]

        Failure error ->
            [ defaultValue ]

        Success categories ->
            List.map (selectOption selectedCategoryId) categories
                |> (::) defaultValue


selectOption : CategoryId -> Category -> Html Msg
selectOption selectedCategoryId category =
    option
        [ value category.id
        , selected (category.id == selectedCategoryId)
        ]
        [ text category.title ]



-- targetValueIntDecoder : Json.Decoder (Maybe Int)
-- targetValueIntDecoder =
--   targetValue
--     |> Json.andThen checkTargetValue
--
--
-- checkTargetValue : String -> Json.Decoder (Maybe Int)
-- checkTargetValue val =
--   case String.toInt val of
--     Ok int -> Json.succeed (Just int)
--     Err e -> Json.succeed Nothing


descriptionCharCounter : String -> Int
descriptionCharCounter description =
    140 - String.length description


submitButton : NewEntryModel -> Language -> Html Msg
submitButton model language =
    let
        canAddEntry =
            noErrors model && fieldsFilled model

        msg =
            if canAddEntry && not model.formSubmitted then
                AddNewEntry
            else
                NoOp
    in
    Button.render MDL
        [ 2 ]
        model.mdl
        [ Button.raised
        , if canAddEntry then
            Button.colored
          else
            Button.disabled
        , Options.onClick msg
        ]
        [ text <| translate language SubmitEntryFormText ]


noErrors : NewEntryModel -> Bool
noErrors model =
    String.isEmpty model.titleError
        && String.isEmpty model.descriptionError
        && String.isEmpty model.imageUrlError


fieldsFilled : NewEntryModel -> Bool
fieldsFilled model =
    model.categoryId
        == Nothing
        || isBlank model.title
        || isBlank model.description
        || String.isEmpty model.title
        || String.isEmpty model.description
        |> not
