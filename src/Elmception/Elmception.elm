port module Elmception.Elmception exposing (..)

import Browser
import Html exposing (Html)
import Json.Encode as E


type alias Model params state =
    { params : params
    , state : state
    }


port reportEvent : E.Value -> Cmd msg


update :
    (params -> msg -> state -> ( state, Cmd msg, List event ))
    -> (event -> E.Value)
    -> msg
    -> Model params state
    -> ( Model params state, Cmd msg )
update updateFunction eventEncoder msg model =
    let
        ( state, cmd, events ) =
            updateFunction model.params msg model.state
    in
    ( { model | state = state }
    , wrapEvents eventEncoder cmd events
    )


init :
    (params -> ( state, Cmd msg, List event ))
    -> (event -> E.Value)
    -> params
    -> ( Model params state, Cmd msg )
init initFunction eventEncoder params =
    let
        ( state, cmd, events ) =
            initFunction params
    in
    ( { params = params
      , state = state
      }
    , wrapEvents eventEncoder cmd events
    )


wrapEvents : (event -> E.Value) -> Cmd msg -> List event -> Cmd msg
wrapEvents eventEncoder cmd events =
    (cmd
        :: (events
                |> List.map (\ev -> reportEvent (eventEncoder ev))
           )
    )
        |> Cmd.batch


type alias ElmceptionElement params state msg event =
    { update : params -> msg -> state -> ( state, Cmd msg, List event )
    , eventEncoder : event -> E.Value
    , view : params -> state -> Html msg
    , init : params -> ( state, Cmd msg, List event )
    }


element : ElmceptionElement params state msg event -> Program params (Model params state) msg
element app =
    Browser.element
        { init = init app.init app.eventEncoder
        , update = update app.update app.eventEncoder
        , subscriptions = always Sub.none
        , view = \model -> app.view model.params model.state
        }
