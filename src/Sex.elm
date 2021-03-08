module Sex exposing (Sex(..), all, color, fromSlug, htmlOption, icon, label, toSlug)

import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html, option, text)
import Html.Attributes exposing (value)


type Sex
    = Male
    | Female


all : List Sex
all =
    [ Male, Female ]


htmlOption : Sex -> Html msg
htmlOption sex =
    option [ value (toSlug sex) ] [ text (label sex) ]


icon : Sex -> Html msg
icon sex =
    case sex of
        Male ->
            Icon.viewIcon Icon.mars

        Female ->
            Icon.viewIcon Icon.venus


label : Sex -> String
label sex =
    case sex of
        Male ->
            "Macho"

        Female ->
            "Hembra"


color : Sex -> String
color sex =
    case sex of
        Male ->
            "DeepSkyBlue"

        Female ->
            "HotPink"


toSlug : Sex -> String
toSlug sex =
    case sex of
        Male ->
            "Male"

        Female ->
            "Female"


fromSlug : String -> Sex
fromSlug str =
    case str of
        "Male" ->
            Male

        "Female" ->
            Female

        _ ->
            Male
