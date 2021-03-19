module FamilyRecovery.Human exposing (..)


type alias Human =
    { id : String
    , alias : String
    , name : String
    , phone : String
    , email : String
    , avatar : String
    , bio : String
    }


data1 : Human
data1 =
    { id = "human1"
    , alias = "Zequez"
    , name = "Ezequiel Schwartzman"
    , email = "zequez@gmail.com"
    , phone = "+54 9 223 5235568"
    , avatar = "https://en.gravatar.com/userimage/10143531/5dea71d35686673d0d93a3d0de968b64.png?size=200"
    , bio = ""
    }
