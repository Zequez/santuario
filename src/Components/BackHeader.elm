module Components.BackHeader exposing (view)

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, href)


view : String -> Html msg
view pageTitle =
    div [ class "h-12 bg-white bg-opacity-25 flex items-center text-white" ]
        [ a [ href "/", class "text-2xl w-12 text-center" ] [ text "❮" ]
        , div [ class "flex-grow font-semibold text-xl tracking-wider text-white" ] [ text pageTitle ]
        ]
