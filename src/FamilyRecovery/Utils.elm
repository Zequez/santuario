module FamilyRecovery.Utils exposing (..)

import Date exposing (Date)


distanceBetweenPoints : ( Float, Float ) -> ( Float, Float ) -> Float
distanceBetweenPoints ( lat1, lng1 ) ( lat2, lng2 ) =
    2.5


daysBetweenDates : Date -> Date -> Int
daysBetweenDates from to =
    Date.toRataDie to - Date.toRataDie from
