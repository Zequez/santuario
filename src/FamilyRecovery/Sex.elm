module FamilyRecovery.Sex exposing (Sex(..), all, color, fromSlug, fullIcon, fullLabel, htmlOption, icon, label, toSlug)

import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import Html exposing (Html, div, option, text)
import Html.Attributes exposing (class, style, title, value)


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


fullIcon : Sex -> Html msg
fullIcon sex =
    div
        [ title (label sex)
        , class "text-white h-4 w-4 text-center text-xs rounded-full"
        , style "background" (color sex)
        ]
        [ icon sex ]


fullLabel : Sex -> Html msg
fullLabel sex =
    div
        [ class "text-white"
        , style "background" (color sex)
        ]
        [ text (label sex)
        , icon sex
        ]


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
