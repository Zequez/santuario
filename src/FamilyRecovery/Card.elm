module FamilyRecovery.Card exposing (..)

import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class)


view : String -> Html msg -> Html msg
view cardLegend children =
    div [ class "bg-white rounded-md p-4 relative shadow-sm" ]
        [ span [ class """absolute left-0 top-0 -mt-2 ml-2 px-1 bg-yellow-400
                    text-xs uppercase font-bold text-white rounded-sm""" ]
            [ text cardLegend ]
        , children
        ]
