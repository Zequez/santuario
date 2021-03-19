module FamilyRecovery.Mapbox exposing (..)

import FamilyRecovery.Report as Report
import Html exposing (Html, div, node)
import Html.Attributes exposing (attribute, class, style)
import Html.Events exposing (on)
import Json.Decode as JD
import Json.Encode as JE


type alias ImageMarker =
    { src : String
    , lat : Float
    , lng : Float
    , id : String
    }


imageMarkersEncode : List ImageMarker -> JE.Value
imageMarkersEncode imageMarkers =
    imageMarkers
        |> JE.list
            (\imageMarker ->
                JE.object
                    [ ( "src", JE.string imageMarker.src )
                    , ( "lat", JE.float imageMarker.lat )
                    , ( "lng", JE.float imageMarker.lng )
                    , ( "id", JE.string imageMarker.id )
                    ]
            )


reportToMarker : Report.Report -> ImageMarker
reportToMarker report =
    { src = Maybe.withDefault "" (List.head report.animal.photos)
    , lat = Tuple.first report.spaceTime.location
    , lng = Tuple.second report.spaceTime.location
    , id = report.id
    }


onMarkerClick : (String -> msg) -> Html.Attribute msg
onMarkerClick message =
    on "markerClick" (JD.map message (JD.at [ "detail", "id" ] JD.string))


mapView : List Report.Report -> (String -> msg) -> Html msg
mapView reports msg =
    let
        markers : List ImageMarker
        markers =
            reports
                |> List.map reportToMarker
    in
    div [ style "height" "400px", class "w-full" ]
        [ node "mapbox-element"
            [ attribute "images" (JE.encode 0 (imageMarkersEncode markers))
            , attribute "lat" "-38.0139405"
            , attribute "lng" "-57.5610563"
            , attribute "zoom" "10"
            , onMarkerClick msg
            ]
            []
        ]
