module Specie exposing (Specie(..), all, emoji, fromSlug, htmlOption, label, toSlug)

import Html exposing (Html, option, text)
import Html.Attributes exposing (value)


type Specie
    = Dog
    | Cat
    | Other


all : List Specie
all =
    [ Dog, Cat, Other ]


htmlOption : Specie -> Html msg
htmlOption specie =
    option [ value (toSlug specie) ] [ text (emoji specie ++ " " ++ label specie) ]


emoji : Specie -> String
emoji specie =
    case specie of
        Dog ->
            "🐶"

        Cat ->
            "🐱"

        Other ->
            "🐾"


label : Specie -> String
label specie =
    case specie of
        Dog ->
            "Perre"

        Cat ->
            "Gate"

        Other ->
            "Otra"


toSlug : Specie -> String
toSlug specie =
    case specie of
        Dog ->
            "Dog"

        Cat ->
            "Cat"

        Other ->
            "Other"


fromSlug : String -> Specie
fromSlug str =
    case str of
        "Dog" ->
            Dog

        "Cat" ->
            Cat

        "Other" ->
            Other

        _ ->
            Other
