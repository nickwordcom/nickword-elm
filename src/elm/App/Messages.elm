module App.Messages exposing (..)

import App.Translations exposing (Language)
import Categories.Messages as CategoriesMsgs
import Countries.Messages as CountriesMsgs
import Entries.Messages as EntriesMsgs
import Http exposing (Error)
import Material
import Material.Snackbar as Snackbar
import Navigation exposing (Location)
import ShareDialog.Messages as ShareDialogMsgs
import Votes.Messages as VotesMsgs
import Words.Messages as WordsMsgs


type Msg
    = NoOp
    | OnLocationChange Location
    | EntriesMsg EntriesMsgs.Msg
    | WordsMsg WordsMsgs.Msg
    | VotesMsg VotesMsgs.Msg
    | CategoriesMsg CategoriesMsgs.Msg
    | CountriesMsg CountriesMsgs.Msg
    | ShareDialogMsg ShareDialogMsgs.Msg
    | UserAuthorization (Result Error String)
    | Navigate String
    | ToggleTopLoginForm
    | ToggleSearchDialog
    | UpdateSearchField String
    | ClearSearchField
    | SearchEntries String
    | ChangeLanguage Language
    | RemoveLocalJWT
    | ScrollToTop
    | MDL (Material.Msg Msg)
    | Snackbar (Snackbar.Msg Int)
