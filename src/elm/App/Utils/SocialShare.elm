module App.Utils.SocialShare exposing (..)

import App.Routing exposing (Route(EntryRoute), routeToPath)
import App.Translations exposing (Language(English), encryptLang)
import App.Utils.Cloudinary exposing (cloudinaryPosterUrl)
import App.Utils.Config exposing (rootUrl)
import App.Utils.Requests exposing (encodeUrl)
import ShareDialog.Models exposing (ShareDialog, SocialNetwork(..))


facebookShareDialog : ShareDialog -> Language -> String
facebookShareDialog { entrySlug, entryId, title, subTitle, word } language =
    let
        base =
            "https://www.facebook.com/dialog/feed"

        appId =
            "1847230732200619"

        redirect =
            "http://www.facebook.com/"

        routeUrl =
            routeToPath (EntryRoute entrySlug entryId)
                |> (++) rootUrl

        link =
            encodeUrl routeUrl (urlParams language)

        quote =
            word ++ " - " ++ title ++ " " ++ subTitle
    in
    encodeUrl base [ ( "app_id", appId ), ( "redirect_uri", redirect ), ( "link", link ), ( "quote", quote ) ]


pinItLink : ShareDialog -> Language -> String
pinItLink ({ entrySlug, entryId, title, subTitle, word } as dialog) language =
    let
        base =
            "https://www.pinterest.com/pin/create/button"

        routeUrl =
            routeToPath (EntryRoute entrySlug entryId)
                |> (++) rootUrl

        url =
            encodeUrl routeUrl (urlParams language)

        media =
            cloudinaryPosterUrl dialog Pinterest

        description =
            word ++ " - " ++ title ++ " " ++ subTitle
    in
    encodeUrl base [ ( "url", url ), ( "media", media ), ( "description", description ) ]


vkLink : ShareDialog -> Language -> String
vkLink ({ entrySlug, entryId, title, subTitle, word } as dialog) language =
    let
        base =
            "https://vk.com/share.php"

        routeUrl =
            routeToPath (EntryRoute entrySlug entryId)
                |> (++) rootUrl

        url =
            encodeUrl routeUrl (urlParams language)

        titleText =
            word ++ " - " ++ title ++ " " ++ subTitle

        description =
            ""

        image =
            cloudinaryPosterUrl dialog VK

        noparse =
            "true"
    in
    encodeUrl base [ ( "url", url ), ( "title", titleText ), ( "description", description ), ( "image", image ), ( "noparse", noparse ) ]


urlParams : Language -> List ( String, String )
urlParams language =
    if language /= English then
        [ ( "lang", encryptLang language ) ]
    else
        []
