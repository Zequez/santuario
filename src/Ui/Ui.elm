module Ui.Ui exposing (..)

import Html exposing (Attribute, Html, a, button, code, div, input, text)
import Html.Attributes exposing (attribute, class, disabled, placeholder, type_, value)
import Html.Events exposing (on, onClick, onInput)


primaryButton : List (Html.Attribute msg) -> List (Html msg) -> Html msg
primaryButton attributes children =
    button
        (class """
          bg-yellow-500 ring-yellow-400 ring-opacity-50
          hover:ring-4 hover:ring-opacity-25
          focus:ring-4 focus:ring-opacity-50 focus:outline-none
          active:ring-opacity-75
          text-white text-lg font-semibold tracking-wide uppercase
          py-2 px-4 rounded-md
          disabled:opacity-50"""
            :: attributes
        )
        children


classInput : Html.Attribute msg
classInput =
    class "block w-full mb-4 h-12 px-4 py-2 text-lg rounded-md ring-1 ring-gray-200"


classFocusRing : Html.Attribute msg
classFocusRing =
    class "focus:outline-none focus:ring focus:ring-green-500 focus:ring-opacity-50"
