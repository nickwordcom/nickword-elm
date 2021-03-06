module App.Utils.Cloudinary exposing (..)

import App.Translations exposing (Language, TranslationId(DescribeIOWText), translate)
import App.Utils.Config exposing (cloudinaryName)
import ShareDialog.Models exposing (ShareDialog, SocialNetwork(..))
import String


type alias ImageUrl =
    String


type alias EntryTitle =
    String


cloudinaryBase : String
cloudinaryBase =
    "https://res.cloudinary.com/" ++ cloudinaryName


cloudinaryUrl_240 : ImageUrl -> String
cloudinaryUrl_240 imageUrl =
    if String.isEmpty imageUrl then
        "/static/img/placeholder240.jpeg"
    else
        cloudinaryBase ++ "/image/fetch/t_fill_grav_240,f_auto/" ++ imageUrl


cloudinaryPosterUrl : ShareDialog -> SocialNetwork -> String
cloudinaryPosterUrl dialog network =
    let
        ( posterHeight, ySpot ) =
            case network of
                VK ->
                    ( "540", { t = "122", i = "168", w = "190" } )

                _ ->
                    ( "600", { t = "182", i = "228", w = "250" } )

        baseUrl =
            cloudinaryBase ++ "/image/fetch/t_poster_fill_" ++ posterHeight ++ "/"

        fafafa =
            cloudinaryBase ++ "/image/upload/v1482934813/fafafa.png"

        imageUrl =
            if String.isEmpty dialog.imageUrl then
                fafafa
            else
                dialog.imageUrl

        titleSize =
            textFontSize dialog.title |> toString

        encodedTitle =
            dialog.title
                |> String.filter (\c -> not <| List.member c [ ',', '#', '%', '/', '?' ])
                |> String.split " "
                |> String.join "%20"

        title =
            "l_text:Roboto_" ++ titleSize ++ "_medium_letter_spacing_1:" ++ encodedTitle ++ ",co_rgb:fff,w_560,h_54,y_" ++ ySpot.t ++ ",g_north,c_fit"

        encodedSubTitle =
            String.join "%20" (String.split " " dialog.subTitle)

        inoneword =
            "l_text:Roboto_18_letter_spacing_1:" ++ encodedSubTitle ++ ",co_rgb:fff,w_560,h_20,y_" ++ ySpot.i ++ ",g_north,c_fit"

        wordSize =
            textFontSize dialog.word |> toString

        word =
            "l_text:Roboto_" ++ wordSize ++ "_bold_letter_spacing_1:" ++ dialog.word ++ ",co_rgb:fff000,w_560,h_54,y_" ++ ySpot.w ++ ",g_north,c_fit"

        params =
            String.join "/" [ title, inoneword, word, imageUrl ]
    in
    baseUrl ++ params


cloudinaryEntryPosterUrl : EntryTitle -> ImageUrl -> Language -> String
cloudinaryEntryPosterUrl title imageUrl language =
    let
        baseUrl =
            cloudinaryBase ++ "/image/fetch/t_poster_fill_600/"

        fafafa =
            cloudinaryBase ++ "/image/upload/v1482934813/fafafa.png"

        mainImage =
            if String.isEmpty imageUrl then
                fafafa
            else
                imageUrl

        encodedTitle =
            title
                |> String.filter (\c -> not <| List.member c [ ',', '#', '%', '/', '?' ])
                |> String.split " "
                |> String.join "%20"

        encodedSubTitle =
            translate language DescribeIOWText
                |> String.split " "
                |> String.join "%20"

        titleText =
            "l_text:Roboto_40_medium_letter_spacing_1:" ++ encodedTitle ++ ",co_rgb:fff,w_560,h_54,y_182,g_north,c_fit"

        subTitleText =
            "l_text:Roboto_40_bold_letter_spacing_1:" ++ encodedSubTitle ++ ",co_rgb:fff000,w_560,h_54,y_230,g_north,c_fit"

        params =
            String.join "/" [ titleText, subTitleText, mainImage ]
    in
    baseUrl ++ params


textFontSize : String -> Int
textFontSize text =
    let
        size =
            String.length text
    in
    if size <= 18 then
        48
    else if size >= 19 && size <= 25 then
        40
    else if size >= 26 && size <= 32 then
        30
    else
        22
