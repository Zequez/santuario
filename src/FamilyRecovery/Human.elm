module FamilyRecovery.Human exposing (..)

import FamilyRecovery.Card as Card
import FamilyRecovery.Utils as Utils
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import Html exposing (Html, a, div, img, span, text)
import Html.Attributes exposing (class, href, src, target)


type alias Human =
    { id : String
    , alias : String
    , name : String
    , phone : String
    , email : String
    , avatar : String
    , bio : String
    }


cardView : Human -> Html msg
cardView human =
    Card.view "Humano"
        (div [ class "flex" ]
            [ img [ src human.avatar, class "h-24 w-24 rounded-full" ] []
            , div [ class "flex-grow ml-4" ]
                [ div [ class "text-xl" ]
                    [ text human.alias
                    , span [ class "text-white text-sm text-opacity-75" ] [ text (" (" ++ human.name ++ ")") ]
                    ]
                , div [ class "flex" ]
                    [ div [ class "flex-grow" ]
                        [ div []
                            [ a
                                [ target "_blank"
                                , class "text-yellow-500"
                                , href ("mailto:" ++ human.email)
                                ]
                                [ text human.email ]
                            ]
                        , div []
                            [ a
                                [ target "_blank"
                                , class "text-yellow-500"
                                , href (whatsappUrl human.phone)
                                ]
                                [ text human.phone ]
                            ]
                        ]
                    ]
                ]
            ]
        )


tagsView : String -> List Human -> Html msg
tagsView label humans =
    Card.tagView label
        (div [ class "flex flex-wrap" ]
            (humans
                |> List.map
                    (\h ->
                        span [ class "whitespace-nowrap" ]
                            [ img [ src h.avatar, class "inline-block h-4 w-4 mr-1 rounded-full" ] []
                            , text h.name
                            ]
                    )
                |> List.intersperse (text ",")
            )
        )



-- , div [ class "flex justify-end h-12 bg-gray-200" ]
--     [ a
--         [ href (whatsappUrl human.phone)
--         , class "flex items-center bg-green-500 text-white px-4 font-bold"
--         , target "_blank"
--         ]
--         [ Icon.viewIcon Icon.whatsapp
--         , span [ class "ml-2" ] [ text "WhatsApp" ]
--         ]
--     ]
-- ]


whatsappUrl : String -> String
whatsappUrl rawPhone =
    "https://api.whatsapp.com/send?phone=" ++ Utils.cleanPhoneNumber rawPhone


empty : Human
empty =
    { id = ""
    , alias = ""
    , name = ""
    , email = ""
    , phone = ""
    , avatar = ""
    , bio = ""
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


data2 : Human
data2 =
    { id = "human2"
    , alias = "CelesteStars"
    , name = "Celeste Balencia"
    , email = "celeste.stars7@gmail.com"
    , phone = "+54 223 684-7367"
    , avatar = "http://1.gravatar.com/avatar/22a73abc3ffbd5861bd8f8ec1d11aa1a?size=200"
    , bio = ""
    }
