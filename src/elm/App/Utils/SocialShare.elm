module App.Utils.SocialShare exposing (..)

import App.Utils.Cloudinary exposing (cloudinaryPosterUrl)
import App.Utils.Config exposing (rootUrl)
import App.Utils.Requests exposing (encodeUrl)
import ShareDialog.Models exposing (ShareDialog, SocialNetwork(..))


facebookShareDialog : ShareDialog -> String
facebookShareDialog dialog =
    let
        base =
            "https://www.facebook.com/dialog/feed"

        appId =
            "1847230732200619"

        redirect =
            "http://www.facebook.com/"

        link =
            rootUrl ++ "/e/" ++ dialog.entrySlug ++ "/" ++ dialog.entryId

        quote =
            dialog.title ++ " " ++ dialog.subTitle ++ " - " ++ dialog.word

        -- fields are deprecated in v2.9
        -- picture =
        --     cloudinaryPosterUrl dialog Facebook
        --
        -- name =
        --     dialog.word ++ " - " ++ dialog.title ++ " " ++ dialog.subTitle
        --
        -- caption =
        --     ""
        --
        -- description =
        --     ""
    in
    encodeUrl base [ ( "app_id", appId ), ( "redirect_uri", redirect ), ( "link", link ), ( "quote", quote ) ]


pinItLink : ShareDialog -> String
pinItLink dialog =
    let
        base =
            "https://www.pinterest.com/pin/create/button"

        url =
            rootUrl ++ "/e/" ++ dialog.entrySlug ++ "/" ++ dialog.entryId

        media =
            cloudinaryPosterUrl dialog Pinterest

        description =
            dialog.word ++ " - " ++ dialog.title ++ " " ++ dialog.subTitle
    in
    encodeUrl base [ ( "url", url ), ( "media", media ), ( "description", description ) ]


vkLink : ShareDialog -> String
vkLink dialog =
    let
        base =
            "https://vk.com/share.php"

        url =
            rootUrl ++ "/e/" ++ dialog.entrySlug ++ "/" ++ dialog.entryId

        title =
            dialog.word ++ " - " ++ dialog.title ++ " " ++ dialog.subTitle

        description =
            ""

        image =
            cloudinaryPosterUrl dialog VK

        noparse =
            "true"
    in
    encodeUrl base [ ( "url", url ), ( "title", title ), ( "description", description ), ( "image", image ), ( "noparse", noparse ) ]
