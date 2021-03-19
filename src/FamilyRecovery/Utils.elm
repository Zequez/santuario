module FamilyRecovery.Utils exposing (..)

import Date exposing (Date)
import Regex


distanceBetweenPoints : ( Float, Float ) -> ( Float, Float ) -> Float
distanceBetweenPoints ( lat1, lng1 ) ( lat2, lng2 ) =
    2.5


daysBetweenDates : Date -> Date -> Int
daysBetweenDates from to =
    Date.toRataDie to - Date.toRataDie from


cleanPhoneNumber : String -> String
cleanPhoneNumber phone =
    let
        regex =
            Maybe.withDefault Regex.never (Regex.fromString "[^0-9]")
    in
    phone
        |> Regex.replace regex (\_ -> "")
