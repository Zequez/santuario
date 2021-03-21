module FamilyRecovery.ReportEditModal exposing (..)

import FamilyRecovery.Animal as Animal
import FamilyRecovery.Card as Card
import FamilyRecovery.Human as Human
import FamilyRecovery.Modal as Modal
import FamilyRecovery.Player as Player
import FamilyRecovery.Report as Report
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (class)


type alias Model =
    { report : Report.Report
    , human : Human.Human
    , animal : Animal.Animal
    }


type Msg
    = SetReport Report.WriteMsg


update : Msg -> Model -> Model
update msg model =
    case msg of
        SetReport subMsg ->
            { model | report = Report.writer subMsg model.report }


new : Model
new =
    { report = Report.empty
    , human = Human.empty
    , animal = Animal.empty
    }



-- updateReport : (Report.Report -> Report.Report) -> Report.Report -> Report.Report
-- updateReport updater report =
--     updater report


view : Maybe Player.Player -> Model -> msg -> (Msg -> msg) -> Html msg
view maybePlayer { report, human, animal } closeMsg msgWrapper =
    Modal.view "Nuevo Reporte"
        closeMsg
        (div [ class "text-black p-4" ]
            [ case maybePlayer of
                Just player ->
                    div [ class "mb-4" ] [ Card.view "Jugador" (text player.alias) ]

                Nothing ->
                    div [] []
            , div [ class "mb-4 text-xl" ] [ text "Contacto primario humano" ]
            , div [ class "mb-4" ] [ Human.cardView report.humanContact ]
            , div [ class "mb-4 text-xl" ] [ text "Información del animal perdide" ]
            , div [ class "mb-4" ] [ Animal.cardView report.animal ]
            , div [ class "mb-4 text-xl" ] [ text "Información del evento" ]
            , div [ class "mb-4" ]
                [ Report.shallowCardView report (msgWrapper << SetReport << Report.SetLocation)
                ]
            , div [ class "flex justify-end" ]
                [ button [ class "bg-yellow-300 py-2 px-4 rounded-md text-white font-bold tracking-wider uppercase" ]
                    [ text "Publicar reporte"
                    ]
                ]
            ]
        )
