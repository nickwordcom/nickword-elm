module Entries.Messages exposing (..)

import Categories.Messages as CategoriesMsgs
import Entries.Models exposing (Entry, EntryId, EntrySlug, FilterType)
import Entries.NewEntry.Messages as NewEntryMsgs
import Material
import RemoteData exposing (WebData)
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
    | RandomEntryResponse (WebData Entry)
    | EntryResponse (WebData Entry)
    | PrefetchEntry Entry
    | LoadMoreEntries
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
