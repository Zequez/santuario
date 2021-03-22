module KintoStorage.Main exposing (..)

import Browser
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html, a, br, button, div, h2, hr, img, input, option, p, select, span, text)
import Html.Attributes exposing (class, classList, href, placeholder, src, style, target, title, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE
import Kinto
import List.Extra



-- ████████╗██╗   ██╗██████╗ ███████╗███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
--    ██║      ██║   ██║     ███████╗███████║
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝


type alias Need =
    { id : Maybe String
    , description : String
    , isMet : Bool
    , metBy : String
    }


dbCollectionNeed =
    "needs"


decodeNeed : JD.Decoder Need
decodeNeed =
    JD.map4 Need
        (JD.at [ "id" ] (JD.maybe JD.string))
        (JD.at [ "description" ] JD.string)
        (JD.at [ "isMet" ] JD.bool)
        (JD.at [ "metBy" ] JD.string)


encodeNeed : Need -> JE.Value
encodeNeed need =
    JE.object
        [ ( "description", JE.string need.description )
        , ( "isMet", JE.bool need.isMet )
        , ( "metBy", JE.string need.metBy )
        ]


resourceNeed : Kinto.Resource Need
resourceNeed =
    Kinto.recordResource dbBucket dbCollectionNeed decodeNeed



-- type alias Player =
--     { name : String
--     , needs : List Need
--     }


type alias Model =
    { needs : List Need
    , newNeedDescription : String
    }


type alias Flags =
    {}


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { needs = [], newNeedDescription = "" }
    , Cmd.batch
        [ getNeedsList
        ]
    )



-- ███╗   ███╗███████╗ ██████╗
-- ████╗ ████║██╔════╝██╔════╝
-- ██╔████╔██║███████╗██║  ███╗
-- ██║╚██╔╝██║╚════██║██║   ██║
-- ██║ ╚═╝ ██║███████║╚██████╔╝
-- ╚═╝     ╚═╝╚══════╝ ╚═════╝


type Msg
    = NeedAdded (Result Kinto.Error Need)
    | NeedsFetched (Result Kinto.Error (Kinto.Pager Need))
    | NeedDeleted (Result Kinto.Error Need)
    | NewNeedChange String
    | NewNeedSubmit
    | NeedDelete String


addNeed : String -> Cmd Msg
addNeed description =
    client
        |> Kinto.create resourceNeed
            (encodeNeed
                { id = Nothing
                , description = description
                , isMet = False
                , metBy = ""
                }
            )
            NeedAdded
        |> Kinto.send


deleteNeed : String -> Cmd Msg
deleteNeed id =
    client
        |> Kinto.delete resourceNeed id NeedDeleted
        |> Kinto.send


getNeedsList : Cmd Msg
getNeedsList =
    client
        |> Kinto.getList resourceNeed NeedsFetched
        |> Kinto.sort [ "description" ]
        |> Kinto.send



-- ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗
-- ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
-- ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗
-- ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝
-- ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗
--  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NeedAdded (Ok need) ->
            ( { model | needs = need :: model.needs }, Cmd.none )

        NeedAdded (Err err) ->
            let
                _ =
                    Debug.log "Error while creating `need` record" err
            in
            ( model, Cmd.none )

        NeedsFetched (Ok needPager) ->
            ( { model | needs = needPager.objects }, Cmd.none )

        NeedsFetched (Err err) ->
            let
                _ =
                    Debug.log "Error while getting list of `need` records" err
            in
            ( model, Cmd.none )

        NeedDeleted (Ok need) ->
            ( model, Cmd.none )

        NeedDeleted (Err err) ->
            let
                _ =
                    Debug.log "Failed to delete need" err
            in
            ( model, Cmd.none )

        NewNeedChange description ->
            ( { model | newNeedDescription = description }, Cmd.none )

        NewNeedSubmit ->
            ( { model | newNeedDescription = "" }, addNeed model.newNeedDescription )

        NeedDelete id ->
            ( { model
                | needs =
                    model.needs
                        |> List.filter
                            (\n ->
                                case n.id of
                                    Just needId ->
                                        needId /= id

                                    Nothing ->
                                        True
                            )
              }
            , deleteNeed id
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
        [ div [ class "text-2xl mb-4 tracking-wide" ] [ text "List of needs" ]
        , if List.isEmpty model.needs then
            div [ class "text-xl text-gray-400" ]
                [ text "You have no needs, that's alright too."
                ]

          else
            div []
                (model.needs
                    |> List.map needView
                )
        , newNeedView model.newNeedDescription
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
                div [] []
        ]


classFocusRing : Html.Attribute msg
classFocusRing =
    class "focus:outline-none focus:ring focus:ring-green-500 focus:ring-opacity-50"


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
            [ class "w-12 p-3 ml-2 shadow-sm bg-green-500 text-white rounded-md"
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


client : Kinto.Client
client =
    Kinto.client
        "https://kinto.dev.mozaws.net/v1/"
        (Kinto.Basic "test" "test")


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg

            else
                JD.fail "not ENTER"
    in
    on "keydown" (JD.andThen isEnter keyCode)
