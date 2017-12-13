module Entries.Messages exposing (..)

import App.Models exposing (WebData)
import Categories.Messages as CategoriesMsgs
import Entries.Models exposing (Entry, EntryId, EntrySlug, FilterType)
import Entries.NewEntry.Messages as NewEntryMsgs
import Material
import Votes.Messages as VotesMsgs
import Words.Messages as WordsMsgs


type Msg
    = NoOp
    | CategoryEntriesResponse (WebData (List Entry))
    | EntriesPopularResponse (WebData (List Entry))
    | EntriesFeaturedResponse (WebData (List Entry))
    | UserEntriesResponse (WebData (List Entry))
    | AllPopularEntriesResponse (WebData (List Entry))
    | SearchEntriesResponse (WebData (List Entry))
    | EntrySimilarResponse (WebData (List Entry))
    | EntryResponse (WebData Entry)
    | PrefetchEntry Entry
    | LoadMoreEntries
    | RandomEntryResponse (WebData Entry)
    | ApplyFilters FilterType
    | Navigate String
    | SelectEntryTab Int
    | ToggleEntryFilters
      -- Else messages
    | NewEntryMsg NewEntryMsgs.Msg
    | WordsMsg WordsMsgs.Msg
    | VotesMsg VotesMsgs.Msg
    | CategoriesMsg CategoriesMsgs.Msg
    | ScrollToTop
    | MDL (Material.Msg Msg)
