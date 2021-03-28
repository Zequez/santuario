module MapboxElement.Mapbox exposing (..)

import Html exposing (Html, div, node)
import Html.Attributes exposing (attribute, class, style)
import Html.Events exposing (on)
import Json.Decode as JD
import Json.Encode as JE
import Tuple


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


onMarkerClick : (String -> msg) -> Html.Attribute msg
onMarkerClick message =
    on "markerClick" (JD.map message (JD.at [ "detail", "id" ] JD.string))


onLocationChangeClick : (( Float, Float ) -> msg) -> Html.Attribute msg
onLocationChangeClick message =
    on "locationChange"
        (JD.map message
            (JD.map2
                Tuple.pair
                (JD.at [ "detail", "lat" ] JD.float)
                (JD.at [ "detail", "lng" ] JD.float)
            )
        )


imagesMapView : List ImageMarker -> (String -> msg) -> Html msg
imagesMapView markers msg =
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


locationPickerMapView : ( Float, Float ) -> (( Float, Float ) -> msg) -> Html msg
locationPickerMapView ( lat, lng ) msg =
    node "mapbox-element"
        [ attribute "lat" (String.fromFloat lat)
        , attribute "lng" (String.fromFloat lng)
        , attribute "zoom" "10"
        , onLocationChangeClick msg
        ]
        []
