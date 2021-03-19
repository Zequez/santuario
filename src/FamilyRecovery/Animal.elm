module FamilyRecovery.Animal exposing (..)

import FamilyRecovery.Human as Human
import FamilyRecovery.Sex as Sex
import FamilyRecovery.Specie as Specie


type alias Animal =
    { id : String
    , family : List Human.Human
    , name : String
    , specie : Specie.Specie
    , sex : Sex.Sex
    , bio : String
    , photos : List String
    }


data1 : Animal
data1 =
    { id = "animal1"
    , family = [ Human.data1, Human.data2 ]
    , name = "Marley"
    , specie = Specie.Dog
    , sex = Sex.Male
    , bio = "He's a good boy"
    , photos = [ "https://placekitten.com/200/200" ]
    }


data2 : Animal
data2 =
    { id = "animal2"
    , family = [ Human.data1 ]
    , name = "Meri"
    , specie = Specie.Cat
    , sex = Sex.Female
    , bio = "She's a little timid. Mancha marron."
    , photos = [ "https://placekitten.com/225/225" ]
    }


data3 : Animal
data3 =
    { data2 | name = "Popote", photos = [ "https://placekitten.com/220/220" ] }


data4 : Animal
data4 =
    { id = "animal4"
    , family = []
    , name = ""
    , specie = Specie.Cat
    , sex = Sex.Female
    , bio = ""
    , photos = [ "https://placekitten.com/270/270" ]
    }


data5 : Animal
data5 =
    { id = "animal2"
    , family = []
    , name = ""
    , specie = Specie.Cat
    , sex = Sex.Female
    , bio = ""
    , photos = [ "https://placekitten.com/225/225" ]
    }
