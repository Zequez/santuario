module FamilyRecovery.Main exposing (main)

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

import Browser
import Components.BackHeader as BackHeader
import Date exposing (Date)
import FamilyRecovery.Animal as Animal
import FamilyRecovery.Human as Human
import FamilyRecovery.Mapbox as Mapbox
import FamilyRecovery.Modal as Modal
import FamilyRecovery.Player as Player
import FamilyRecovery.Report as Report
import FamilyRecovery.Sex as Sex
import FamilyRecovery.Specie as Specie
import FamilyRecovery.Utils as Utils
import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon exposing (Icon)
import FontAwesome.Solid as Icon
import FontAwesome.Styles
import Html exposing (Html, a, br, button, div, h2, img, input, option, p, select, span, text)
import Html.Attributes exposing (class, classList, href, placeholder, src, style, target, title, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE
import Regex
import Round
import Task
import Time



------------------------------------ ████████╗██╗   ██╗██████╗ ███████╗███████╗
------------------------------------ ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
------------------------------------    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
------------------------------------    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
------------------------------------    ██║      ██║   ██║     ███████╗███████║
------------------------------------    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝


type alias Model =
    { player : Player.Player
    , geolocation : Report.GeoLocation
    , searchKm : Float
    , today : Date
    , query : String
    , querySex : Maybe Sex.Sex
    , querySpecie : Maybe Specie.Specie
    , tab : Tab
    , modal : Modal
    }


type Tab
    = MissingTab
    | FoundTab
    | ReunitedTab


type Modal
    = NoModal
    | ViewReport String
    | EditReport Report.Report



-- type alias Home =
--     { id : String
--     , name : String
--     , location : List ( Float, Float )
--     }
-------- ████████╗███████╗███████╗████████╗    ██████╗  █████╗ ████████╗ █████╗
-------- ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
--------    ██║   █████╗  ███████╗   ██║       ██║  ██║███████║   ██║   ███████║
--------    ██║   ██╔══╝  ╚════██║   ██║       ██║  ██║██╔══██║   ██║   ██╔══██║
--------    ██║   ███████╗███████║   ██║       ██████╔╝██║  ██║   ██║   ██║  ██║
--------    ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝
------------------------------------------------------ ██╗███╗   ██╗██╗████████╗
------------------------------------------------------ ██║████╗  ██║██║╚══██╔══╝
------------------------------------------------------ ██║██╔██╗ ██║██║   ██║
------------------------------------------------------ ██║██║╚██╗██║██║   ██║
------------------------------------------------------ ██║██║ ╚████║██║   ██║
------------------------------------------------------ ╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝


init : ( Model, Cmd Msg )
init =
    ( { player = Player.data1
      , geolocation = Nothing
      , searchKm = 5.0
      , today = Date.fromCalendarDate 2020 Time.Jan 1
      , query = ""
      , querySex = Nothing
      , querySpecie = Nothing
      , tab = MissingTab
      , modal = NoModal
      }
    , Date.today |> Task.perform ReceiveDate
    )


main : Program () Model Msg
main =
    Browser.element
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
    | SearchTyping String
    | PickSpecie String
    | PickSex String
    | SetTab Tab
    | SetModal Modal


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceiveDate date ->
            ( { model | today = date }, Cmd.none )

        -- OpenReport id ->
        --     ( { model
        --         | viewing =
        --             if List.any (\r -> r.id == id) model.player.reports then
        --                 Just id
        --             else
        --                 Nothing
        --       }
        --     , Cmd.none
        --     )
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

        SetModal modal ->
            ( { model | modal = modal }, Cmd.none )



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


view : Model -> Html Msg
view model =
    let
        filteredReports =
            model.player.reports
                |> List.filter
                    (\r ->
                        (case model.tab of
                            MissingTab ->
                                r.reportType == Report.Missing && r.resolved == Report.Unresolved

                            FoundTab ->
                                r.reportType == Report.Found && r.resolved == Report.Unresolved

                            ReunitedTab ->
                                r.resolved /= Report.Unresolved
                        )
                            && (searchString r.animal.name model.query
                                    || searchString r.animal.bio model.query
                               )
                            && maybeFilter model.querySpecie r.animal.specie
                            && maybeFilter model.querySex r.animal.sex
                    )

        contextualizedReports =
            filteredReports
                |> List.map (Report.contextualize model.today model.geolocation)
                |> List.sortBy .daysAgo
    in
    div [ class "text-white bg-gray-100 min-h-full" ]
        [ FontAwesome.Styles.css
        , BackHeader.view docTitle
        , tabsView model.tab
        , Mapbox.mapView filteredReports (SetModal << ViewReport)
        , actionButtonView (SetModal (EditReport Report.data1))

        -- Modals
        , case model.modal of
            ViewReport id ->
                case Report.findById id contextualizedReports of
                    Just cReport ->
                        reportShowModalView cReport

                    Nothing ->
                        div [] []

            EditReport report ->
                reportEditModalView report

            NoModal ->
                div [] []

        -- Tabs pages
        , div [ class "container mx-auto p-4 pb-20" ]
            [ filterView
            , if model.tab == ReunitedTab then
                reportsResolutionsView contextualizedReports

              else
                reportsListView contextualizedReports
            ]
        ]


actionButtonView : msg -> Html msg
actionButtonView msg =
    div
        [ class """
            fixed flex items-center justify-center z-40 mb-20 mr-4 bottom-0 right-0 w-16 h-16
            rounded-full bg-yellow-400 text-white font-bold text-2xl cursor-pointer"""
        , onClick msg
        ]
        [ Icon.viewIcon Icon.plus ]


type alias ResolvedReportsPairs =
    { missing : Report.ContextualizedReport
    , maybeFound : Maybe Report.ContextualizedReport
    , date : Date
    }


reportsResolutionsView : List Report.ContextualizedReport -> Html Msg
reportsResolutionsView cReports =
    let
        reportsPairs : List ResolvedReportsPairs
        reportsPairs =
            cReports
                |> List.filterMap
                    (\cr ->
                        case ( cr.report.reportType, cr.report.resolved ) of
                            ( Report.Missing, Report.Resolved ( date, id ) ) ->
                                Just
                                    { missing = cr
                                    , maybeFound = Report.findById id cReports
                                    , date = date
                                    }

                            ( _, _ ) ->
                                Nothing
                    )
    in
    div []
        (reportsPairs
            |> List.map reportsResolutionPairView
        )


reportsResolutionPairView : ResolvedReportsPairs -> Html Msg
reportsResolutionPairView { missing, maybeFound, date } =
    div [ class "bg-white rounded-md p-4 text-black text-center text-xl border border-gray-300" ]
        [ div [] [ text ("¡" ++ missing.report.animal.name ++ " se reencontró con su familia!") ]
        , div [ class "text-black text-opacity-50 mb-4" ]
            [ text
                ("Después de "
                    ++ String.fromInt (Utils.daysBetweenDates missing.report.spaceTime.date date)
                    ++ " días"
                    ++ (case maybeFound of
                            Just found ->
                                " a "
                                    ++ Round.round 1 (Utils.distanceBetweenPoints found.report.spaceTime.location missing.report.spaceTime.location)
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


tabButton : String -> Icon -> Bool -> Tab -> Html Msg
tabButton label icon active tab =
    button
        [ class "flex-grow tracking-wide uppercase font-bold hover:bg-green-400 focus:bg-green-400 focus:outline-none"
        , classList
            [ ( "bg-green-400", active )
            ]
        , onClick (SetTab tab)
        ]
        [ span [ class "text-xl" ] [ Icon.viewIcon icon ]
        , br [] []
        , text label
        ]


tabsView : Tab -> Html Msg
tabsView currentTab =
    div [ class "flex fixed z-20 inset-x-0 bottom-0 h-16 bg-green-300 text-white" ]
        [ tabButton "Separades" Icon.heartBroken (currentTab == MissingTab) MissingTab
        , tabButton "Encontrades" Icon.binoculars (currentTab == FoundTab) FoundTab
        , tabButton "Reunides" Icon.heart (currentTab == ReunitedTab) ReunitedTab
        ]


reportShowModalView : Report.ContextualizedReport -> Html Msg
reportShowModalView cReport =
    let
        report =
            cReport.report

        animal =
            report.animal

        human =
            report.humanContact
    in
    Modal.view
        (if animal.name == "" then
            "Identidad desconocida"

         else
            animal.name
        )
        (SetModal (ViewReport ""))
        (div []
            [ div []
                (report.animal.photos
                    |> List.map (\p -> img [ src p, class "w-full" ] [])
                )
            , div [ class "tracking-wide" ]
                [ div [ class "bg-yellow-400 bg-opacity-75 p-4 mb-2" ]
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
                                    Report.Missing ->
                                        "Desapareció"

                                    Report.Found ->
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
                , div [ class "p-4 text-gray-700" ]
                    [ p [ class "mb-4" ] [ text report.animal.bio ]
                    , h2 [ class "text-2xl mb-2" ] [ text "Familia humana" ]
                    , Human.cardView human
                    ]
                ]
            ]
        )


reportEditModalView : Report.Report -> Html Msg
reportEditModalView report =
    Modal.view "Nuevo Reporte"
        (SetModal NoModal)
        (div [ class "text-black p-4" ]
            [ div [] [ text "Jugador" ]
            , div [] [ text "Humano" ]
            , div [] [ text "Animal" ]
            , div [] [ text "Reporte" ]
            ]
        )



-- div [ class "fixed inset-0 bg-black bg-opacity-25 z-40 p-4" ]
--     [ div [ class "bg-white rounded-md w-full h-full overflow-hidden flex flex-col" ]
--         [ div [ class "relative h-16 bg-yellow-300 uppercase font-bold text-xl tracking-wider flex items-center justify-center" ]
--             [ text "Nuevo reporte"
--             , div
--                 [ class "absolute right-0 h-full w-16 bg-red-400 flex items-center justify-center text-3xl cursor-pointer"
--                 , onClick (SetModal NoModal)
--                 ]
--                 [ Icon.viewIcon Icon.times
--                 ]
--             ]
--         ,
--         ]
--     ]


filterView : Html Msg
filterView =
    div [ class "mb-4" ]
        [ input
            [ class "px-4 py-2 text-xl rounded-md w-full text-black shadow-inner border border-gray-300 "
            , placeholder "Buscar..."
            , onInput SearchTyping
            ]
            []
        , div [ class "mt-4 text-black" ]
            [ select [ class "p-2 rounded-md border border-gray-300", onInput PickSpecie ]
                (option [ value "all" ] [ text "Todas las especies" ]
                    :: (Specie.all
                            |> List.map Specie.htmlOption
                       )
                )
            , select [ class "p-2 rounded-md ml-4 border border-gray-300", onInput PickSex ]
                (option [ value "all" ] [ text "Macho/Hembra" ]
                    :: (Sex.all
                            |> List.map Sex.htmlOption
                       )
                )
            ]
        ]


reportsListView : List Report.ContextualizedReport -> Html Msg
reportsListView reports =
    div [ class "grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4" ]
        (List.map reportsCardView reports)


reportsCardView : Report.ContextualizedReport -> Html Msg
reportsCardView cReport =
    let
        animal =
            cReport.report.animal

        report =
            cReport.report
    in
    a
        [ class "bg-white text-gray-800 shadow-md overflow-hidden rounded-md cursor-pointer border border-gray-300"
        , onClick (SetModal (ViewReport report.id))
        ]
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
