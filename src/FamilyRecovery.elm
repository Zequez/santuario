----------------------------------------- ███████╗███╗   ███╗██╗██╗     ███████╗
----------------------------------------- ██╔════╝████╗ ████║██║██║     ██╔════╝
----------------------------------------- ███████╗██╔████╔██║██║██║     █████╗
----------------------------------------- ╚════██║██║╚██╔╝██║██║██║     ██╔══╝
----------------------------------------- ███████║██║ ╚═╝ ██║██║███████╗███████╗
----------------------------------------- ╚══════╝╚═╝     ╚═╝╚═╝╚══════╝╚══════╝
-- ██╗   ██╗ ██████╗ ██╗   ██╗     █████╗ ██████╗ ███████╗    ███████╗███╗   ██╗ ██████╗ ██╗   ██╗ ██████╗ ██╗  ██╗
-- ╚██╗ ██╔╝██╔═══██╗██║   ██║    ██╔══██╗██╔══██╗██╔════╝    ██╔════╝████╗  ██║██╔═══██╗██║   ██║██╔════╝ ██║  ██║
--  ╚████╔╝ ██║   ██║██║   ██║    ███████║██████╔╝█████╗      █████╗  ██╔██╗ ██║██║   ██║██║   ██║██║  ███╗███████║
--   ╚██╔╝  ██║   ██║██║   ██║    ██╔══██║██╔══██╗██╔══╝      ██╔══╝  ██║╚██╗██║██║   ██║██║   ██║██║   ██║██╔══██║
--    ██║   ╚██████╔╝╚██████╔╝    ██║  ██║██║  ██║███████╗    ███████╗██║ ╚████║╚██████╔╝╚██████╔╝╚██████╔╝██║  ██║
--    ╚═╝    ╚═════╝  ╚═════╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝


module FamilyRecovery exposing (main)

import Browser
import Date exposing (Date, fromCalendarDate)
import FontAwesome.Styles
import Html exposing (Html, a, div, h2, img, input, node, option, select, span, text)
import Html.Attributes exposing (attribute, class, href, placeholder, src, style, title, value)
import Html.Events exposing (on, onInput)
import Json.Decode as JD
import Json.Encode as JE
import Regex
import Round
import Sex
import Specie
import Task exposing (Task)
import Time



------------------------------------ ████████╗██╗   ██╗██████╗ ███████╗███████╗
------------------------------------ ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
------------------------------------    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
------------------------------------    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
------------------------------------    ██║      ██║   ██║     ███████╗███████║
------------------------------------    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝


type alias Model =
    { player : Player
    , reports : List MissingReport
    , geolocation : GeoLocation
    , searchKm : Float
    , today : Date
    , query : String
    , querySex : Maybe Sex.Sex
    , querySpecie : Maybe Specie.Specie
    }


type alias Player =
    { alias : String
    , name : String
    , phone : String
    , email : String
    , avatar : String
    }


type alias MissingReport =
    { id : String
    , player : Player
    , animal : Animal
    , spaceTime : SpaceTime
    }


type alias ContextualizedMissingReport =
    { report : MissingReport
    , daysAgo : Int
    , kmAway : Maybe Float
    }


type alias Animal =
    { name : String
    , specie : Specie.Specie
    , sex : Sex.Sex
    , description : String
    , contact : String
    , photos : List String
    }


type alias GeoLocation =
    Maybe ( Float, Float )


type alias SpaceTime =
    { date : Date
    , location : ( Float, Float )
    }



-------- ████████╗███████╗███████╗████████╗    ██████╗  █████╗ ████████╗ █████╗
-------- ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
--------    ██║   █████╗  ███████╗   ██║       ██║  ██║███████║   ██║   ███████║
--------    ██║   ██╔══╝  ╚════██║   ██║       ██║  ██║██╔══██║   ██║   ██╔══██║
--------    ██║   ███████╗███████║   ██║       ██████╔╝██║  ██║   ██║   ██║  ██║
--------    ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝


testPlayer : Player
testPlayer =
    { alias = "Zequez"
    , name = "Ezequiel Schwartzman"
    , email = "zequez@gmail.com"
    , phone = "+54 9 223 5235568"
    , avatar = "https://en.gravatar.com/userimage/10143531/5dea71d35686673d0d93a3d0de968b64.png?size=200"
    }


testAnimal : Animal
testAnimal =
    { name = "Marley"
    , specie = Specie.Dog
    , sex = Sex.Male
    , description = "He's a good boy"
    , contact = "Call Zequez @ +5492235235568"
    , photos = [ "https://placekitten.com/200/200" ]
    }


testAnimal2 : Animal
testAnimal2 =
    { name = "Meri"
    , specie = Specie.Cat
    , sex = Sex.Female
    , description = "She's a little timid"
    , contact = "Call Zequez @ +5492235235568"
    , photos = [ "https://placekitten.com/225/225" ]
    }


testAnimal3 : Animal
testAnimal3 =
    { testAnimal2 | name = "Popote", photos = [ "https://placekitten.com/220/220" ] }


testAnimal4 : Animal
testAnimal4 =
    { testAnimal2 | name = "Mark", photos = [ "https://placekitten.com/210/210" ] }


testReports : List MissingReport
testReports =
    [ { id = "one"
      , player = testPlayer
      , animal = testAnimal
      , spaceTime =
            { date = Date.fromCalendarDate 2021 Time.Feb 4
            , location = ( -38.0631442, -57.5572745 )
            }
      }
    , { id = "two"
      , player = testPlayer
      , animal = testAnimal2
      , spaceTime =
            { date = Date.fromCalendarDate 2021 Time.Jan 22
            , location = ( -38.0139405, -57.5610563 )
            }
      }
    , { id = "three"
      , player = testPlayer
      , animal = testAnimal3
      , spaceTime =
            { date = Date.fromCalendarDate 2021 Time.Jan 4
            , location = ( -38.0431048, -57.5694195 )
            }
      }
    , { id = "four"
      , player = testPlayer
      , animal = testAnimal4
      , spaceTime =
            { date = Date.fromCalendarDate 2020 Time.Dec 14
            , location = ( -37.9777782, -57.5753418 )
            }
      }
    ]



------------------------------------------------------ ██╗███╗   ██╗██╗████████╗
------------------------------------------------------ ██║████╗  ██║██║╚══██╔══╝
------------------------------------------------------ ██║██╔██╗ ██║██║   ██║
------------------------------------------------------ ██║██║╚██╗██║██║   ██║
------------------------------------------------------ ██║██║ ╚████║██║   ██║
------------------------------------------------------ ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝


init : ( Model, Cmd Msg )
init =
    ( { player = testPlayer
      , reports = testReports
      , geolocation = Nothing
      , searchKm = 5.0
      , today = Date.fromCalendarDate 2020 Time.Jan 1
      , query = ""
      , querySex = Nothing
      , querySpecie = Nothing
      }
    , Date.today |> Task.perform ReceiveDate
    )


main : Program () Model Msg
main =
    Browser.document
        { init = always init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



---------------------------- ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗
---------------------------- ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
---------------------------- ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗
---------------------------- ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝
---------------------------- ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗
----------------------------  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝


type Msg
    = ReceiveDate Date
    | ClickedMarker String
    | SearchTyping String
    | PickSpecie String
    | PickSex String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDate date ->
            ( { model | today = date }, Cmd.none )

        ClickedMarker str ->
            ( model, Cmd.none )

        SearchTyping query ->
            ( { model | query = query }, Cmd.none )

        PickSpecie str ->
            ( { model
                | querySpecie =
                    if str == "all" then
                        Nothing

                    else
                        Just (Specie.fromSlug str)
              }
            , Cmd.none
            )

        PickSex str ->
            ( { model
                | querySex =
                    if str == "all" then
                        Nothing

                    else
                        Just (Sex.fromSlug str)
              }
            , Cmd.none
            )



---------------------------------------- ██╗   ██╗██╗███████╗██╗    ██╗███████╗
---------------------------------------- ██║   ██║██║██╔════╝██║    ██║██╔════╝
---------------------------------------- ██║   ██║██║█████╗  ██║ █╗ ██║███████╗
---------------------------------------- ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║╚════██║
----------------------------------------  ╚████╔╝ ██║███████╗╚███╔███╔╝███████║
----------------------------------------   ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚══════╝


docTitle : String
docTitle =
    "Animales perdides y encontrades"


maybeFilter : Maybe k -> k -> Bool
maybeFilter maybeK val =
    case maybeK of
        Just k ->
            k == val

        Nothing ->
            True


view : Model -> Browser.Document Msg
view model =
    let
        filteredReports =
            model.reports
                |> List.filter
                    (\r ->
                        searchString r.animal.name model.query
                            && maybeFilter model.querySpecie r.animal.specie
                            && maybeFilter model.querySex r.animal.sex
                    )

        contextualizedReports =
            filteredReports
                |> List.map (contextualizeReport model.today model.geolocation)
                |> List.sortBy .daysAgo
    in
    Browser.Document docTitle
        [ div [ class "text-white" ]
            [ FontAwesome.Styles.css
            , headerBackView docTitle
            , mapView filteredReports
            , div [ class "container mx-auto p-4" ]
                [ filterView
                , reportsListView contextualizedReports
                ]
            ]
        ]


headerView : Html msg
headerView =
    div
        [ class """
            h-12 bg-white bg-opacity-25 flex items-center
            justify-center text-2xl text-spacing  shadow-md"""
        ]
        [ a [ href "/" ] [ text "SANTUARIO" ]
        ]


headerBackView : String -> Html msg
headerBackView pageTitle =
    div [ class "h-12 bg-white bg-opacity-25 flex items-center" ]
        [ a [ href "/", class "text-2xl w-12 text-center" ] [ text "❮" ]
        , div [ class "flex-grow font-semibold text-xl tracking-wider text-white" ] [ text pageTitle ]
        ]


type alias ImageMarker =
    { src : String
    , lat : Float
    , lng : Float
    , id : String
    }


imageMarkersEncode : List ImageMarker -> JE.Value
imageMarkersEncode imageMarkers =
    imageMarkers
        |> JE.list
            (\imageMarker ->
                JE.object
                    [ ( "src", JE.string imageMarker.src )
                    , ( "lat", JE.float imageMarker.lat )
                    , ( "lng", JE.float imageMarker.lng )
                    , ( "id", JE.string imageMarker.id )
                    ]
            )


reportToMarker : MissingReport -> ImageMarker
reportToMarker report =
    { src = Maybe.withDefault "" (List.head report.animal.photos)
    , lat = Tuple.first report.spaceTime.location
    , lng = Tuple.second report.spaceTime.location
    , id = report.id
    }


onMarkerClick : (String -> msg) -> Html.Attribute msg
onMarkerClick message =
    on "markerClick" (JD.map message (JD.at [ "detail", "id" ] JD.string))


mapView : List MissingReport -> Html Msg
mapView reports =
    let
        markers : List ImageMarker
        markers =
            reports
                |> List.map reportToMarker
    in
    div [ style "height" "400px", class "w-full" ]
        [ node "mapbox-element"
            [ attribute "images" (JE.encode 0 (imageMarkersEncode markers))
            , attribute "lat" "-38.0139405"
            , attribute "lng" "-57.5610563"
            , attribute "zoom" "10"
            , onMarkerClick ClickedMarker
            ]
            []
        ]


filterView : Html Msg
filterView =
    div [ class "mb-4" ]
        [ input
            [ class "px-4 py-2 text-xl rounded-md w-full text-black"
            , placeholder "Buscar..."
            , onInput SearchTyping
            ]
            []
        , div [ class "mt-4 text-black" ]
            [ select [ class "p-2 rounded-md", onInput PickSpecie ]
                (option [ value "all" ] [ text "Todas las especies" ]
                    :: (Specie.all
                            |> List.map Specie.htmlOption
                       )
                )
            , select [ class "p-2 rounded-md ml-4", onInput PickSex ]
                (option [ value "all" ] [ text "Macho/Hembra" ]
                    :: (Sex.all
                            |> List.map Sex.htmlOption
                       )
                )
            ]
        ]


reportsListView : List ContextualizedMissingReport -> Html msg
reportsListView reports =
    div [ class "grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4" ] (List.map reportsCardView reports)


reportsCardView : ContextualizedMissingReport -> Html msg
reportsCardView cReport =
    let
        animal =
            cReport.report.animal

        report =
            cReport.report
    in
    a [ class "bg-white text-gray-800 shadow-md overflow-hidden rounded-md", href "/" ]
        [ div [ class "h-40 overflow-hidden" ]
            [ img
                [ class "object-cover w-full"
                , src (Maybe.withDefault "" (List.head animal.photos))
                ]
                []
            ]
        , div [ class "p-2 bg-white" ]
            [ div [ class "flex items-center" ]
                [ div [ class "flex-grow" ]
                    [ text report.animal.name ]
                , div
                    [ class "flex items-center" ]
                    [ span [ title (Specie.label animal.specie) ]
                        [ text (Specie.emoji animal.specie) ]
                    , div
                        [ title (Sex.label animal.sex)
                        , class "rounded-full text-white h-4 w-4 text-center text-xs ml-1"
                        , style "background" (Sex.color animal.sex)
                        ]
                        [ Sex.icon animal.sex ]
                    ]
                ]
            , div [ class "flex text-xs text-gray-600" ]
                [ span [ class "flex-grow" ] [ text ("Hace " ++ String.fromInt cReport.daysAgo ++ " días") ]
                , span []
                    [ text
                        (case cReport.kmAway of
                            Just distance ->
                                Round.round 1 distance ++ "km"

                            Nothing ->
                                "?km"
                        )
                    ]
                ]
            ]
        ]



-- animalCardView : Animal -> Html msg
-- animalCardView animal =
--     div [ class "bg-white text-gray-800" ] [ text animal.name ]


userCardView : Player -> Html msg
userCardView user =
    div [ class "p-4" ]
        [ img
            [ class "h-16 w-16 md:h-24 md:w-24 rounded-full mx-auto md:mx-0 md:mr-6 mb-4"
            , src user.avatar
            ]
            []
        , div
            [ class "text-center md:text-left" ]
            [ h2 [ class "text-lg" ] [ text user.name ]
            , div [ class "text-gray-600" ] [ text user.email ]
            , div [ class "text-gray-600" ] [ text user.phone ]
            ]
        ]



---------------------- ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
---------------------- ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
---------------------- ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
---------------------- ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
---------------------- ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
---------------------- ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝


contextualizeReport : Date -> GeoLocation -> MissingReport -> ContextualizedMissingReport
contextualizeReport today geolocation report =
    { report = report
    , daysAgo = daysBetweenDates report.spaceTime.date today
    , kmAway = Maybe.map (distanceBetweenPoints report.spaceTime.location) geolocation
    }


distanceBetweenPoints : ( Float, Float ) -> ( Float, Float ) -> Float
distanceBetweenPoints ( lat1, lng1 ) ( lat2, lng2 ) =
    2.5


daysBetweenDates : Date -> Date -> Int
daysBetweenDates from to =
    Date.toRataDie to - Date.toRataDie from


normalizationRegex : Regex.Regex
normalizationRegex =
    Maybe.withDefault Regex.never (Regex.fromString "[^a-z0-9\\s]")


normalizeString : String -> String
normalizeString str =
    str
        |> String.toLower
        |> Regex.replace normalizationRegex (\_ -> " ")


regexFromString : String -> Regex.Regex
regexFromString query =
    Maybe.withDefault Regex.never (Regex.fromString query)


searchString : String -> String -> Bool
searchString searchSubject query =
    if query /= "" then
        let
            regexQuery : Regex.Regex
            regexQuery =
                regexFromString (normalizeString query)
        in
        Regex.contains regexQuery (normalizeString searchSubject)

    else
        True
