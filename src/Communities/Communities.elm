module Communities.Communities exposing (..)

-- Communities are hard-coded for now, because the overhead of writing an entire
-- community managment system would get in the way of writing the small systems that
-- communities can actually use.
-- Additionally, in this way we can also see the communities that
-- the app is serving just by looking at the source code, how cool is that? :)
-- We can even use this information to automatically deploy a community-scoped Santuario to
-- specific domain names, which would not be possible if storing it on a DB


type IPFSAddress
    = IPFSAddress String


type alias Community =
    { name : String
    , slug : String
    , description : String
    , language : String
    , host : String
    , emoji : String
    , banner : IPFSAddress
    , logo : IPFSAddress
    , location : List ( Float, Float )
    , coordinators : List String
    , markets : List String
    }


communities : List Community
communities =
    [ { name = "Mar del Plata"
      , slug = "mdq"
      , description = "Espacio digital comunitario de la ciudad"
      , language = "es"
      , host = "santuario.zequez.space"
      , emoji = "🦆"
      , banner = IPFSAddress "QmPdYGLiUsr6waTtsxV4B57y3mfjFSNcnrytgVNHrVMpRC"
      , logo = IPFSAddress "QmQsiFfPhbnzq16D7VQerxi5pvURdmmCV6nkUR511emttp"
      , coordinators = [ "Zequez" ]
      , location =
            [ ( -57.6424627, -37.9811701 )
            , ( -57.6283865, -38.0285118 )
            , ( -57.5796347, -38.0844708 )
            , ( -57.5298529, -38.099332 )
            , ( -57.494834, -38.0052505 )
            , ( -57.5350027, -37.935964 )
            , ( -57.611907, -37.9392133 )
            , ( -57.6424627, -37.9811701 )
            ]
      , markets = [ "vegan", "agroeco", "artesano", "clothing" ]
      }
    ]
