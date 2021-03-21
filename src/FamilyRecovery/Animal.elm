module FamilyRecovery.Animal exposing (..)

import FamilyRecovery.Card as Card
import FamilyRecovery.Human as Human
import FamilyRecovery.Sex as Sex
import FamilyRecovery.Specie as Specie
import Html exposing (Html, a, div, img, input, span, text)
import Html.Attributes exposing (class, href, placeholder, src, target, value)


type alias Animal =
    { id : String
    , family : List Human.Human
    , name : String
    , specie : Specie.Specie
    , sex : Sex.Sex
    , bio : String
    , photos : List String
    }


cardView : Animal -> Html msg
cardView animal =
    Card.view "Animal"
        (div [ class "flex items-start" ]
            [ div [ class "w-32 overflow-hidden rounded-md" ]
                [ animal.photos
                    |> List.head
                    |> Maybe.andThen (\photoSrc -> Just (img [ src photoSrc, class "object-cover w-full" ] []))
                    |> Maybe.withDefault (text "No photo")
                ]
            , div [ class "ml-4 flex-grow" ]
                [ div [ class "text-xl mb-1" ]
                    [ input [ placeholder "Nombre", value animal.name, class "w-full" ] []
                    ]
                , Card.row <|
                    Card.tagsWrapper
                        [ Card.tagView "Especie" (text (Specie.label animal.specie ++ " " ++ Specie.emoji animal.specie))
                        , Card.tagView "Sexo"
                            (div [ class "flex items-center" ]
                                [ text (Sex.label animal.sex)
                                , span [ class "ml-1" ] [ Sex.fullIcon animal.sex ]
                                ]
                            )
                        , Human.tagsView "Familia humana" animal.family
                        ]
                , div [] [ Card.textBoxView "Bio" animal.bio ]
                ]
            ]
        )


empty : Animal
empty =
    { id = ""
    , family = []
    , name = ""
    , specie = Specie.Other
    , sex = Sex.Male
    , bio = ""
    , photos = []
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
