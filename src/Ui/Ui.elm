module Ui.Ui exposing (..)

import Html exposing (Attribute, Html, a, button, code, div, input, text)
import Html.Attributes exposing (attribute, class, disabled, href, placeholder, type_, value)
import Html.Events exposing (on, onClick, onInput)


mainSidebarView : String -> List (Attribute msg) -> List (Html msg) -> Html msg
mainSidebarView title attributes children =
    div (class "w-32 flex-shrink-0 bg-gray-100 shadow-md flex flex-col" :: attributes)
        (a [ class "flex h-12 items-center bg-green-500 bg-opacity-75 hover:bg-opacity-100 text-white", href "/" ]
            [ div [ class "text-2xl mx-4" ] [ text "❮" ]
            , div [ class "text-xl" ] [ text title ]
            ]
            :: children
        )


primaryButton : List (Attribute msg) -> List (Html msg) -> Html msg
primaryButton attributes children =
    button
        (class """
          bg-yellow-500 ring-yellow-400 ring-opacity-50
          hover:ring-4 hover:ring-opacity-25
          focus:ring-4 focus:ring-opacity-50 focus:outline-none
          active:ring-opacity-75
          text-white text-base font-semibold tracking-wide uppercase
          py-2 px-4 rounded-md
          disabled:opacity-50"""
            :: attributes
        )
        children


classInput : Attribute msg
classInput =
    class "block w-full mb-4 h-12 px-4 py-2 text-lg rounded-md ring-1 ring-gray-200"


classFocusRing : Attribute msg
classFocusRing =
    class "focus:outline-none focus:ring focus:ring-green-500 focus:ring-opacity-50"
