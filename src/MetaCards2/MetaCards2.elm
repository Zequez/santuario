module MetaCards2.MetaCards2 exposing (..)

import Browser
import Components.BackHeader as BackHeader
import Dict exposing (Dict)
import Html exposing (Html, a, br, button, div, h2, img, input, node, option, p, select, span, text)
import Html.Attributes exposing (attribute, class, classList, href, placeholder, src, style, target, title, value)
import Html.Events exposing (on, onClick, onInput)
import List.Extra
import Time


type alias Model =
    { board : Board
    }


type alias Player =
    { id : String
    , alias : String
    , cards : List Card
    , trust : List String -- List of Player ID
    }


type CardEvent
    = CreateCard
    | UpdateCard
    | DeleteCard
    | ForkCard



-- type alias PlayingWithPlayer =
--     { player : Player
--     , recognize : List Card
--     }


type alias Board =
    { players : List Player
    , cards : List Card
    , playingAs : String -- Player ID
    , editing : String -- Card ID
    , playerWeight : List String -- List of Player ID
    }


type alias Card =
    { id : String
    , managedBy : List String -- Player ID
    , color : String
    , name : String
    }


computePlayersWeight : List Player -> List Player -> Dict String Int
computePlayersWeight trustedPlayers excludePlayers =



addPlayersWeight : List Player -> Dict String Int -> Dict String Int
addPlayersWeight trustedPlayers playersWeight =
    trustedPlayers
        |> List.map (\player -> p.id)


addPlayerWeight : String -> Dict String Int -> Dict String Int
addPlayerWeight playerId playersWeight =
    playersWeight
        |> Dict.update playerId
            (\playerWeight ->
                case playerWeight of
                    Just weight ->
                        Just (weight + 1)

                    Nothing ->
                        Just 1
            )


getCardsManagedByPlayer : String -> List Card -> List Card
getCardsManagedByPlayer playerId cards =
    cards
        |> List.filter (.managedBy >> List.member playerId)


getPlayersManagingCard : Card -> List Player -> List Player
getPlayersManagingCard card players =
    card.managedBy
        |> List.filterMap
            (\id ->
                players
                    |> List.Extra.find (\p -> p.id == id)
            )



-- isCardManagedByPlayer : String -> Card -> Bool
-- isCardManagedByPlayer playerId card =
--     card.managedBy
--         |> List.member playerId
-- type alias ColorCard extends


init : ( Model, Cmd Msg )
init =
    ( { cards = [] }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.document
        { init = always init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


type Msg
    = Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Meta cards experiment"
        [ BackHeader.view "Meta cards experiment"
        , div [ class "text-white p-4" ]
            [ div [ class "text-3xl mb-4" ] [ text "Cards" ]
            , div [ class "grid grid-cols-2 gap-4" ] []
            ]
        ]
