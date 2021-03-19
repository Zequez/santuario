module FamilyRecovery.Player exposing (..)

import FamilyRecovery.Animal as Animal
import FamilyRecovery.Human as Human
import FamilyRecovery.Report as Report


type alias Player =
    { alias : String
    , humans : List Human.Human
    , animals : List Animal.Animal
    , reports : List Report.Report
    }


data1 : Player
data1 =
    { alias = "Zequez"
    , humans = [ Human.data1 ]
    , animals = [ Animal.data1, Animal.data2, Animal.data3, Animal.data4 ]
    , reports =
        [ Report.data1
        , Report.data2
        , Report.data3
        , Report.data4
        , Report.data5
        ]
    }
