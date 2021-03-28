module FamilyRecovery.Card exposing (..)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)
import MapboxElement.Mapbox as Mapbox


view : String -> Html msg -> Html msg
view cardLegend children =
    div [ class "bg-white rounded-md p-4 relative shadow-sm" ]
        [ span [ class """absolute left-0 top-0 -mt-2 ml-2 px-1 bg-yellow-400
                    text-xs uppercase font-bold text-white rounded-sm""" ]
            [ text cardLegend ]
        , children
        ]


row : Html msg -> Html msg
row el =
    div [ class "mb-4" ] [ el ]


tagsWrapper : List (Html msg) -> Html msg
tagsWrapper children =
    div [ class "flex flex-wrap -m-1" ]
        (children
            |> List.map (\tag -> div [ class "m-1" ] [ tag ])
        )


tagView : String -> Html msg -> Html msg
tagView label el =
    div [ class "rounded-md bg-gray-200  text-sm overflow-hidden flex flex-inline" ]
        [ div [ class "bg-yellow-400 uppercase text-xs flex items-center justify-center text-center text-white font-bold px-2" ]
            [ text label ]
        , div
            [ class "px-2 flex items-center" ]
            [ el ]
        ]


mapView : String -> ( Float, Float ) -> (( Float, Float ) -> msg) -> Html msg
mapView label location msg =
    div [ class "relative" ]
        [ legendView label
        , div [ class "h-60 bg-gray-100 rounded-md border border-gray-200" ]
            [ Mapbox.locationPickerMapView location msg
            ]
        ]


textBoxView : String -> String -> Html msg
textBoxView label val =
    div [ class "relative bg-gray-100 p-2 rounded-md border border-gray-200" ]
        [ legendView label
        , text val
        ]


legendView : String -> Html msg
legendView legendText =
    div [ class "absolute bg-yellow-400 z-40 top-0 left-0 -mt-2 ml-2 text-xs uppercase text-white font-bold px-1 rounded-sm" ]
        [ text legendText
        ]
