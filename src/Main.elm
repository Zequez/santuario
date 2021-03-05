module Main exposing (main)

import Browser
import Date exposing (Date, fromCalendarDate)
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import FontAwesome.Styles
import Html exposing (Html, a, div, h2, img, input, node, select, span, text)
import Html.Attributes exposing (attribute, class, href, placeholder, src, style, title)
import Json.Decode
import Json.Encode
import LngLat exposing (LngLat)
import Map.Style
import MapCommands
import Mapbox.Element
import Mapbox.Expression as E exposing (float, str)
import Mapbox.Layer as Layer exposing (Layer)
import Mapbox.Source as Source exposing (Source)
import Mapbox.Style as Style exposing (Style)
import Round
import Task exposing (Task)
import Time



------------------------------------ ████████╗██╗   ██╗██████╗ ███████╗███████╗
------------------------------------ ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
------------------------------------    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
------------------------------------    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
------------------------------------    ██║      ██║   ██║     ███████╗███████║
------------------------------------    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝


type alias Model =
    { player : Player
    , reports : List MissingReport
    , geolocation : GeoLocation
    , searchKm : Float
    , today : Date
    }


type alias Player =
    { alias : String
    , name : String
    , phone : String
    , email : String
    , avatar : String
    }


type alias MissingReport =
    { player : Player
    , animal : Animal
    , spaceTime : SpaceTime
    }


type alias ContextualizedMissingReport =
    { report : MissingReport
    , daysAgo : Int
    , kmAway : Maybe Float
    }


type alias Animal =
    { name : String
    , specie : Specie
    , sex : Sex
    , description : String
    , contact : String
    , photos : List String
    }


type alias GeoLocation =
    Maybe ( Float, Float )


type Sex
    = Male
    | Female


type Specie
    = Dog
    | Cat
    | Other


type alias SpaceTime =
    { date : Date
    , location : ( Float, Float )
    }



-------- ████████╗███████╗███████╗████████╗    ██████╗  █████╗ ████████╗ █████╗
-------- ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
--------    ██║   █████╗  ███████╗   ██║       ██║  ██║███████║   ██║   ███████║
--------    ██║   ██╔══╝  ╚════██║   ██║       ██║  ██║██╔══██║   ██║   ██╔══██║
--------    ██║   ███████╗███████║   ██║       ██████╔╝██║  ██║   ██║   ██║  ██║
--------    ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝


testPlayer : Player
testPlayer =
    { alias = "Zequez"
    , name = "Ezequiel Schwartzman"
    , email = "zequez@gmail.com"
    , phone = "+54 9 223 5235568"
    , avatar = "https://en.gravatar.com/userimage/10143531/5dea71d35686673d0d93a3d0de968b64.png?size=200"
    }


testAnimal : Animal
testAnimal =
    { name = "Marley"
    , specie = Dog
    , sex = Male
    , description = "He's a good boy"
    , contact = "Call Zequez @ +5492235235568"
    , photos = [ "https://placekitten.com/200/200" ]
    }


testAnimal2 : Animal
testAnimal2 =
    { name = "Meri"
    , specie = Cat
    , sex = Female
    , description = "She's a little timid"
    , contact = "Call Zequez @ +5492235235568"
    , photos = [ "https://placekitten.com/225/225" ]
    }


testReports : List MissingReport
testReports =
    [ { player = testPlayer
      , animal = testAnimal
      , spaceTime =
            { date = Date.fromCalendarDate 2021 Time.Feb 4
            , location = ( -38.0631442, -57.5572745 )
            }
      }
    , { player = testPlayer
      , animal = testAnimal2
      , spaceTime =
            { date = Date.fromCalendarDate 2021 Time.Jan 22
            , location = ( -38.0139405, -57.5610563 )
            }
      }
    , { player = testPlayer
      , animal = testAnimal2
      , spaceTime =
            { date = Date.fromCalendarDate 2021 Time.Jan 4
            , location = ( -38.0139405, -57.5610563 )
            }
      }
    , { player = testPlayer
      , animal = testAnimal2
      , spaceTime =
            { date = Date.fromCalendarDate 2020 Time.Dec 14
            , location = ( -38.0139405, -57.5610563 )
            }
      }
    ]



------------------------------------------------------ ██╗███╗   ██╗██╗████████╗
------------------------------------------------------ ██║████╗  ██║██║╚══██╔══╝
------------------------------------------------------ ██║██╔██╗ ██║██║   ██║
------------------------------------------------------ ██║██║╚██╗██║██║   ██║
------------------------------------------------------ ██║██║ ╚████║██║   ██║
------------------------------------------------------ ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝


init : ( Model, Cmd Msg )
init =
    ( { player = testPlayer
      , reports = testReports
      , geolocation = Nothing
      , searchKm = 5.0
      , today = Date.fromCalendarDate 2020 Time.Jan 1
      }
    , Date.today |> Task.perform ReceiveDate
    )


main : Program () Model Msg
main =
    Browser.document
        { init = always init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



---------------------------- ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗
---------------------------- ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
---------------------------- ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗
---------------------------- ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝
---------------------------- ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗
----------------------------  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝


type Msg
    = ReceiveDate Date


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDate date ->
            ( { model | today = date }, Cmd.none )



---------------------------------------- ██╗   ██╗██╗███████╗██╗    ██╗███████╗
---------------------------------------- ██║   ██║██║██╔════╝██║    ██║██╔════╝
---------------------------------------- ██║   ██║██║█████╗  ██║ █╗ ██║███████╗
---------------------------------------- ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║╚════██║
----------------------------------------  ╚████╔╝ ██║███████╗╚███╔███╔╝███████║
----------------------------------------   ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚══════╝


view : Model -> Browser.Document msg
view model =
    let
        contextualizedReports =
            model.reports
                |> List.map (contextualizeReport model.today model.geolocation)
                |> List.sortBy .daysAgo
    in
    Browser.Document "Santuario"
        [ div [ class "text-white" ]
            [ FontAwesome.Styles.css

            -- , headerView
            , mapView model
            , div [ class "container mx-auto p-4" ]
                [ filterView
                , reportsListView contextualizedReports
                ]
            ]
        ]


headerView : Html msg
headerView =
    div
        [ class """
            h-12 bg-white bg-opacity-25 flex items-center
            justify-center text-2xl text-spacing font-bold tracking-wider text-white shadow-md"""
        ]
        [ a [ href "/" ] [ text "SANTUARIO" ]
        ]


mapView : Model -> Html msg
mapView model =
    let
        photos : String
        photos =
            "["
                ++ (model.reports
                        |> List.concatMap (\m -> m.animal.photos)
                        |> List.map (\s -> "\"" ++ s ++ "\"")
                        |> String.join ","
                   )
                ++ "]"
    in
    -- div [ style "height" "400px", class "w-full" ] [ Mapbox.Element.map [] (buildStyle model) ]
    div [ style "height" "400px", class "w-full" ]
        [ node "mapbox-images"
            [ attribute "images" photos
            , attribute "lat" "-38.0139405"
            , attribute "lng" "-57.5610563"
            ]
            []
        ]


filterView : Html msg
filterView =
    div [ class "mb-4" ]
        [ input
            [ class "px-4 py-2 text-xl rounded-md w-full text-black"
            , placeholder "Buscar..."
            ]
            []
        ]


reportsListView : List ContextualizedMissingReport -> Html msg
reportsListView reports =
    div [ class "grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4" ] (List.map reportsCardView reports)


reportsCardView : ContextualizedMissingReport -> Html msg
reportsCardView cReport =
    let
        animal =
            cReport.report.animal

        report =
            cReport.report
    in
    a [ class "bg-white text-gray-800 shadow-md overflow-hidden rounded-md", href "/" ]
        [ div [ class "h-40 overflow-hidden" ]
            [ img
                [ class "object-cover w-full"
                , src (Maybe.withDefault "" (List.head animal.photos))
                ]
                []
            ]
        , div [ class "p-2 bg-white" ]
            [ div [ class "flex items-center" ]
                [ div [ class "flex-grow" ]
                    [ text report.animal.name ]
                , div
                    [ class "flex items-center" ]
                    [ span [ title (specieText animal.specie) ]
                        [ text (specieEmoji animal.specie) ]
                    , div
                        [ title (sexText animal.sex)
                        , class "rounded-full text-white h-4 w-4 text-center text-xs ml-1"
                        , style "background" (sexColor animal.sex)
                        ]
                        [ sexIcon animal.sex ]
                    ]
                ]
            , div [ class "flex text-xs text-gray-600" ]
                [ span [ class "flex-grow" ] [ text ("Hace " ++ String.fromInt cReport.daysAgo ++ " días") ]
                , span []
                    [ text
                        (case cReport.kmAway of
                            Just distance ->
                                Round.round 1 distance ++ "km"

                            Nothing ->
                                "?km"
                        )
                    ]
                ]
            ]
        ]



-- animalCardView : Animal -> Html msg
-- animalCardView animal =
--     div [ class "bg-white text-gray-800" ] [ text animal.name ]


userCardView : Player -> Html msg
userCardView user =
    div [ class "p-4" ]
        [ img
            [ class "h-16 w-16 md:h-24 md:w-24 rounded-full mx-auto md:mx-0 md:mr-6 mb-4"
            , src user.avatar
            ]
            []
        , div
            [ class "text-center md:text-left" ]
            [ h2 [ class "text-lg" ] [ text user.name ]
            , div [ class "text-gray-600" ] [ text user.email ]
            , div [ class "text-gray-600" ] [ text user.phone ]
            ]
        ]



---------------------- ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
---------------------- ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
---------------------- ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
---------------------- ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
---------------------- ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
---------------------- ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝


contextualizeReport : Date -> GeoLocation -> MissingReport -> ContextualizedMissingReport
contextualizeReport today geolocation report =
    { report = report
    , daysAgo = daysBetweenDates report.spaceTime.date today
    , kmAway = Maybe.map (distanceBetweenPoints report.spaceTime.location) geolocation
    }


distanceBetweenPoints : ( Float, Float ) -> ( Float, Float ) -> Float
distanceBetweenPoints ( lat1, lng1 ) ( lat2, lng2 ) =
    2.5


daysBetweenDates : Date -> Date -> Int
daysBetweenDates from to =
    Date.toRataDie to - Date.toRataDie from


specieEmoji : Specie -> String
specieEmoji specie =
    case specie of
        Dog ->
            "🐶"

        Cat ->
            "🐱"

        Other ->
            "🐾"


specieText : Specie -> String
specieText specie =
    case specie of
        Dog ->
            "Perre"

        Cat ->
            "Gate"

        Other ->
            "Otro"


sexIcon : Sex -> Html msg
sexIcon sex =
    case sex of
        Male ->
            Icon.viewIcon Icon.mars

        Female ->
            Icon.viewIcon Icon.venus


sexText : Sex -> String
sexText sex =
    case sex of
        Male ->
            "Marte"

        Female ->
            "Venus"


sexColor : Sex -> String
sexColor sex =
    case sex of
        Male ->
            "DeepSkyBlue"

        Female ->
            "HotPink"


geojson : Json.Decode.Value
geojson =
    Json.Decode.decodeString Json.Decode.value """
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [-57.5610563, -38.0631442]
      }
    }
  ]
}
""" |> Result.withDefault (Json.Encode.object [])



-- https://upload.wikimedia.org/wikipedia/commons/7/7c/201408_cat.png


buildStyle : Model -> Style
buildStyle model =
    let
        _ =
            Debug.log "Geojson" geojson
    in
    Map.Style.light
        [ Source.geoJSONFromValue "photos" [] geojson ]
        -- [ Layer.fill "changes"
        --     "changes"
        --     [ Layer.fillColor (E.rgba 255 255 255 1)
        --     ]
        -- , Layer.iconImage (E.str "dot-10")
        -- ]
        [ Layer.symbol "photos"
            "photos"
            [ Layer.iconImage (E.str "cat")
            , Layer.iconSize (E.float 0.25)
            ]
        ]
        [ Style.defaultZoomLevel 11
        , Style.defaultCenter <| LngLat -57.5610563 -38.0139405
        ]



-- [ Source.geoJSONFromUrl "flooding" "https://data.easos.my/geoserver/easos-flooding/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=easos-flooding:rainfall_latest&outputFormat=application%2Fjson" [] ]
-- [ Layer.circle "points"
--     "flooding"
--     [ E.getProperty (str "stationtype")
--         |> E.matchesStr
--             [ ( "WL", float 1 )
--             , ( "RF", float 3 )
--             , ( "RF & WL", float 5 )
--             ]
--             (float 1)
--         |> Layer.circleRadius
--     , [ E.getProperty (str "waterlevelmsg"), E.getProperty (str "rainfallmsg") ]
--         |> E.coalesce
--         |> E.matchesStr
--             [ ( "LIGHT", E.rgba 125 210 33 1 )
--             , ( "NORMAL", E.rgba 125 210 33 1 )
--             , ( "MODERATE", E.rgba 255 239 0 1 )
--             , ( "ALERT", E.rgba 255 239 0 1 )
--             , ( "HEAVY", E.rgba 255 155 0 1 )
--             , ( "WARNING", E.rgba 255 155 0 1 )
--             , ( "VERY HEAVY", E.rgba 255 0 18 1 )
--             , ( "DANGER", E.rgba 255 0 18 1 )
--             , ( "NODATA", E.rgba 49 93 107 0.2 )
--             , ( "OFF", E.rgba 49 93 107 0.2 )
--             ]
--             (E.rgba 49 93 107 0.2)
--         |> Layer.circleColor
--     ]
-- ]
