module App.Utils.Checkers exposing (..)

import App.Translations exposing (Language, TranslationId(..), translate)
import List exposing (member)
import String


checkForTitleError : String -> Language -> String
checkForTitleError title language =
    if title == "" then
        translate language TitleMustPresent
    else if String.length title <= 2 then
        translate language TitleTooShort
    else if String.length title > 60 then
        translate language TitleTooLong
    else
        ""


checkForDescriptionError : String -> Language -> String
checkForDescriptionError description language =
    if description == "" then
        translate language DescriptionMustPresent
    else if String.length description > 140 then
        translate language DescriptionTooLong
    else
        ""


checkForImageUrlError : String -> Language -> String
checkForImageUrlError imageUrl language =
    if not (String.isEmpty imageUrl) then
        if not (String.startsWith "http" imageUrl) then
            translate language InvalidImageURL
        else if not (member (String.right 4 imageUrl) [ ".jpg", ".png", ".gif" ] || String.endsWith ".jpeg" imageUrl) then
            translate language InvalidImageFormat
        else
            ""
    else
        ""
