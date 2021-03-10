module MetaCards.MetaCards exposing (..)

import Browser
import Components.BackHeader as BackHeader
import Html exposing (Html, a, br, button, div, h2, img, input, node, option, p, select, span, text)
import Html.Attributes exposing (attribute, class, classList, href, placeholder, src, style, target, title, value)
import Html.Events exposing (on, onClick, onInput)
import Time


type alias Model =
    { showExplanation : Bool
    , cards : List Card
    }


init : ( Model, Cmd Msg )
init =
    ( { showExplanation = False, cards = [ card1, card2 ] }
    , Cmd.none
    )


main : Program () Model Msg
main =
    Browser.document
        { init = always init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


type Msg
    = ToggleExplanation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleExplanation ->
            ( { model | showExplanation = not model.showExplanation }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    Browser.Document "Meta cards experiment"
        [ BackHeader.view "Meta cards experiment"
        , div [ class "text-white p-4" ]
            [ explanationView model.showExplanation
            , div [ class "text-3xl mb-4" ] [ text "Cards" ]
            , div [ class "mb-4 text-white text-opacity-75" ]
                [ text "Gotta confess, I was literally imagining Pokemon playing cards in my head 😆"
                ]
            , div [ class "grid grid-cols-2 gap-4" ]
                (model.cards
                    |> List.map (\card -> [ genericCardView card, cardView card ])
                    |> List.concat
                )
            ]
        ]


genericCardView : Card -> Html Msg
genericCardView card =
    div [ class "p-2 bg-green-100 rounded-md shadow-md border-green-300 border-4 text-black text-opacity-75" ]
        [ div []
            [ div [ class "p-2 font-bold" ] [ text "Hard data (all cards have this)" ]
            , div [ class "flex flex-wrap justify-start" ]
                [ atomStringView "UUID" (Maybe.withDefault "" card.uuid)
                , atomStringView "CardKind" (cardKindToLabel card.kind)
                , atomStringView "Player" (Maybe.withDefault "" card.owner)
                , atomStringView "Copying" (Maybe.withDefault "" card.follow)
                ]
            , div [ class "p-2 font-bold" ] [ text "Soft data (arbitrary for each card)" ]
            , div
                [ class "flex flex-wrap justify-start" ]
                (card.atoms
                    |> List.map atomView
                )
            , div [ class "p-2" ] [ text "We could add other properties here that wouldn't be reflected on the rendered card; and removing properties used by the card would just make the spaces be empty or change the card rendering. Maybe the View can decide the card isn't valid and ignore it." ]
            ]
        ]


atomView : Atom -> Html Msg
atomView atom =
    case atom of
        Bio str ->
            atomStringView "Bio" str

        Name str ->
            atomStringView "Name" str

        Alias str ->
            atomStringView "Alias" str

        Sex sex ->
            case sex of
                Male ->
                    atomStringView "Sex" "Male"

                Female ->
                    atomStringView "Sex" "Female"

                OtherSex str ->
                    atomStringView "Sex" str

        Specie specie ->
            case specie of
                Dog ->
                    atomStringView "Specie" "Dog"

                Cat ->
                    atomStringView "Specie" "Cat"

                OtherSpecie str ->
                    atomStringView "Specie" str

        _ ->
            div [] []


atomStringView : String -> String -> Html Msg
atomStringView label val =
    div [ class "bg-green-400 rounded-md m-2 flex items-stretch" ]
        [ span [ class "bg-yellow-300 bg-opacity-75 py-1 px-2 flex items-center" ] [ text label ]
        , span [ class "px-2 flex items-center" ] [ text val ]
        ]


cardView : Card -> Html Msg
cardView card =
    case card.kind of
        Animal ->
            cardFrameView
                { name = fetchAtomString PickName card.atoms
                , alias = fetchAtomString PickAlias card.atoms
                , imageSrc = fetchAtomString PickAvatar card.atoms
                , cardType = "Animal"
                , left = fetchAtomString PickSpecie card.atoms
                , right = fetchAtomString PickSex card.atoms
                , description = fetchAtomString PickBio card.atoms
                }

        _ ->
            div [] []


type alias CardFrame =
    { name : String
    , alias : String
    , imageSrc : String
    , cardType : String
    , left : String
    , right : String
    , description : String
    }


cardFrameView : CardFrame -> Html Msg
cardFrameView cardFrame =
    div [ class "p-2 bg-green-100 rounded-md shadow-md border-green-300 border-4 text-black text-opacity-75" ]
        [ div [ class "mb-2" ]
            [ text ("[" ++ cardFrame.cardType ++ "] ")
            , if cardFrame.name == "" then
                span [ class "text-black text-opacity-25" ] [ text "Unknow name" ]

              else
                text cardFrame.name
            , if cardFrame.alias == "" then
                text ""

              else
                text (" (" ++ cardFrame.alias ++ ")")
            ]
        , div [ class "relative h-0", style "padding-top" "62%" ]
            [ div [ class "absolute inset-0 overflow-hidden rounded-md border-4 border-green-300" ]
                [ img [ src cardFrame.imageSrc, class "object-fit w-full" ] []
                ]
            ]
        , div [ class "flex mb-2" ]
            [ div [ class "flex-grow" ] [ text ("[" ++ cardFrame.left ++ "]") ]
            , div [] [ text ("[" ++ cardFrame.right ++ "]") ]
            ]
        , p [ class "h-40 overflow-auto" ]
            [ text cardFrame.description
            ]
        ]


explanationView : Bool -> Html Msg
explanationView expanded =
    div [ class "bg-white bg-opacity-25 py-2 pl-4 pr-2 rounded-md mb-4" ]
        [ div [ class "flex cursor-pointer items-center" ]
            [ div [ class "flex-grow text-xl" ] [ text "What is this?" ]
            , button
                [ class "bg-yellow-600 p-2 rounded-md"
                , onClick ToggleExplanation
                ]
                [ text
                    (if expanded then
                        "I've got it, thanks"

                     else
                        "Read about it"
                    )
                ]
            ]
        , if expanded then
            div [ class "mt-4" ]
                [ ph "So, I've been thinking for a while about a way of modeling data on a general purpose app framework."
                , ph "The idea is to imagine that we're playing a kind of board game with cards."
                , ph "To make it agent centric, each player only sees the cards of others players she considers is playing with."
                , ph "Each player has a personal catalog of owned cards too."
                , ph "Imagine playing chess by mail; you have your own board, and the other person has his own board"
                , ph "The tool ultimately is for the player use, so with the same cards, two players could be playing different games"
                , ph """
                In a sense, I feel it's a model inspired by the Holochain architecture;
                and in fact, the idea is to eventually implement it there, but that
                doesn't mean it cannot be implemented without Holochain; it allows me to
                experiment quicker with the GUI, which is the part I'm interested in.
            """
                , ph """
                The cards can have recognizable types, so for example we can create a Human card
                that has information about a human; the information can be arbitrary, but from the
                GUI there are certain parameters that if used, enhance the visual experience, but the data
                model isn't in hard sense restricted, extra parameters the GUI is not prepared to read are just
                ignored.
                """
                , ph """
                Among the parameters in cards, cards can also be linkeg to each other. So for example, if you have Human
                card you could link it to a Home card and a Family card or other Human cards. Those links can be interpreted
                from specific GUIs, and ignored in other GUIs.
            """
                , ph """
                From the cards in the player Universe we can build graphical interfaces, by filtering, sorting and displaying
                the cards in the screen with specific "views". There could be some default views to just see the filtering/sorting
                raw information, and then we can program specific views for certain filtering parameters that extend the GUI
                to make information easier to digest.
            """
                , ph """
                So in a sense is a kind of visually programmable agent-centric API structure that you can extend with
                customized views.
            """
                , ph """
                Information is added to the system by adding cards, adding parameters to cards, and linking cards to other cards.
            """
                , ph """
                    I have no idea where this is going, but I've gotta see if it leads somewhere.
                """
                , div [ class "flex justify-end" ]
                    [ button
                        [ class "bg-yellow-600 p-2 rounded-md"
                        , onClick ToggleExplanation
                        ]
                        [ text "I've got it thanks"
                        ]
                    ]
                ]

          else
            div [] []
        ]


ph : String -> Html msg
ph txt =
    p [ class "pb-2" ] [ text txt ]



-- type alias UUID =
--     String
-- type alias CardKind =
--     String
-- type alias LinkGroup =
--     String
-- Atomic units of information, we'll add more as needed by the ecosystem apps


type alias Card =
    { uuid : Maybe String
    , kind : CardKind
    , follow : Maybe String
    , owner : Maybe String
    , atoms : List Atom
    }


type CardKind
    = Human
    | Animal
    | Report
    | CustomKind String


cardKindToLabel : CardKind -> String
cardKindToLabel cardKind =
    case cardKind of
        Human ->
            "Human"

        Animal ->
            "Animal"

        Report ->
            "Report"

        CustomKind str ->
            "Custom: " ++ str


card1 : Card
card1 =
    { uuid = Nothing
    , kind = Animal
    , follow = Nothing
    , owner = Nothing
    , atoms =
        [ Name "Barry Furballton"
        , Alias "CatnipLife"
        , Sex Male
        , Specie Cat
        , Bio "Barry is a very special cat, he likes catnip, lasagna, and has a lot of fur"
        , Avatar "https://placekitten.com/350/250"
        , Cover "/catlife.jpg"
        ]
    }


card2 : Card
card2 =
    { uuid = Nothing
    , kind = Animal
    , follow = Nothing
    , owner = Nothing
    , atoms =
        [ Sex Female
        , Specie Dog
        , Bio "We found this strange dog, near my home, it's very furry and barks weird. (all the images are from Placekitten.com)"
        , Avatar "https://placekitten.com/400/400"
        , Cover "/catlife.jpg"
        ]
    }



-- pickAtoms : List (k -> Atom) -> List Atom -> List Atom
-- pickAtoms atomsToPick atomsList =
--     atomsToPick
-- findAtoms : String -> List Atom -> List Atom
-- findAtoms atomType atoms =
--     case atomType of
--         "bio" ->
--             atoms
--                 |> List.filter (\a -> )
--         _ ->
--             atoms
-- multiPickAtoms : List AtomPick -> List Atom


fetchAtomString : AtomPick -> List Atom -> String
fetchAtomString atomPick atoms =
    Maybe.withDefault "" (fetchMaybeAtomString atomPick atoms)


fetchMaybeAtomString : AtomPick -> List Atom -> Maybe String
fetchMaybeAtomString atomPick atoms =
    Maybe.map unwrapString (pickAtom atomPick atoms)


unwrapString : Atom -> String
unwrapString atom =
    case atom of
        Bio str ->
            str

        Name str ->
            str

        Alias str ->
            str

        Sex sex ->
            case sex of
                Male ->
                    "Male"

                Female ->
                    "Female"

                OtherSex str ->
                    str

        Specie specie ->
            case specie of
                Dog ->
                    "Dog"

                Cat ->
                    "Cat"

                OtherSpecie str ->
                    str

        Avatar str ->
            str

        _ ->
            ""



-- Name String
-- Alias String
-- Sex Sex
-- Specie Specie
-- Doc String
-- Title String
-- -- Connection like
-- Channel Channel
-- -- Photos like
-- Avatar String
-- Photos (List String)
-- Cover String
-- -- Location like
-- Location ( Float, Float )
-- Location2d (List ( Float, Float ))
-- -- Date like
-- Date Time.Posix
-- -- Misc
-- Icon String
-- Color String
-- Property String String


pickAtom : AtomPick -> List Atom -> Maybe Atom
pickAtom pickFrom atoms =
    atoms
        |> pickAtoms pickFrom
        |> List.head


pickAtoms : AtomPick -> List Atom -> List Atom
pickAtoms pickFrom atoms =
    atoms
        |> List.filterMap (matchAtom pickFrom)


matchAtom : AtomPick -> Atom -> Maybe Atom
matchAtom pickFrom atom =
    case ( pickFrom, atom ) of
        ( PickBio, Bio str ) ->
            Just (Bio str)

        ( PickName, Name str ) ->
            Just (Name str)

        ( PickAlias, Alias str ) ->
            Just (Alias str)

        ( PickSpecie, Specie str ) ->
            Just (Specie str)

        ( PickSex, Sex str ) ->
            Just (Sex str)

        ( PickAvatar, Avatar str ) ->
            Just (Avatar str)

        ( _, _ ) ->
            Nothing


matched1 =
    -- Should return Just (Bio "Hello there")
    pickAtom PickBio [ Bio "Hello there" ]



-- matched2 =
--     -- Should return Nothing
--     matchAtom Name (Bio "Hello nope")
-- Should return Nothing
-- zequez =
--     [ Name "Ezequiel Schwartzman"
--     , Alias "Zequez"
--     , Sex Male
--     , Channel (Url "https://zequez.space")
--     , Channel (Instagram "zequezs")
--     , Channel (Facebook "Zequez")
--     ]
-- templateCards =
--     [ [ { uuid = Nothing
--         , kind = Human
--         , follow = Nothing -- Another card to copy from
--         , owner = Nothing -- Player UUID
--         , atoms = []
--         }
--       ]
--     ]


type Atom
    = -- Descriptive like
      Bio String
    | Name String
    | Alias String
    | Sex Sex
    | Specie Specie
    | Doc String
    | Title String
      -- Connection like
    | Channel Channel
      -- Photos like
    | Avatar String
    | Photos (List String)
    | Cover String
      -- Location like
    | Location ( Float, Float )
    | Location2d (List ( Float, Float ))
      -- Date like
    | Date Time.Posix
      -- Misc
    | Icon String
    | Color String
    | Property String String


type AtomPick
    = PickBio
    | PickName
    | PickAlias
    | PickSex
    | PickSpecie
    | PickDoc
    | PickTitle
    | PickChannel
    | PickAvatar
    | PickPhotos
    | PickCover
    | PickLocation
    | PickLocation2d
    | PickDate
    | PickIcon
    | PickColor
    | PickProperty



-- atoms : List Atom
-- atoms =
--     [ Bio "", Name "", Alias "" ]
-- type Datex
--     = UnitDate Time.Posix
--     | RangeDate ( Time.Posix, Time.Posix )
--     | RepeatingDate ( Time.Posix, TimeSpan )
--     | MultiDate (List Datex)
-- type MultiDatex
--     = MultiDatex (List Datex)


type TimeSpan
    = Second Int
    | Minute Int
    | Hour Int
    | Day Int
    | Week Int
    | Month Int
    | Year Int


type Specie
    = Dog
    | Cat
    | OtherSpecie String


type Sex
    = Male
    | Female
    | OtherSex String


type Channel
    = Email String
    | Facebook String
    | Instagram String
    | Phone String
    | Telegram String
    | Whatsapp String
    | Url String
    | Matrix String
