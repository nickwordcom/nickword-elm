module App.Partials.Header exposing (appHeader)

import App.Messages exposing (Msg(..))
import App.Models exposing (Model)
import App.Routing exposing (Route(EntriesNewRoute, RandomEntryRoute, UserEntriesRoute), routeToPath)
import App.Translations exposing (..)
import App.Utils.Links exposing (linkTo)
import Html exposing (Html, text)
import Html.Attributes exposing (class, classList, tabindex)
import Material
import Material.Icon as Icon
import Material.Layout as Layout
import Material.Menu as Menu
import Material.Options as Options exposing (cs, css, div, nop, span)
import Search.SearchBox exposing (searchBox)
import Users.Models exposing (User)
import Users.Utils exposing (userIsUnknown)


appHeader : Model -> List (Html Msg)
appHeader { searchDialogOpen, searchValue, appLanguage, user, mdl } =
    [ Layout.row
        [ css "transition" "height 333ms ease-in-out 0s" ]
        [ primaryTitle "Nickword" searchDialogOpen
        , searchBox searchDialogOpen searchValue appLanguage
        , Layout.spacer
        , headerNavigation mdl searchDialogOpen user appLanguage
        ]
    ]


primaryTitle : String -> Bool -> Html Msg
primaryTitle title searchOpen =
    Layout.title
        [ cs "h-clickable"
        , if searchOpen then
            cs "h-hidden"
          else
            nop
        ]
        [ linkTo "/"
            (Navigate "/")
            [ class "mdl-layout__title mdl-navigation__link h-remove-padding"
            , tabindex 1
            ]
            [ text title ]
        ]


headerNavigation : Material.Model -> Bool -> User -> Language -> Html Msg
headerNavigation mdlModel searchOpen user language =
    Layout.navigation []
        [ linkTo newEntryPath
            (Navigate newEntryPath)
            [ class "mdl-navigation__link header-desktop"
            , tabindex 1
            ]
            [ text <| translate language CreateEntryText ]
        , linkTo randomEntryPath
            (Navigate randomEntryPath)
            [ class "mdl-navigation__link header-desktop"
            , tabindex 1
            ]
            [ text <| translate language RandomEntryText ]
        , linkTo userEntriesPath
            (Navigate userEntriesPath)
            [ classList
                [ ( "mdl-navigation__link header-desktop", True )
                , ( "h-hidden", userIsUnknown user )
                ]
            , tabindex 1
            ]
            [ text <| translate language MyEntriesText ]
        , Layout.link
            [ Options.onClick ToggleTopLoginForm
            , Options.attribute <| Html.Attributes.tabindex 1
            , cs "mdl-navigation__link header-desktop h-clickable"
            , if userIsUnknown user then
                nop
              else
                cs "h-hidden"
            ]
            [ text <| translate language LoginText ]

        -- Open Search icon
        , Layout.link
            [ Options.onClick ToggleSearchDialog
            , cs "h-clickable header-mobile"
            , if searchOpen then
                cs "h-hidden"
              else
                nop
            ]
            [ Icon.i "search" ]

        -- Open Menu icon
        , div
            [ cs "mdl-navigation__link header-mobile"
            , css "position" "relative"
            , if searchOpen then
                cs "h-hidden"
              else
                nop
            ]
            [ Menu.render MDL
                [ 1 ]
                mdlModel
                [ Menu.ripple, Menu.bottomRight ]
                [ Menu.item
                    [ Menu.onSelect (Navigate newEntryPath)
                    , css "padding-right" "24px"
                    ]
                    [ Icon.view "add" [ css "width" "40px" ]
                    , text <| translate language CreateEntryText
                    ]
                , Menu.item
                    [ Menu.onSelect (Navigate randomEntryPath)
                    , css "padding-right" "24px"
                    ]
                    [ Icon.view "shuffle" [ css "width" "40px" ]
                    , text <| translate language RandomEntryText
                    ]
                , Menu.item
                    [ Menu.onSelect (Navigate userEntriesPath)
                    , css "padding-right" "24px"
                    , if userIsUnknown user then
                        cs "h-hidden"
                      else
                        nop
                    ]
                    [ Icon.view "collections" [ css "width" "40px" ]
                    , text <| translate language MyEntriesText
                    ]
                , Menu.item
                    [ Menu.onSelect ToggleTopLoginForm
                    , css "padding-right" "24px"
                    , if userIsUnknown user then
                        nop
                      else
                        cs "h-hidden"
                    ]
                    [ Icon.view "person" [ css "width" "40px" ]
                    , text <| translate language LoginText
                    ]
                ]
            ]

        -- Close Search icon
        , Layout.link
            [ Options.onClick ToggleSearchDialog
            , cs "h-clickable header-mobile"
            , if searchOpen then
                nop
              else
                cs "h-hidden"
            ]
            [ Icon.i "close" ]
        ]


newEntryPath : String
newEntryPath =
    routeToPath EntriesNewRoute


randomEntryPath : String
randomEntryPath =
    routeToPath RandomEntryRoute


userEntriesPath : String
userEntriesPath =
    routeToPath UserEntriesRoute
