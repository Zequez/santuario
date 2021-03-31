module Turnos.Main exposing (..)

import Browser
import Date exposing (Date)
import Dict exposing (Dict)
import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import Time exposing (Posix)
import Utils.Utils exposing (dictFromRecordLike)


type alias UUID =
    String


type alias State =
    { startDate : Date
    , currentDate : Date
    , startHour : Int
    , endHour : Int
    , timeSlots : Dict UUID TimeSlot
    , startOfDay : Int
    , endOfDay : Int
    , subjects : Dict UUID Subject
    , turnos : Dict UUID Turno
    , editingTurno : Maybe UUID
    , editingSubject : Maybe UUID
    , weekDays : List Int
    }


type alias TimeSlot =
    { id : String
    , from : Posix
    , to : Posix
    }


type alias Subject =
    { id : String
    , title : String
    , color : String
    , price : Int
    , timeInMinutes : Int
    }


type alias Turno =
    { id : String
    , person : String
    , subject : String
    , coupon : String
    , pays : Int
    , timeSlot : String
    }



-- daysInWeek =
--     7
-- type alias WeeklyTimeSlotTemplate =
--     List DayTimeSlotTemplate


dayLength =
    60 * 60 * 24



-- type alias DayTimeSlotTemplate =
--     List TimeSlot


minFractionSize =
    60 * 15


type Msg
    = ReceiveCurrentTime Posix
    | SetStartDay Posix
    | SetStartOfDay Int
    | SetEndOfDay Int
    | EditTurno UUID
    | SaveTurno
    | CancelEditTurno
    | EditSubject UUID
    | SaveSubject
    | CancelEditSubject


init : Flags -> ( State, Cmd Msg )
init _ =
    ( { startDate = Date.fromCalendarDate 2021 Time.Mar 29
      , currentDate = Date.fromCalendarDate 2021 Time.Mar 31
      , startHour = 10
      , endHour = 20
      , timeSlots = dictFromRecordLike []
      , startOfDay = 0
      , endOfDay = dayLength
      , subjects = dictFromRecordLike [ tratamiento1, tratamiento2, tratamiento3 ]
      , turnos = dictFromRecordLike []
      , editingTurno = Nothing
      , editingSubject = Nothing
      , weekDays = [ 1, 2, 3, 4, 5, 6, 7 ]
      }
    , Cmd.none
    )


update : Msg -> State -> ( State, Cmd Msg )
update msg state =
    ( state, Cmd.none )


daysInitials =
    [ "L", "M", "M", "J", "V", "S", "D" ]


view : State -> Html Msg
view state =
    div [ class "bg-gray-100 h-full text-gray-800" ]
        [ div [ class "container mx-auto max-w-lg" ]
            [ div [ class "text-4xl p-4 font-semibold tracking-wide" ] [ text "Gestor de turnos" ]
            , div [ class "p-4 text-xl font-bold" ] [ text "29 Mar - 4 Abr" ]
            , div [ class "grid grid-cols-8 text-center", style "grid-gap" "1px" ]
                ((div [ class "bg-gray-400" ] [ text "" ]
                    :: (daysInitials
                            |> List.map (\day -> div [ class "bg-gray-300 font-bold" ] [ text day ])
                       )
                 )
                    ++ ((List.range state.startHour state.endHour
                            |> List.map hoursRowView
                        )
                            |> List.foldr (++) []
                       )
                )
            ]
        ]


hoursRowView : Int -> List (Html Msg)
hoursRowView hour =
    div [ class "bg-gray-700 text-white text-sm h-10 flex items-center" ] [ text (String.fromInt hour ++ ":00") ]
        :: (List.range 1 7
                |> List.map (\_ -> hourSlotView)
           )


hourSlotView : Html Msg
hourSlotView =
    div [ class "bg-gray-300 font-bold" ] [ text "" ]


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


tratamiento1 : Subject
tratamiento1 =
    { id = "1"
    , title = "Rojo"
    , color = "red"
    , price = 300
    , timeInMinutes = 30
    }


tratamiento2 : Subject
tratamiento2 =
    { id = "2"
    , title = "Azul"
    , color = "blue"
    , price = 150
    , timeInMinutes = 15
    }


tratamiento3 : Subject
tratamiento3 =
    { id = "3"
    , title = "Azul"
    , color = "blue"
    , price = 150
    , timeInMinutes = 15
    }
