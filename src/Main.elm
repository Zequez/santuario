module Main exposing (main)

import Browser
import Html exposing (Html, div, h2, img, text)
import Html.Attributes exposing (class, src)


type alias User =
    { fullName : String
    , position : String
    , email : String
    , phone : String
    , avatar : String
    }


me : User
me =
    { fullName = "Ezequiel Schwartzman"
    , position = "Wizard"
    , email = "zequez@gmail.com"
    , phone = "+54 9 223 5235568"
    , avatar = "https://en.gravatar.com/userimage/10143531/5dea71d35686673d0d93a3d0de968b64.png?size=200"
    }


userCardView : User -> Html msg
userCardView user =
    div [ class "md:flex bg-white rounded-lg p-6 shadow-lg m-10" ]
        [ img
            [ class "h-16 w-16 md:h-24 md:w-24 rounded-full mx-auto md:mx-0 md:mr-6"
            , src user.avatar
            ]
            []
        , div
            [ class "text-center md:text-left" ]
            [ h2 [ class "text-lg" ] [ text user.fullName ]
            , div [ class "text-purple-500" ] [ text user.position ]
            , div [ class "text-gray-600" ] [ text user.email ]
            , div [ class "text-gray-600" ] [ text user.phone ]
            ]
        ]


update : msg -> User -> User
update _ model =
    model


view : User -> Html msg
view model =
    userCardView model


main : Program () User msg
main =
    Browser.sandbox { init = me, update = update, view = view }
