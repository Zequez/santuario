module Agent.SignIn exposing (..)

import Browser
import Elmception.Elmception as Elmception
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, a, button, code, div, input, text)
import Html.Attributes exposing (attribute, class, disabled, placeholder, type_, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as D
import Json.Encode as E
import Kinto
import Utils.Utils exposing (classFocusRing, classInput, iif)


main : Program Params (Elmception.Model Params State) Msg
main =
    Elmception.element
        { init = init
        , update = update
        , eventEncoder = eventEncoder
        , view = view
        }


type alias Params =
    { kintoKeys : String
    , storage : Maybe Storage
    }


type alias Storage =
    { user : String
    , password : String
    }


type alias State =
    { user : String
    , password : String
    , passwordConfirmation : String
    , signInStatus : Status
    , signUp : Bool
    }


type Status
    = NotSubmitted
    | SubmittingLocalAuth
    | Submitting
    | SubmittedError String String
    | Authenticated


empty =
    State "" "" "" NotSubmitted False


decodeUserId : D.Decoder (Maybe String)
decodeUserId =
    D.maybe (D.at [ "user", "id" ] D.string)


userIdResource : Kinto.Resource (Maybe String)
userIdResource =
    Kinto.Resource (\_ -> Kinto.RootEndpoint) Kinto.RootEndpoint decodeUserId (D.succeed [])


requestKintoAgentInfo : Kinto.Client -> Cmd Msg
requestKintoAgentInfo kintoClient =
    kintoClient
        |> Kinto.get userIdResource "" SubmitResponse
        |> Kinto.send


init : Params -> ( State, Cmd Msg, List Event )
init params =
    let
        storedUser =
            params.storage
                |> Maybe.andThen (\s -> Just s.user)

        storedPass =
            params.storage
                |> Maybe.andThen (\s -> Just s.password)

        localAuthData =
            storedUser /= Nothing && storedPass /= Nothing
    in
    ( { user = Maybe.withDefault "" storedUser
      , password = Maybe.withDefault "" storedPass
      , passwordConfirmation = ""
      , signInStatus =
            if localAuthData then
                SubmittingLocalAuth

            else
                NotSubmitted
      , signUp = False
      }
    , case ( storedUser, storedPass ) of
        ( Just user, Just pass ) ->
            requestKintoAgentInfo (Kinto.client params.kintoKeys (Kinto.Basic user pass))

        ( _, _ ) ->
            Cmd.none
    , []
    )


type Msg
    = WriteUser String
    | WritePassword String
    | WritePasswordConfirmation String
    | ToggleSignUp
    | Submit
    | SubmitResponse (Result Kinto.Error (Maybe String))
    | RequestLogout



-- Elmception events


type Event
    = Save State
    | AgentKeys ( String, String )
    | Logout


update : Params -> Msg -> State -> ( State, Cmd Msg, List Event )
update params msg state =
    case msg of
        RequestLogout ->
            let
                newState =
                    { state | signInStatus = NotSubmitted, password = "", passwordConfirmation = "" }
            in
            ( newState, Cmd.none, [ Save newState, Logout ] )

        WriteUser user ->
            let
                newState =
                    { state | user = user }
            in
            ( newState, Cmd.none, [] )

        WritePassword password ->
            { state | password = password } |> andDoNothing

        WritePasswordConfirmation password ->
            { state | passwordConfirmation = password } |> andDoNothing

        ToggleSignUp ->
            { state | signUp = not state.signUp } |> andDoNothing

        Submit ->
            let
                kintoAuth =
                    Kinto.Basic state.user state.password
            in
            ( { state | signInStatus = Submitting }
            , requestKintoAgentInfo (Kinto.client params.kintoKeys kintoAuth)
            , []
            )

        SubmitResponse (Ok maybeUserId) ->
            case maybeUserId of
                Just userId ->
                    ( { state | signInStatus = Authenticated }
                    , Cmd.none
                    , [ Save state, AgentKeys ( state.user, state.password ) ]
                    )

                Nothing ->
                    if state.signUp then
                        { state | signInStatus = SubmittedError "Account with that name already exists" "" }
                            |> andDoNothing

                    else
                        { state | signInStatus = SubmittedError "Incorrect username or password" "" }
                            |> andDoNothing

        SubmitResponse (Err err) ->
            { state | signInStatus = SubmittedError "Oops, server error (email me to zequez@gmail.com)" (Kinto.errorToString err) }
                |> andDoNothing


andDoNothing : state -> ( state, Cmd m, List Event )
andDoNothing state =
    ( state, Cmd.none, [] )



-- ██╗   ██╗██╗███████╗██╗    ██╗
-- ██║   ██║██║██╔════╝██║    ██║
-- ██║   ██║██║█████╗  ██║ █╗ ██║
-- ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║
--  ╚████╔╝ ██║███████╗╚███╔███╔╝
--   ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝


view : Params -> State -> Html Msg
view params state =
    case state.signInStatus of
        SubmittingLocalAuth ->
            div [] [ text "Checking if the credentials saved on this device are still valid..." ]

        Authenticated ->
            div []
                [ text "Successfully authenticated!"
                , button
                    [ class "uppercase ml-4 px-4 py-2 font-semibold bg-green-500 rounded-md text-white"
                    , onClick RequestLogout
                    ]
                    [ text "Logout" ]
                ]

        _ ->
            let
                disableInputs =
                    disabled (state.signInStatus == Submitting)
            in
            div [ class "container mx-auto max-w-md" ]
                [ div [ class "text-2xl mb-4 tracking-wide" ] [ text "Sign in" ]
                , input
                    [ value state.user
                    , onInput WriteUser
                    , placeholder "User"
                    , classInput
                    , classFocusRing
                    , disableInputs
                    ]
                    []
                , input
                    [ value state.password
                    , type_ "password"
                    , onInput WritePassword
                    , placeholder "Password"
                    , classInput
                    , classFocusRing
                    , disableInputs
                    ]
                    []
                , if state.signUp then
                    input
                        [ value state.passwordConfirmation
                        , type_ "password"
                        , onInput WritePasswordConfirmation
                        , placeholder "Password confirmation"
                        , classInput
                        , classFocusRing
                        , disableInputs
                        ]
                        []

                  else
                    div [] []
                , div [ class "flex justify-end items-center" ]
                    [ if state.signInStatus == Submitting then
                        div [ class "text-gray-500 flex text-2xl animation-rotate animation-slower mr-4" ]
                            [ Icon.viewIcon Icon.cog
                            ]

                      else
                        a
                            [ class "mr-2 text-yellow-500 cursor-pointer"
                            , onClick ToggleSignUp
                            ]
                            [ text (iif state.signUp "Sign in" "Sign up" ++ " instead?") ]
                    , button
                        [ class "bg-yellow-500 text-white py-2 px-4 rounded-md font-bold tracking-wide uppercase disabled:opacity-50"
                        , classFocusRing
                        , disableInputs
                        , onClick Submit
                        , disabled
                            ((state.signInStatus == Submitting)
                                || (state.user == "")
                                || (state.password == "")
                                || (state.signUp && state.password /= state.passwordConfirmation)
                            )
                        ]
                        [ text (iif state.signUp "Sign up" "Sign in") ]
                    ]
                , case state.signInStatus of
                    SubmittedError err errDetails ->
                        div [ class "bg-red-300 px-4 py-2 mt-4 text-white rounded-md ring-2 ring-red-300" ]
                            [ div [] [ text err ]
                            , if errDetails /= "" then
                                code [ class "text-sm" ] [ text errDetails ]

                              else
                                div [] []
                            ]

                    _ ->
                        div [] []
                ]



-- ███████╗██╗     ███╗   ███╗ ██████╗███████╗██████╗ ████████╗██╗ ██████╗ ███╗   ██╗
-- ██╔════╝██║     ████╗ ████║██╔════╝██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║
-- █████╗  ██║     ██╔████╔██║██║     █████╗  ██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║
-- ██╔══╝  ██║     ██║╚██╔╝██║██║     ██╔══╝  ██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║
-- ███████╗███████╗██║ ╚═╝ ██║╚██████╗███████╗██║        ██║   ██║╚██████╔╝██║ ╚████║
-- ╚══════╝╚══════╝╚═╝     ╚═╝ ╚═════╝╚══════╝╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝


element : String -> (( String, String ) -> msg) -> msg -> Html msg
element keys agentKeysMsg logoutMsg =
    htmlElement
        [ kintoKeys keys
        , onAgentKeys agentKeysMsg
        , onLogout logoutMsg
        ]
        []


htmlElement : List (Attribute msg) -> List (Html msg) -> Html msg
htmlElement =
    Html.node "agent-signin"


kintoKeys : String -> Attribute msg
kintoKeys =
    attribute "kinto-keys"


onAgentKeys : (( String, String ) -> msg) -> Attribute msg
onAgentKeys eventListener =
    on "AgentKeys"
        (D.map eventListener
            (D.field "detail"
                (D.map2 Tuple.pair
                    (D.index 0 D.string)
                    (D.index 1 D.string)
                )
            )
        )


onLogout : msg -> Attribute msg
onLogout msg =
    on "Logout" (D.succeed msg)


decoder : D.Decoder Storage
decoder =
    D.map2 Storage
        (D.field "user" D.string)
        (D.field "password" D.string)


encoder : State -> E.Value
encoder state =
    E.object
        [ ( "user", E.string state.user )
        , ( "password", E.string state.password )
        ]


eventEncoder : Event -> E.Value
eventEncoder event =
    case event of
        Save state ->
            E.object
                [ ( "event", E.string "Save" )
                , ( "payload", encoder state )
                ]

        AgentKeys ( v1, v2 ) ->
            E.object
                [ ( "event", E.string "AgentKeys" )
                , ( "payload", E.list identity [ E.string v1, E.string v2 ] )
                ]

        Logout ->
            E.object [ ( "event", E.string "Logout" ), ( "payload", E.null ) ]
