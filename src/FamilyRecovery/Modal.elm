module FamilyRecovery.Modal exposing (..)

import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


view : String -> msg -> Html msg -> Html msg
view modalTitle onClose content =
    div [ class "fixed inset-0 z-40 p-2 md:p-4 overflow-auto" ]
        [ div [ class "bg-gray-100 max-w-lg bg-white mx-auto rounded-md w-full overflow-hidden flex flex-col z-50 relative" ]
            [ div [ class "relative h-16 bg-yellow-300 uppercase font-bold text-xl tracking-wider flex items-center justify-center" ]
                [ text modalTitle
                , div
                    [ class "absolute right-0 h-full w-16 bg-red-400 flex items-center justify-center text-3xl cursor-pointer"
                    , onClick onClose
                    ]
                    [ Icon.viewIcon Icon.times
                    ]
                ]
            , content
            ]
        , div [ class "bg-black bg-opacity-25 z-40 fixed inset-0", onClick onClose ] []
        ]
