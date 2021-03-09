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


module FamilyRecovery.Main exposing (main)

import Browser
import Date exposing (Date, fromCalendarDate)
import FamilyRecovery.Sex as Sex
import FamilyRecovery.Specie as Specie
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import FontAwesome.Styles
import Html exposing (Html, a, br, button, div, h2, img, input, node, option, p, select, span, text)
import Html.Attributes exposing (attribute, class, classList, href, placeholder, src, style, target, title, value)
import Html.Events exposing (on, onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE
import Regex
import Round
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
    , geolocation : GeoLocation
    , searchKm : Float
    , today : Date
    , query : String
    , querySex : Maybe Sex.Sex
    , querySpecie : Maybe Specie.Specie
    , tab : Tab
    , viewing : Maybe String
    }


type Tab
    = MissingTab
    | FoundTab
    | ReunitedTab


type alias Player =
    { alias : String
    , humans : List Human
    , animals : List Animal
    , reports : List Report
    }


type alias Human =
    { id : String
    , alias : String
    , name : String
    , phone : String
    , email : String
    , avatar : String
    , bio : String
    }



-- type alias Home =
--     { id : String
--     , name : String
--     , location : List ( Float, Float )
--     }


type alias Animal =
    { id : String
    , family : List Human
    , name : String
    , specie : Specie.Specie
    , sex : Sex.Sex
    , bio : String
    , photos : List String
    }


type alias Report =
    { id : String
    , animal : Animal
    , humanContact : Human
    , spaceTime : SpaceTime
    , notes : String
    , reportType : ReportType
    , resolved : ReportResolution
    }


type ReportResolution
    = Unresolved
    | Resolved ( Date, String ) -- ID of another report


type ReportType
    = Missing
    | Found


type alias ReportsResolution =
    { reports : List Report
    , date : Date
    }


type alias ContextualizedReport =
    { report : Report
    , daysAgo : Int
    , kmAway : Maybe Float
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


human1 : Human
human1 =
    { id = "human1"
    , alias = "Zequez"
    , name = "Ezequiel Schwartzman"
    , email = "zequez@gmail.com"
    , phone = "+54 9 223 5235568"
    , avatar = "https://en.gravatar.com/userimage/10143531/5dea71d35686673d0d93a3d0de968b64.png?size=200"
    , bio = ""
    }


animal1 : Animal
animal1 =
    { id = "animal1"
    , family = [ human1 ]
    , name = "Marley"
    , specie = Specie.Dog
    , sex = Sex.Male
    , bio = "He's a good boy"
    , photos = [ "https://placekitten.com/200/200" ]
    }


animal2 : Animal
animal2 =
    { id = "animal2"
    , family = [ human1 ]
    , name = "Meri"
    , specie = Specie.Cat
    , sex = Sex.Female
    , bio = "She's a little timid. Mancha marron."
    , photos = [ "https://placekitten.com/225/225" ]
    }


animal3 : Animal
animal3 =
    { animal2 | name = "Popote", photos = [ "https://placekitten.com/220/220" ] }


animal4 : Animal
animal4 =
    { id = "animal4"
    , family = []
    , name = ""
    , specie = Specie.Cat
    , sex = Sex.Female
    , bio = ""
    , photos = [ "https://placekitten.com/270/270" ]
    }


animal5 : Animal
animal5 =
    { id = "animal2"
    , family = []
    , name = ""
    , specie = Specie.Cat
    , sex = Sex.Female
    , bio = ""
    , photos = [ "https://placekitten.com/225/225" ]
    }


report1 : Report
report1 =
    { id = "report1"
    , animal = animal1
    , humanContact = human1
    , spaceTime =
        { date = Date.fromCalendarDate 2021 Time.Feb 4
        , location = ( -38.0631442, -57.5572745 )
        }
    , notes = "Additional notes of the report..."
    , reportType = Missing
    , resolved = Unresolved
    }


report2 : Report
report2 =
    { report1
        | id = "report2"
        , animal = animal2
        , spaceTime = { date = Date.fromCalendarDate 2021 Time.Jan 22, location = ( -38.0139405, -57.5610563 ) }
    }


report3 : Report
report3 =
    { report1
        | id = "report3"
        , animal = animal3
        , spaceTime = { date = Date.fromCalendarDate 2021 Time.Jan 4, location = ( -38.0431048, -57.5694195 ) }
        , resolved = Resolved ( Date.fromCalendarDate 2021 Time.Mar 7, "report5" )
    }


report4 : Report
report4 =
    { report1
        | id = "report4"
        , animal = animal4
        , spaceTime = { date = Date.fromCalendarDate 2020 Time.Dec 14, location = ( -37.9777782, -57.5753418 ) }
        , reportType = Found
    }


report5 : Report
report5 =
    { report1
        | id = "report5"
        , animal = animal5
        , spaceTime = { date = Date.fromCalendarDate 2021 Time.Feb 17, location = ( -37.9477782, -57.5453418 ) }
        , reportType = Found
        , resolved = Resolved ( Date.fromCalendarDate 2021 Time.Mar 7, "report3" )
    }


player1 : Player
player1 =
    { alias = "Zequez"
    , humans = [ human1 ]
    , animals = [ animal1, animal2, animal3, animal4 ]
    , reports =
        [ report1
        , report2
        , report3
        , report4
        , report5
        ]
    }



------------------------------------------------------ ██╗███╗   ██╗██╗████████╗
------------------------------------------------------ ██║████╗  ██║██║╚══██╔══╝
------------------------------------------------------ ██║██╔██╗ ██║██║   ██║
------------------------------------------------------ ██║██║╚██╗██║██║   ██║
------------------------------------------------------ ██║██║ ╚████║██║   ██║
------------------------------------------------------ ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝


init : ( Model, Cmd Msg )
init =
    ( { player = player1
      , geolocation = Nothing
      , searchKm = 5.0
      , today = Date.fromCalendarDate 2020 Time.Jan 1
      , query = ""
      , querySex = Nothing
      , querySpecie = Nothing
      , viewing = Nothing
      , tab = MissingTab
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
    | OpenReport String
    | SearchTyping String
    | PickSpecie String
    | PickSex String
    | SetTab Tab


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDate date ->
            ( { model | today = date }, Cmd.none )

        OpenReport id ->
            ( { model
                | viewing =
                    if List.any (\r -> r.id == id) model.player.reports then
                        Just id

                    else
                        Nothing
              }
            , Cmd.none
            )

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

        SetTab tab ->
            ( { model | tab = tab }, Cmd.none )



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
            model.player.reports
                |> List.filter
                    (\r ->
                        (case model.tab of
                            MissingTab ->
                                r.reportType == Missing && r.resolved == Unresolved

                            FoundTab ->
                                r.reportType == Found && r.resolved == Unresolved

                            ReunitedTab ->
                                r.resolved /= Unresolved
                        )
                            && (searchString r.animal.name model.query
                                    || searchString r.animal.bio model.query
                               )
                            && maybeFilter model.querySpecie r.animal.specie
                            && maybeFilter model.querySex r.animal.sex
                    )

        contextualizedReports =
            filteredReports
                |> List.map (contextualizeReport model.today model.geolocation)
                |> List.sortBy .daysAgo

        maybeViewingReport : Maybe ContextualizedReport
        maybeViewingReport =
            model.viewing
                |> Maybe.andThen
                    (\reportId ->
                        contextualizedReports
                            |> List.filter (\r -> r.report.id == reportId)
                            |> List.head
                    )
    in
    Browser.Document docTitle
        [ div [ class "text-white" ]
            [ FontAwesome.Styles.css
            , headerBackView docTitle
            , mapView filteredReports
            , case maybeViewingReport of
                Just report ->
                    reportPageView report

                Nothing ->
                    div [ class "container mx-auto p-4 pb-20" ]
                        [ filterView
                        , if model.tab == ReunitedTab then
                            reportsResolutionsView contextualizedReports

                          else
                            reportsListView contextualizedReports
                        ]
            ]
        , tabsView model.tab
        ]


type alias ResolvedReportsPairs =
    { missing : ContextualizedReport
    , maybeFound : Maybe ContextualizedReport
    , date : Date
    }


reportsResolutionsView : List ContextualizedReport -> Html Msg
reportsResolutionsView cReports =
    let
        reportsPairs : List ResolvedReportsPairs
        reportsPairs =
            cReports
                |> List.filterMap
                    (\cr ->
                        case ( cr.report.reportType, cr.report.resolved ) of
                            ( Missing, Resolved ( date, id ) ) ->
                                Just
                                    { missing = cr
                                    , maybeFound =
                                        cReports
                                            |> List.filter (\cr2 -> cr2.report.id == id)
                                            |> List.head
                                    , date = date
                                    }

                            ( _, _ ) ->
                                Nothing
                    )
    in
    div []
        (reportsPairs
            |> List.map
                (\{ missing, maybeFound, date } ->
                    div [ class "bg-white rounded-md p-4 text-black text-center text-xl" ]
                        [ div [] [ text ("¡" ++ missing.report.animal.name ++ " se reencontró con su familia!") ]
                        , div [ class "text-black text-opacity-50 mb-4" ]
                            [ text
                                ("Después de "
                                    ++ String.fromInt (daysBetweenDates missing.report.spaceTime.date date)
                                    ++ " días"
                                    ++ (case maybeFound of
                                            Just found ->
                                                " a "
                                                    ++ Round.round 1 (distanceBetweenPoints found.report.spaceTime.location missing.report.spaceTime.location)
                                                    ++ "km de distancia"

                                            Nothing ->
                                                ""
                                       )
                                )
                            ]
                        , div [ class "flex items-center justify-center text-black text-opacity-50 text-xs" ]
                            [ div []
                                [ div [ class "relative" ]
                                    [ img [ class "h-32 w-32 rounded-full mx-2 mb-2 border-2 border-white shadow-md", src (Maybe.withDefault "" (List.head missing.report.animal.photos)) ] []
                                    , case Maybe.andThen (\f -> List.head f.report.animal.photos) maybeFound of
                                        Just photoSrc ->
                                            img
                                                [ class "h-12 w-12 rounded-full absolute bottom-0 right-0 border-2 border-white shadow-md"
                                                , src photoSrc
                                                ]
                                                []

                                        Nothing ->
                                            div [] []
                                    ]
                                , text missing.report.animal.name
                                ]
                            , span [ class "text-red-500 text-6xl p-4 rounded-full" ]
                                [ Icon.viewIcon Icon.heart
                                ]
                            , div []
                                [ img [ class "h-32 w-32 rounded-full mx-2 mb-2 border-2 border-white shadow-md", src missing.report.humanContact.avatar ] []
                                , text missing.report.humanContact.name
                                ]
                            ]
                        , case maybeFound of
                            Just found ->
                                p [ class "text-base mt-4" ]
                                    [ text ("Gracias un reporte de " ++ found.report.humanContact.name)
                                    ]

                            Nothing ->
                                div [] []
                        ]
                )
        )


tabButton : String -> Icon -> Bool -> Tab -> Html Msg
tabButton label icon active tab =
    button
        [ class "flex-grow tracking-wide uppercase font-bold hover:bg-yellow-400 focus:bg-yellow-400 focus:outline-none"
        , classList
            [ ( "bg-yellow-400", active )
            ]
        , onClick (SetTab tab)
        ]
        [ span [ class "text-xl" ] [ Icon.viewIcon icon ]
        , br [] []
        , text label
        ]


tabsView : Tab -> Html Msg
tabsView currentTab =
    div [ class "flex fixed z-20 inset-x-0 bottom-0 h-16 bg-yellow-300 text-white" ]
        [ tabButton "Separades" Icon.heartBroken (currentTab == MissingTab) MissingTab
        , tabButton "Encontrades" Icon.binoculars (currentTab == FoundTab) FoundTab
        , tabButton "Reunides" Icon.heart (currentTab == ReunitedTab) ReunitedTab
        ]


reportPageView : ContextualizedReport -> Html Msg
reportPageView cReport =
    let
        report =
            cReport.report

        animal =
            report.animal

        human =
            report.humanContact
    in
    div [ class "absolute top-0 min-h-full w-full bg-green-600 z-30" ]
        [ buttonBackView
            (if animal.name == "" then
                "Identidad desconocida"

             else
                animal.name
            )
            (OpenReport "")
        , div []
            (report.animal.photos
                |> List.map (\p -> img [ src p, class "w-full" ] [])
            )
        , div [ class "tracking-wide" ]
            [ div [ class "bg-yellow-400 bg-opacity-25 p-4 mb-2" ]
                [ div [ class "mb-2 flex" ]
                    [ div [ class "flex-grow" ]
                        [ span [ class "font-bold" ] [ text "Especie: " ]
                        , text (Specie.emoji report.animal.specie ++ " " ++ Specie.label report.animal.specie)
                        ]
                    , div [ class "flex items-center" ]
                        [ div
                            [ class "rounded-full text-white h-4 w-4 text-center text-xs mr-1"
                            , style "background" (Sex.color animal.sex)
                            ]
                            [ Sex.icon animal.sex ]
                        , text (Sex.label animal.sex)
                        ]
                    ]
                , div [ class "flex" ]
                    [ div [ class "flex-grow" ]
                        [ text
                            ((case report.reportType of
                                Missing ->
                                    "Desapareció"

                                Found ->
                                    "Encontrade"
                             )
                                ++ " hace "
                                ++ String.fromInt cReport.daysAgo
                                ++ " días"
                            )
                        ]
                    , span
                        [ class "text-white text-opacity-75" ]
                        [ text (Date.format "EEEE, d MMMM y" report.spaceTime.date) ]
                    ]
                ]
            , div [ class "p-4" ]
                [ p [ class "mb-4" ] [ text report.animal.bio ]
                , h2 [ class "text-2xl mb-2" ] [ text "Datos de contacto" ]
                , div [ class "bg-yellow-400 bg-opacity-25 rounded-md overflow-hidden" ]
                    [ div [ class "flex" ]
                        [ img [ src human.avatar, class "h-24 w-24" ] []
                        , div [ class "flex-grow p-2" ]
                            [ div [ class "text-xl" ]
                                [ text human.alias
                                , span [ class "text-white text-sm text-opacity-75" ] [ text (" (" ++ human.name ++ ")") ]
                                ]
                            , div [ class "flex" ]
                                [ div [ class "flex-grow" ]
                                    [ div [] [ text human.email ]
                                    , div [] [ text human.phone ]
                                    ]
                                , a
                                    [ href ("https://api.whatsapp.com/send?phone=" ++ cleanPhoneNumber human.phone)
                                    , class "flex items-center bg-green-500 rounded-md px-4 font-bold"
                                    , target "_blank"
                                    ]
                                    [ Icon.viewIcon Icon.whatsapp
                                    , span [ class "ml-2" ] [ text "WhatsApp" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


buttonBackView : String -> Msg -> Html Msg
buttonBackView pageTitle msg =
    div [ class "h-12 bg-yellow-400 bg-opacity-25 flex items-center" ]
        [ button [ class "text-2xl w-12 text-center", onClick msg ] [ text "❮" ]
        , div [ class "flex-grow font-semibold text-xl tracking-wider text-white" ] [ text pageTitle ]
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


reportToMarker : Report -> ImageMarker
reportToMarker report =
    { src = Maybe.withDefault "" (List.head report.animal.photos)
    , lat = Tuple.first report.spaceTime.location
    , lng = Tuple.second report.spaceTime.location
    , id = report.id
    }


onMarkerClick : (String -> msg) -> Html.Attribute msg
onMarkerClick message =
    on "markerClick" (JD.map message (JD.at [ "detail", "id" ] JD.string))


mapView : List Report -> Html Msg
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
            , onMarkerClick OpenReport
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


reportsListView : List ContextualizedReport -> Html Msg
reportsListView reports =
    div [ class "grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4" ]
        (List.map reportsCardView reports)


reportsCardView : ContextualizedReport -> Html Msg
reportsCardView cReport =
    let
        animal =
            cReport.report.animal

        report =
            cReport.report
    in
    a [ class "bg-white text-gray-800 shadow-md overflow-hidden rounded-md cursor-pointer", onClick (OpenReport report.id) ]
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
                    [ if report.animal.name == "" then
                        span [ class "text-black text-opacity-25" ] [ text "Identidad desconocida" ]

                      else
                        text report.animal.name
                    ]
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



---------------------- ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
---------------------- ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
---------------------- ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
---------------------- ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
---------------------- ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
---------------------- ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝


contextualizeReport : Date -> GeoLocation -> Report -> ContextualizedReport
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


cleanPhoneNumber : String -> String
cleanPhoneNumber phone =
    let
        regex =
            Maybe.withDefault Regex.never (Regex.fromString "[^0-9]")
    in
    phone
        |> Regex.replace regex (\_ -> "")


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
