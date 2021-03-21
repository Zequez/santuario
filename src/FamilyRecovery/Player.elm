module FamilyRecovery.Player exposing (..)

import Dict exposing (Dict)
import FamilyRecovery.Animal as Animal
import FamilyRecovery.Human as Human
import FamilyRecovery.Report as Report


type alias Player =
    { alias : String
    , humans : List Human.Human
    , animals : List Animal.Animal
    , reports : List Report.Report
    }


toDict : List Player -> Dict String Player
toDict players =
    players
        |> List.map (\a -> ( a.alias, a ))
        |> Dict.fromList


animals : List Player -> Dict String Animal.Animal
animals players =
    dictFromPlayersCards players .animals


humans : List Player -> Dict String Human.Human
humans players =
    dictFromPlayersCards players .humans


reports : List Player -> Dict String Report.Report
reports players =
    dictFromPlayersCards players .reports


type alias CardLike a =
    { a
        | id : String
    }


all : List Player
all =
    [ data1, data2 ]


dictFromPlayersCards : List Player -> (Player -> List (CardLike a)) -> Dict String (CardLike a)
dictFromPlayersCards players selector =
    players
        |> List.concatMap selector
        |> List.map (\a -> ( a.id, a ))
        |> Dict.fromList


data1 : Player
data1 =
    { alias = "Zequez"
    , humans = [ Human.data1 ]
    , animals = [ Animal.data1, Animal.data2, Animal.data3, Animal.data4 ]
    , reports =
        [ Report.data1
        , Report.data2
        , Report.data3
        ]
    }


data2 : Player
data2 =
    { alias = "Cele"
    , humans = [ Human.data2 ]
    , animals = [ Animal.data4 ]
    , reports =
        [ Report.data4
        , Report.data5
        ]
    }
