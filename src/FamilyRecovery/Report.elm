module FamilyRecovery.Report exposing (..)

import Date exposing (Date)
import FamilyRecovery.Animal as Animal
import FamilyRecovery.Card as Card
import FamilyRecovery.Human as Human
import FamilyRecovery.Mapbox as Mapbox
import FamilyRecovery.Utils as Utils
import Html exposing (Html, a, div, img, input, span, text)
import Html.Attributes exposing (class, href, placeholder, src, target, value)
import Time


type alias Report =
    { id : String
    , animal : Animal.Animal
    , humanContact : Human.Human
    , date : Date
    , location : ( Float, Float )
    , notes : String
    , reportType : ReportType
    , resolved : ReportResolution
    }


type ReportResolution
    = Unresolved
    | Resolved ( Date, String ) -- ID of another report


type ReportType
    = Missing
    | Found


type alias ContextualizedReport =
    { report : Report
    , daysAgo : Int
    , kmAway : Maybe Float
    }


type alias GeoLocation =
    Maybe ( Float, Float )


type WriteMsg
    = SetLocation ( Float, Float )
    | SetDate Date
    | SetNotes String
    | SetResolved ReportResolution
    | SetType ReportType


writer : WriteMsg -> Report -> Report
writer writeMsg report =
    case writeMsg of
        SetLocation location ->
            { report | location = location }

        SetDate date ->
            { report | date = date }

        SetNotes notes ->
            { report | notes = notes }

        SetResolved resolvedStatus ->
            { report | resolved = resolvedStatus }

        SetType reportType ->
            { report | reportType = reportType }


shallowCardView : Report -> (( Float, Float ) -> msg) -> Html msg
shallowCardView report updateLocationMsg =
    Card.view "Reporte"
        (div []
            [ Card.row <|
                Card.tagsWrapper
                    [ Card.tagView "Tipo" (text (reportTypeToLabel report.reportType))
                    , Card.tagView "Fecha" (text "8 Feb 2021")
                    ]
            , Card.row <| div [] [ Card.mapView "Lugar" report.location updateLocationMsg ]
            , div [] [ Card.textBoxView "Notas" report.notes ]
            ]
        )



-- type alias SpaceTime =
--     { date : Date
--     , location : ( Float, Float )
--     }
---------------------------------------- ██╗   ██╗██╗███████╗██╗    ██╗███████╗
---------------------------------------- ██║   ██║██║██╔════╝██║    ██║██╔════╝
---------------------------------------- ██║   ██║██║█████╗  ██║ █╗ ██║███████╗
---------------------------------------- ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║╚════██║
----------------------------------------  ╚████╔╝ ██║███████╗╚███╔███╔╝███████║
----------------------------------------   ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚══════╝
---------------------- ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
---------------------- ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
---------------------- ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
---------------------- ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
---------------------- ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
---------------------- ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝


toMapboxMarker : Report -> Mapbox.ImageMarker
toMapboxMarker report =
    { src = Maybe.withDefault "" (List.head report.animal.photos)
    , lat = Tuple.first report.location
    , lng = Tuple.second report.location
    , id = report.id
    }


reportTypeToLabel : ReportType -> String
reportTypeToLabel reportType =
    case reportType of
        Missing ->
            "Perdide"

        Found ->
            "Encontrade"


contextualize : Date -> GeoLocation -> Report -> ContextualizedReport
contextualize today geolocation report =
    { report = report
    , daysAgo = Utils.daysBetweenDates report.date today
    , kmAway = Maybe.map (Utils.distanceBetweenPoints report.location) geolocation
    }


findById : String -> List ContextualizedReport -> Maybe ContextualizedReport
findById id cReports =
    cReports
        |> List.filter (\cr2 -> cr2.report.id == id)
        |> List.head


empty : Report
empty =
    { id = ""
    , animal = Animal.empty
    , humanContact = Human.empty
    , date = Date.fromCalendarDate 2021 Time.Jan 1
    , location = ( -38.0631442, -57.5572745 )
    , notes = ""
    , reportType = Missing
    , resolved = Unresolved
    }


data1 : Report
data1 =
    { id = "report1"
    , animal = Animal.data1
    , humanContact = Human.data1
    , date = Date.fromCalendarDate 2021 Time.Feb 4
    , location = ( -38.0631442, -57.5572745 )
    , notes = "Additional notes of the report..."
    , reportType = Missing
    , resolved = Unresolved
    }


data2 : Report
data2 =
    { data1
        | id = "report2"
        , animal = Animal.data2
        , date = Date.fromCalendarDate 2021 Time.Jan 22
        , location = ( -38.0139405, -57.5610563 )
    }


data3 : Report
data3 =
    { data1
        | id = "report3"
        , animal = Animal.data3
        , date = Date.fromCalendarDate 2021 Time.Jan 4
        , location = ( -38.0431048, -57.5694195 )
        , resolved = Resolved ( Date.fromCalendarDate 2021 Time.Mar 7, "report5" )
    }


data4 : Report
data4 =
    { data1
        | id = "report4"
        , animal = Animal.data4
        , date = Date.fromCalendarDate 2020 Time.Dec 14
        , location = ( -37.9777782, -57.5753418 )
        , reportType = Found
    }


data5 : Report
data5 =
    { data1
        | id = "report5"
        , animal = Animal.data5
        , date = Date.fromCalendarDate 2021 Time.Feb 17
        , location = ( -37.9477782, -57.5453418 )
        , reportType = Found
        , resolved = Resolved ( Date.fromCalendarDate 2021 Time.Mar 7, "report3" )
    }
