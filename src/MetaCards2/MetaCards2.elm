module MetaCards2.MetaCards2 exposing (..)

import Browser
import Components.BackHeader as BackHeader
import Html exposing (Html, a, br, button, div, h2, img, input, node, option, p, select, span, text)
import Html.Attributes exposing (attribute, class, classList, href, placeholder, src, style, target, title, value)
import Html.Events exposing (on, onClick, onInput)
import Time


type alias Model =
    { cards : List Card
    }


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


type alias Card =
    { color : String
    }
