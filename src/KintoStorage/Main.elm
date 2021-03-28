module KintoStorage.Main exposing (..)

import Agent.SignIn as SignIn
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



-- type alias Player =
--     { name : String
--     , needs : List Need
--     }
-- type alias Model =
--     Page


type Model
    = SignInPage SignIn.Model
    | NeedsPage NeedsModel


type alias NeedsModel =
    { needs : List Need
    , connectionStatus : ConnectionStatus
    , newNeedDescription : String
    , timeZone : Time.Zone
    , timePosix : Posix
    , auth : Kinto.Auth
    }


type ConnectionStatus
    = Loading
    | Error
    | Loaded


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    wrapInit SignInPage SignInMsg SignIn.init


wrapInit : (model -> Model) -> (msg -> Msg) -> ( model, Cmd msg ) -> ( Model, Cmd Msg )
wrapInit modelWrap msgWrap ( model, cmd ) =
    ( modelWrap model, Cmd.map msgWrap cmd )


needsInit : Kinto.Auth -> ( Model, Cmd Msg )
needsInit auth =
    ( NeedsPage
        { needs = []
        , connectionStatus = Loading
        , newNeedDescription = ""
        , timePosix = Time.millisToPosix 0
        , timeZone = Time.utc
        , auth = auth
        }
    , Cmd.batch
        [ Cmd.map NeedsMsg (getNeedsList (client auth))
        , Cmd.map NeedsMsg getTime
        ]
    )


getTime : Cmd NeedsMsg
getTime =
    Task.perform identity (Task.map2 SetTime Time.here Time.now)



-- ███╗   ███╗███████╗ ██████╗
-- ████╗ ████║██╔════╝██╔════╝
-- ██╔████╔██║███████╗██║  ███╗
-- ██║╚██╔╝██║╚════██║██║   ██║
-- ██║ ╚═╝ ██║███████║╚██████╔╝
-- ╚═╝     ╚═╝╚══════╝ ╚═════╝


type Msg
    = SignInMsg SignIn.Msg
    | NeedsMsg NeedsMsg


type NeedsMsg
    = NeedAdded (Result Kinto.Error Need)
    | NeedsFetched (Result Kinto.Error (Kinto.Pager Need))
    | NeedDeleted (Result Kinto.Error String)
    | NewNeedChange String
    | NewNeedSubmit
    | NewNeedSubmitTimed Posix
    | NeedDelete String
    | SetTime Time.Zone Posix


type ContextMsg
    = GotoPage ( Model, Cmd Msg )
    | DoNothing


addNeed : Kinto.Client -> Need -> Cmd NeedsMsg
addNeed kintoClient need =
    kintoClient
        |> Kinto.create resourceNeed
            (encodeNeed need)
            NeedAdded
        |> Kinto.send



-- Task.attempt (Task.andThen (addNeed newNeed >> Task.succeed) Time.now)


deleteNeed : Kinto.Client -> String -> Cmd NeedsMsg
deleteNeed kintoClient id =
    kintoClient
        |> Kinto.delete resourceDeletedNeedId id NeedDeleted
        |> Kinto.send


getNeedsList : Kinto.Client -> Cmd NeedsMsg
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


wrapUpdate : (model -> Model) -> (msg -> Msg) -> ( model, Cmd msg, ContextMsg ) -> ( Model, Cmd Msg )
wrapUpdate modelWrap msgWrap ( model, cmd, contextMsg ) =
    case contextMsg of
        GotoPage ( newModel, newMsg ) ->
            ( newModel, newMsg )

        DoNothing ->
            ( modelWrap model, Cmd.map msgWrap cmd )


andDoNothing : model -> ( model, Cmd msg, ContextMsg )
andDoNothing model =
    ( model, Cmd.none, DoNothing )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( SignInMsg subMsg, SignInPage subModel ) ->
            (case SignIn.update client subMsg subModel of
                ( newSubModel, newSubMsg, SignIn.NoOp ) ->
                    ( newSubModel, newSubMsg, DoNothing )

                ( newSubModel, newSubMsg, SignIn.Authenticated auth ) ->
                    ( newSubModel, newSubMsg, GotoPage (needsInit auth) )
            )
                |> wrapUpdate SignInPage SignInMsg

        ( NeedsMsg subMsg, NeedsPage subModel ) ->
            let
                kintoClient =
                    client subModel.auth
            in
            (case subMsg of
                NeedAdded (Ok need) ->
                    { subModel
                        | needs =
                            subModel.needs
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
                    subModel |> andDoNothing

                NeedsFetched (Ok needPager) ->
                    { subModel | needs = needPager.objects, connectionStatus = Loaded }
                        |> andDoNothing

                NeedsFetched (Err err) ->
                    -- let
                    --     _ =
                    --         Debug.log "Error while getting list of `need` records" err
                    -- in
                    { subModel | connectionStatus = Error }
                        |> andDoNothing

                NeedDeleted (Ok need) ->
                    subModel |> andDoNothing

                NeedDeleted (Err err) ->
                    -- let
                    --     _ =
                    --         Debug.log "Failed to delete need" err
                    -- in
                    subModel |> andDoNothing

                NewNeedChange description ->
                    { subModel | newNeedDescription = description }
                        |> andDoNothing

                NewNeedSubmit ->
                    ( subModel, Task.perform NewNeedSubmitTimed Time.now, DoNothing )

                NewNeedSubmitTimed posix ->
                    let
                        newNeed =
                            { emptyNeed | description = subModel.newNeedDescription, createdAt = posix }
                    in
                    ( { subModel
                        | newNeedDescription = ""
                        , needs = newNeed :: subModel.needs
                      }
                    , addNeed kintoClient newNeed
                    , DoNothing
                    )

                NeedDelete id ->
                    ( { subModel
                        | needs =
                            subModel.needs
                                |> removeNeedById id
                      }
                    , deleteNeed kintoClient id
                    , DoNothing
                    )

                SetTime zone posix ->
                    { subModel | timeZone = zone, timePosix = posix }
                        |> andDoNothing
            )
                |> wrapUpdate NeedsPage NeedsMsg

        ( _, _ ) ->
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
        , case model of
            NeedsPage subModel ->
                Html.map NeedsMsg (needsView subModel)

            SignInPage subModel ->
                Html.map SignInMsg (SignIn.view subModel)
        ]


needsView : NeedsModel -> Html NeedsMsg
needsView model =
    div []
        [ div [ class "text-2xl mb-4 tracking-wide" ] [ text "List of needs" ]
        , case model.connectionStatus of
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


needView : Need -> Html NeedsMsg
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


newNeedView : String -> Html NeedsMsg
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
