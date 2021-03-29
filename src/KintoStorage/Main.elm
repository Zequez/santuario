module KintoStorage.Main exposing (..)

import Agent.SignIn as Agent
import Browser
import EnvConstants
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import FontAwesome.Styles
import Html exposing (Html, a, br, button, code, div, h2, hr, img, input, option, p, select, span, text)
import Html.Attributes exposing (class, classList, disabled, href, placeholder, src, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE
import Kinto
import Task
import Time exposing (Posix)
import Ui.Ui as Ui
import Utils.Utils exposing (classFocusRing, classInput, onEnter)



-- ████████╗██╗   ██╗██████╗ ███████╗███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
--    ██║      ██║   ██║     ███████╗███████║
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝


type alias Need =
    { id : Maybe String
    , description : String
    , createdAt : Posix
    , isMet : Bool
    , metBy : String
    }


dbCollectionNeed =
    "needs"


decodeNeed : JD.Decoder Need
decodeNeed =
    JD.map5 Need
        (JD.at [ "id" ] (JD.maybe JD.string))
        (JD.at [ "description" ] JD.string)
        (JD.map
            (Maybe.withDefault (Time.millisToPosix 0))
            (JD.maybe (JD.field "createdAt" decodePosix))
        )
        (JD.at [ "isMet" ] JD.bool)
        (JD.at [ "metBy" ] JD.string)


decodeId : JD.Decoder String
decodeId =
    JD.field "id" JD.string


decodePosix : JD.Decoder Posix
decodePosix =
    JD.map Time.millisToPosix JD.int


encodeNeed : Need -> JE.Value
encodeNeed need =
    JE.object
        [ ( "description", JE.string need.description )
        , ( "createdAt", JE.int (Time.posixToMillis need.createdAt) )
        , ( "isMet", JE.bool need.isMet )
        , ( "metBy", JE.string need.metBy )
        ]


resourceNeed : Kinto.Resource Need
resourceNeed =
    Kinto.recordResource dbBucket dbCollectionNeed decodeNeed


resourceDeletedNeedId : Kinto.Resource String
resourceDeletedNeedId =
    Kinto.recordResource dbBucket dbCollectionNeed decodeId


emptyNeed : Need
emptyNeed =
    { id = Nothing
    , description = ""
    , createdAt = Time.millisToPosix 0
    , isMet = False
    , metBy = ""
    }


type alias Model =
    { needs : List Need
    , needsLoadingStatus : NeedsLoadingStatus
    , newNeedDescription : String
    , timeZone : Time.Zone
    , timePosix : Posix
    , user : String
    , auth : Maybe Kinto.Auth
    }


type NeedsLoadingStatus
    = NotAsked
    | Loading
    | Error
    | Loaded


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { needs = []
      , needsLoadingStatus = NotAsked
      , newNeedDescription = ""
      , timePosix = Time.millisToPosix 0
      , timeZone = Time.utc
      , user = ""
      , auth = Nothing
      }
    , Cmd.none
    )


getTime : Cmd Msg
getTime =
    Task.perform identity (Task.map2 SetTime Time.here Time.now)



-- ███╗   ███╗███████╗ ██████╗
-- ████╗ ████║██╔════╝██╔════╝
-- ██╔████╔██║███████╗██║  ███╗
-- ██║╚██╔╝██║╚════██║██║   ██║
-- ██║ ╚═╝ ██║███████║╚██████╔╝
-- ╚═╝     ╚═╝╚══════╝ ╚═════╝


type Msg
    = NeedAdded (Result Kinto.Error Need)
    | NeedsFetch
    | NeedsFetched (Result Kinto.Error (Kinto.Pager Need))
    | NeedDeleted (Result Kinto.Error String)
    | NewNeedChange String
    | NewNeedSubmit
    | NewNeedSubmitTimed Posix
    | NeedDelete String
    | SetTime Time.Zone Posix
    | Authenticated ( String, String )
    | LoggedOut


addNeed : Kinto.Client -> Need -> Cmd Msg
addNeed kintoClient need =
    kintoClient
        |> Kinto.create resourceNeed
            (encodeNeed need)
            NeedAdded
        |> Kinto.send


deleteNeed : Kinto.Client -> String -> Cmd Msg
deleteNeed kintoClient id =
    kintoClient
        |> Kinto.delete resourceDeletedNeedId id NeedDeleted
        |> Kinto.send


getNeedsList : Kinto.Client -> Cmd Msg
getNeedsList kintoClient =
    kintoClient
        |> Kinto.getList resourceNeed NeedsFetched
        |> Kinto.sort [ "-createdAt" ]
        |> Kinto.send



-- ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗
-- ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
-- ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗
-- ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝
-- ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗
--  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝


andDoNothing : model -> ( model, Cmd msg )
andDoNothing model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.auth of
        Nothing ->
            case msg of
                Authenticated ( user, pass ) ->
                    let
                        auth =
                            Kinto.Basic user pass

                        -- _ =
                        --     Debug.log "Authenticated yeah!" (user ++ ":" ++ pass)
                    in
                    ( { model | user = user, auth = Just auth, needsLoadingStatus = Loading }
                    , getNeedsList (client auth)
                    )

                _ ->
                    -- let
                    --     _ =
                    --         Debug.log "Not authentiated cat't do that" msg
                    -- in
                    ( model, Cmd.none )

        Just auth ->
            let
                kintoClient =
                    client auth
            in
            case msg of
                LoggedOut ->
                    ( { model | user = "", auth = Nothing }, Cmd.none )

                NeedAdded (Ok need) ->
                    { model
                        | needs =
                            model.needs
                                |> List.map
                                    (\n ->
                                        if n.id == Nothing && n.description == need.description then
                                            { n | id = need.id }

                                        else
                                            n
                                    )
                    }
                        |> andDoNothing

                NeedAdded (Err err) ->
                    -- let
                    --     _ =
                    --         Debug.log "Error while creating `need` record" err
                    -- in
                    model |> andDoNothing

                NeedsFetch ->
                    ( model, getNeedsList kintoClient )

                NeedsFetched (Ok needPager) ->
                    { model | needs = needPager.objects, needsLoadingStatus = Loaded }
                        |> andDoNothing

                NeedsFetched (Err err) ->
                    -- let
                    --     _ =
                    --         Debug.log "Error while getting list of `need` records" err
                    -- in
                    { model | needsLoadingStatus = Error }
                        |> andDoNothing

                NeedDeleted (Ok need) ->
                    model |> andDoNothing

                NeedDeleted (Err err) ->
                    -- let
                    --     _ =
                    --         Debug.log "Failed to delete need" err
                    -- in
                    model |> andDoNothing

                NewNeedChange description ->
                    { model | newNeedDescription = description }
                        |> andDoNothing

                NewNeedSubmit ->
                    ( model, Task.perform NewNeedSubmitTimed Time.now )

                NewNeedSubmitTimed posix ->
                    let
                        newNeed =
                            { emptyNeed | description = model.newNeedDescription, createdAt = posix }
                    in
                    ( { model
                        | newNeedDescription = ""
                        , needs = newNeed :: model.needs
                      }
                    , addNeed kintoClient newNeed
                    )

                NeedDelete id ->
                    ( { model
                        | needs =
                            model.needs
                                |> removeNeedById id
                      }
                    , deleteNeed kintoClient id
                    )

                SetTime zone posix ->
                    { model | timeZone = zone, timePosix = posix }
                        |> andDoNothing

                _ ->
                    ( model, Cmd.none )



-- mapCmdModel :


removeNeedById : String -> List Need -> List Need
removeNeedById id needs =
    needs
        |> List.filter
            (\n ->
                case n.id of
                    Just needId ->
                        needId /= id

                    Nothing ->
                        True
            )



-- ██╗   ██╗██╗███████╗██╗    ██╗███████╗
-- ██║   ██║██║██╔════╝██║    ██║██╔════╝
-- ██║   ██║██║█████╗  ██║ █╗ ██║███████╗
-- ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║╚════██║
--  ╚████╔╝ ██║███████╗╚███╔███╔╝███████║
--   ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚══════╝


view : Model -> Html Msg
view model =
    div [ class "p-8 bg-gray-100 min-h-full" ]
        [ FontAwesome.Styles.css
        , case model.auth of
            Just auth ->
                needsView model

            Nothing ->
                Agent.element EnvConstants.kintoHost Authenticated LoggedOut
        ]


needsView : Model -> Html Msg
needsView model =
    div []
        [ div [ class "text-2xl mb-4 tracking-wide" ] [ text "List of needs" ]
        , case model.needsLoadingStatus of
            NotAsked ->
                div [ class "text-xl text-gray-400" ]
                    [ text "We haven't fetched the list of needs yet..."
                    , Ui.primaryButton [ onClick NeedsFetch ] [ text "Do that" ]
                    ]

            Loading ->
                div [ class "text-xl text-gray-400" ] [ text "List of needs is loading..." ]

            Error ->
                div [ class "text-xl text-gray-400" ] [ text "Oops, looks like stuff could not be loaded." ]

            Loaded ->
                div []
                    [ if List.isEmpty model.needs then
                        div [ class "text-xl text-gray-400" ]
                            [ text "Seems like all your needs are met."
                            ]

                      else
                        div []
                            (model.needs
                                |> List.reverse
                                |> List.map needView
                            )
                    , newNeedView model.newNeedDescription
                    ]
        ]


needView : Need -> Html Msg
needView need =
    div [ class "flex h-12 mb-2" ]
        [ div [ class "flex-grow bg-white py-2 px-4 rounded-md shadow-sm flex items-center" ] [ text need.description ]
        , case need.id of
            Just id ->
                button
                    [ class "w-8 p-2 ml-2 my-2 shadow-sm bg-red-400 text-white rounded-md flex items-center justify-center"
                    , classFocusRing
                    , onClick (NeedDelete id)
                    ]
                    [ Icon.viewIcon Icon.times
                    ]

            Nothing ->
                div
                    [ class "w-8 p-2 ml-2 my-2 text-gray-300 flex items-center justify-center animation-rotate"
                    ]
                    [ Icon.viewIcon Icon.sync
                    ]
        ]


newNeedView : String -> Html Msg
newNeedView description =
    div [ class "flex mt-4 h-12" ]
        [ input
            [ class """flex-grow py-2 px-4
              bg-white rounded-md shadow-sm"""
            , classFocusRing
            , onInput NewNeedChange
            , onEnter NewNeedSubmit
            , placeholder "I need..."
            , value description
            ]
            []
        , button
            [ class "w-12 p-3 ml-2 shadow-sm bg-green-500 text-white rounded-md "
            , classFocusRing
            , onClick NewNeedSubmit
            ]
            [ Icon.viewIcon Icon.paperPlane
            ]
        ]



--  ██████╗ ████████╗██╗  ██╗███████╗██████╗
-- ██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
-- ██║   ██║   ██║   ███████║█████╗  ██████╔╝
-- ██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
-- ╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
--  ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


dbBucket =
    "default"


client : Kinto.Auth -> Kinto.Client
client auth =
    Kinto.client EnvConstants.kintoHost auth
