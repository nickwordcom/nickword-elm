module Votes.Partials.EntryVotesTab exposing (votesList)

import App.Models exposing (RemoteData(..), WebData)
import App.Translations exposing (..)
import Entries.Messages exposing (Msg)
import Html exposing (..)
import Html.Attributes exposing (class, id, title)
import Material.Options exposing (css)
import Material.Spinner as Spinner
import Votes.Models exposing (Vote)


votesList : WebData (List Vote) -> Language -> Html Msg
votesList entryVotes language =
    let
        votesList =
            case entryVotes of
                Loading ->
                    votesLoadingSpinner

                Failure err ->
                    div [ class "entry-votes__text mdl-color-text--red-A700" ]
                        [ text <| translate language <| ErrorText (toString err) ]

                Success votes ->
                    ul [ class "entry-votes__list" ] (List.map voteItem votes)
    in
    section [ class "entry-votes" ]
        [ votesList ]


voteItem : Vote -> Html Msg
voteItem vote =
    let
        voteTime =
            vote.createdAt

        -- dateToAgo vote.createdAt currentTime
    in
    li [ class "entry-votes__item mdl-shadow--2dp" ]
        [ h3 [ class "entry-votes__item-title", title vote.wordName ] [ text vote.wordName ]
        , span [ class "entry-votes__item-info" ] [ text (vote.city ++ ", " ++ voteTime) ]
        ]


votesLoadingSpinner : Html Msg
votesLoadingSpinner =
    div [ class "entry-votes__loading" ]
        [ Spinner.spinner
            [ Spinner.active True
            , Spinner.singleColor True
            , css "vertical-align" "middle"
            , css "margin" "2px 0"
            ]
        ]
