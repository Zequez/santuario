module FamilyRecovery.Report exposing (..)

import Date exposing (Date)
import FamilyRecovery.Animal as Animal
import FamilyRecovery.Human as Human
import FamilyRecovery.Utils as Utils
import Time


type alias Report =
    { id : String
    , animal : Animal.Animal
    , humanContact : Human.Human
    , spaceTime : SpaceTime
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


type alias SpaceTime =
    { date : Date
    , location : ( Float, Float )
    }


contextualize : Date -> GeoLocation -> Report -> ContextualizedReport
contextualize today geolocation report =
    { report = report
    , daysAgo = Utils.daysBetweenDates report.spaceTime.date today
    , kmAway = Maybe.map (Utils.distanceBetweenPoints report.spaceTime.location) geolocation
    }


findById : String -> List ContextualizedReport -> Maybe ContextualizedReport
findById id cReports =
    cReports
        |> List.filter (\cr2 -> cr2.report.id == id)
        |> List.head


data1 : Report
data1 =
    { id = "report1"
    , animal = Animal.data1
    , humanContact = Human.data1
    , spaceTime =
        { date = Date.fromCalendarDate 2021 Time.Feb 4
        , location = ( -38.0631442, -57.5572745 )
        }
    , notes = "Additional notes of the report..."
    , reportType = Missing
    , resolved = Unresolved
    }


data2 : Report
data2 =
    { data1
        | id = "report2"
        , animal = Animal.data2
        , spaceTime = { date = Date.fromCalendarDate 2021 Time.Jan 22, location = ( -38.0139405, -57.5610563 ) }
    }


data3 : Report
data3 =
    { data1
        | id = "report3"
        , animal = Animal.data3
        , spaceTime = { date = Date.fromCalendarDate 2021 Time.Jan 4, location = ( -38.0431048, -57.5694195 ) }
        , resolved = Resolved ( Date.fromCalendarDate 2021 Time.Mar 7, "report5" )
    }


data4 : Report
data4 =
    { data1
        | id = "report4"
        , animal = Animal.data4
        , spaceTime = { date = Date.fromCalendarDate 2020 Time.Dec 14, location = ( -37.9777782, -57.5753418 ) }
        , reportType = Found
    }


data5 : Report
data5 =
    { data1
        | id = "report5"
        , animal = Animal.data5
        , spaceTime = { date = Date.fromCalendarDate 2021 Time.Feb 17, location = ( -37.9477782, -57.5453418 ) }
        , reportType = Found
        , resolved = Resolved ( Date.fromCalendarDate 2021 Time.Mar 7, "report3" )
    }
