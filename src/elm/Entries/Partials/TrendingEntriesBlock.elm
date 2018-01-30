module Entries.Partials.TrendingEntriesBlock exposing (view)

import App.Routing exposing (Route(TrendingRoute), routeToPath)
import App.Translations exposing (..)
import Entries.Messages exposing (Msg)
import Entries.Models exposing (Entry)
import Entries.Partials.EntriesGridBlock exposing (entriesGridBlock)
import Entries.Partials.EntriesGridBlockFailure exposing (gridBlockFailure)
import Entries.Partials.EntriesGridBlockLoading exposing (gridBlockLoading)
import Html exposing (Html, div, text)
import List exposing (isEmpty, take)
import RemoteData exposing (RemoteData(..), WebData)


view : WebData (List Entry) -> Language -> Html Msg
view trendingEntries language =
    let
        title =
            translate language TrendingNowText

        subTitle =
            translate language TrendingNowSubTitle

        showAllUrl =
            routeToPath TrendingRoute
    in
    case trendingEntries of
        NotAsked ->
            gridBlockLoading title ""

        Loading ->
            gridBlockLoading title (translate language LoadingText)

        Failure error ->
            gridBlockFailure title (translate language <| ErrorText (toString error))

        Success entries ->
            if isEmpty entries then
                div [] []
            else
                entriesGridBlock (take 6 entries) title subTitle (Just showAllUrl) True language
