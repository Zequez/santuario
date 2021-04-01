module Communities.Main exposing (..)

import Browser
import Communities.Communities exposing (Community, communities)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)


type alias State =
    { communities : List Community
    }


type Msg
    = Noop


init : Flags -> ( State, Cmd Msg )
init _ =
    ( { communities = communities }
    , Cmd.none
    )


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    ( state, Cmd.none )


i18n : String -> Html Msg
i18n key =
    Html.node "st-i18n" [ Html.Attributes.attribute "key" key ] [ text key ]


view : State -> Html Msg
view state =
    div []
        [ div [ class "text-3xl font-light" ] [ i18n "communities" ]
        , div [ class "" ]
            (state.communities
                |> List.map communityView
            )
        ]


communityView : Community -> Html Msg
communityView community =
    div [ class "" ]
        [ text community.name
        ]


type alias Flags =
    {}


main : Program Flags State Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
