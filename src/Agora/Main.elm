module Agora.Main exposing (..)

import Agent.SignIn as Agent
import Browser
import Dict exposing (Dict)
import EnvConstants
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, a, button, code, div, input, span, text)
import Html.Attributes exposing (class, classList, disabled, href, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as JD
import Kinto
import Ui.Ui as Ui
import Utils.Utils exposing (classFocusRing, classInput, dictFromRecordLike, iif)



-- ████████╗██╗   ██╗██████╗ ███████╗███████╗
-- ╚══██╔══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔════╝
--    ██║    ╚████╔╝ ██████╔╝█████╗  ███████╗
--    ██║     ╚██╔╝  ██╔═══╝ ██╔══╝  ╚════██║
--    ██║      ██║   ██║     ███████╗███████║
--    ╚═╝      ╚═╝   ╚═╝     ╚══════╝╚══════╝


type alias Model =
    { user : String
    , auth : Maybe Kinto.Auth
    , accountPopupVisible : Bool
    , markets : Dict String Market
    , shops : Dict String Shop
    , selectedMarket : Maybe String
    , selectedShop : Maybe String
    }



-- type alias PlayerInfo =
--     { name : String
--     , email : String
--     , picture : String
--     }


empty =
    Model "" Nothing


init : ( Model, Cmd Msg )
init =
    ( Model ""
        Nothing
        False
        (dictFromRecordLike [ market1, market2, market3, market4 ])
        (dictFromRecordLike [ shop1, shop2, shop3, shop4, shop5, shop6, shop7, shop8 ])
        (Just "vegan")
        Nothing
    , Cmd.none
    )


type alias Market =
    { id : String
    , name : String
    , description : String
    , icon : String
    , admin : String
    , team : List String
    , shops : List String
    }


type alias Shop =
    { id : String
    , name : String
    , icon : String
    , contact : String
    , admin : String
    , team : List String
    , products : List Product
    , locations : List PhysicalLocation
    }


type alias Product =
    { name : String
    , images : List String
    , description : String
    , pricingModel : PricingModel
    }



-- type PhysicalLocation = NoPhysicalLocation | SingleLocation (Float, Float) | SalesPoint (Float, Float)


type alias PhysicalLocation =
    { lat : Float
    , lng : Float
    , address : String
    , name : String
    , details : String
    , availability : String
    }


type PricingModel
    = FixedPrice Int
    | SuggestedPrice Int
    | Gift
    | Consult
    | Custom String



-- ███╗   ███╗███████╗ ██████╗
-- ████╗ ████║██╔════╝██╔════╝
-- ██╔████╔██║███████╗██║  ███╗
-- ██║╚██╔╝██║╚════██║██║   ██║
-- ██║ ╚═╝ ██║███████║╚██████╔╝
-- ╚═╝     ╚═╝╚══════╝ ╚═════╝


type Msg
    = RequestMarkets
    | RequestMarketsFetched (Result Kinto.Error (Kinto.Pager Market))
    | RequestShops
    | RequestShopsFetched (Result Kinto.Error (Kinto.Pager Shop))
    | SelectMarket String
    | SelectShop String
    | Authenticated ( String, String )
    | ToggleAccountPopup
    | LoggedOut



-- ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗
-- ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝
-- ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗
-- ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝
-- ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗
--  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectMarket id ->
            ( { model
                | selectedMarket = Just id
                , selectedShop = Nothing
              }
            , Cmd.none
            )

        SelectShop id ->
            ( { model | selectedShop = Just id }, Cmd.none )

        Authenticated ( user, pass ) ->
            ( { model | user = user, auth = Just (Kinto.Basic user pass) }, Cmd.none )

        LoggedOut ->
            ( { model | user = "", auth = Nothing }, Cmd.none )

        ToggleAccountPopup ->
            ( { model | accountPopupVisible = not model.accountPopupVisible }, Cmd.none )

        _ ->
            model
                |> andDoNothing


andDoNothing : model -> ( model, Cmd msg )
andDoNothing model =
    ( model, Cmd.none )



-- -- ██╗   ██╗██╗███████╗██╗    ██╗███████╗
-- -- ██║   ██║██║██╔════╝██║    ██║██╔════╝
-- -- ██║   ██║██║█████╗  ██║ █╗ ██║███████╗
-- -- ╚██╗ ██╔╝██║██╔══╝  ██║███╗██║╚════██║
-- --  ╚████╔╝ ██║███████╗╚███╔███╔╝███████║
-- --   ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚══════╝


view : Model -> Html Msg
view model =
    let
        markets : List Market
        markets =
            model.markets
                |> Dict.values

        maybeMarketShops : Maybe (List Shop)
        maybeMarketShops =
            model.selectedMarket
                |> Maybe.andThen
                    (\id ->
                        model.markets
                            |> Dict.get id
                            |> Maybe.map .shops
                    )
                |> Maybe.map
                    (\shopsIds ->
                        shopsIds
                            |> List.filterMap (\id -> Dict.get id model.shops)
                    )
    in
    div [ class "bg-gray-200 min-h-full flex" ]
        [ Ui.mainSidebarView "Agora"
            []
            [ marketListView markets (Maybe.withDefault "" model.selectedMarket)
            , userAccountButtonView model.user model.accountPopupVisible
            ]
        , div [ class "flex-grow py-8 px-12" ]
            [ if model.user /= "" then
                div [] [ text ("Woo! Welcome " ++ model.user) ]

              else
                div [] []
            ]
        , case maybeMarketShops of
            Just marketShops ->
                div [ class "w-60 flex-shrink-0 bg-gray-100 shadow-md" ]
                    [ shopsListView marketShops (Maybe.withDefault "" model.selectedShop)
                    ]

            Nothing ->
                div [] []
        ]


userAccountButtonView : String -> Bool -> Html Msg
userAccountButtonView userName popupVisible =
    div [ class "relative" ]
        [ div [ class """
        flex flex-col items-center justify-center
        py-2
        bg-yellow-500 text-white bg-opacity-75 hover:bg-opacity-100
        cursor-pointer""", onClick ToggleAccountPopup ]
            [ div [ class "h-6 w-6 mb-1" ] [ Icon.viewIcon Icon.user ]
            , div [ class "font-semibold" ]
                [ text
                    (if userName == "" then
                        "..."

                     else
                        userName
                    )
                ]
            ]
        , div []
            [ div [ class "fixed inset-0 z-20", classList [ ( "hidden", not popupVisible ) ], onClick ToggleAccountPopup ] []
            , div
                [ class """
                        absolute bottom-0 left-0 w-80 ml-4 mb-4 z-30
                         shadow-lg rounded-lg animate-fade-slide-in bg-white """
                , classList [ ( "hidden", not popupVisible ) ]
                ]
                [ div [ class "flex flex-col" ]
                    [ div [ class "h-20 rounded-t-lg bg-yellow-200" ]
                        [ div [ class "flex flex-col mx-auto w-20 text-center" ]
                            [ div [ class "bg-white rounded-full h-20 w-20 p-1 shadow-sm mt-6" ]
                                [ div [ class "w-full h-full bg-gray-100 rounded-full text-gray-500 flex items-center justify-center" ]
                                    [ div [ class "h-10 w-10 -mt-2" ] [ Icon.viewIcon Icon.user ]
                                    ]
                                ]
                            , div [ class "text-xl font-semibold" ] [ text userName ]
                            ]
                        ]
                    , div [ class "p-4 pt-12 ", classList [ ( "pt-16", userName /= "" ) ] ]
                        [ Agent.element EnvConstants.kintoHost Authenticated LoggedOut
                        ]
                    ]
                ]
            ]
        ]


shopsListView : List Shop -> String -> Html Msg
shopsListView shops selectedShop =
    div [ class "flex flex-col p-2" ]
        (shops
            |> List.map (\s -> shopListButtonView s (s.id == selectedShop))
        )


shopListButtonView : Shop -> Bool -> Html Msg
shopListButtonView shop isSelected =
    div
        [ class """
            px-2 py-1 mb-2
            bg-white bg-opacity-50
            hover:bg-opacity-100
            cursor-pointer rounded-md shadow-sm
            transform transition-transform
            """
        , classList
            [ ( "text-gray-600", not isSelected )
            , ( "bg-green-500 text-white bg-opacity-100 font-semibold shadow-md -translate-x-4", isSelected )
            ]
        , onClick (SelectShop shop.id)
        ]
        [ span [ class "mr-2" ] [ text shop.icon ]
        , span [ class "" ] [ text shop.name ]
        ]


marketListView : List Market -> String -> Html Msg
marketListView markets selectedMarket =
    div [ class "flex flex-col flex-grow" ]
        (markets
            |> List.map (\m -> marketListButtonView m (m.id == selectedMarket))
        )


marketListButtonView : Market -> Bool -> Html Msg
marketListButtonView market isSelected =
    div
        [ class "flex flex-col items-center justify-center h-24 cursor-pointer font-bold hover:bg-gray-200"
        , classList [ ( "bg-gray-200", isSelected ) ]
        , onClick (SelectMarket market.id)
        ]
        [ div [ class "text-4xl" ]
            [ text market.icon
            ]
        , div [ class "text-gray-600" ] [ text market.name ]
        ]



--  ██████╗ ████████╗██╗  ██╗███████╗██████╗
-- ██╔═══██╗╚══██╔══╝██║  ██║██╔════╝██╔══██╗
-- ██║   ██║   ██║   ███████║█████╗  ██████╔╝
-- ██║   ██║   ██║   ██╔══██║██╔══╝  ██╔══██╗
-- ╚██████╔╝   ██║   ██║  ██║███████╗██║  ██║
--  ╚═════╝    ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


main : Program {} Model Msg
main =
    Browser.element
        { init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }



-- ████████╗███████╗███████╗████████╗    ██████╗  █████╗ ████████╗ █████╗
-- ╚══██╔══╝██╔════╝██╔════╝╚══██╔══╝    ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗
--    ██║   █████╗  ███████╗   ██║       ██║  ██║███████║   ██║   ███████║
--    ██║   ██╔══╝  ╚════██║   ██║       ██║  ██║██╔══██║   ██║   ██╔══██║
--    ██║   ███████╗███████║   ██║       ██████╔╝██║  ██║   ██║   ██║  ██║
--    ╚═╝   ╚══════╝╚══════╝   ╚═╝       ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝


market1 : Market
market1 =
    { id = "vegan"
    , name = "Vegan"
    , description = "Mercado local de emprendimientos veganos"
    , icon = "🐮"
    , admin = "Zequez"
    , team = []
    , shops = [ "shop1", "shop2", "shop3", "shop4", "shop5" ]
    }


market2 : Market
market2 =
    { id = "agroeco"
    , name = "Agroeco"
    , description = "Mercado local agroecológico"
    , icon = "🌱"
    , admin = "Zequez"
    , team = []
    , shops = [ "shop6", "shop7", "shop8" ]
    }


market3 : Market
market3 =
    { id = "artesano"
    , name = "Artesano"
    , description = "Mercado artesano local"
    , icon = "🧶"
    , admin = "Zequez"
    , team = []
    , shops = []
    }


market4 : Market
market4 =
    { id = "clothing"
    , name = "Ropa"
    , description = "Mercado local de ropa artesanal"
    , icon = "🥋"
    , admin = "Zequez"
    , team = []
    , shops = []
    }


shop1 : Shop
shop1 =
    { id = "shop1"
    , name = "Dog Food Emporium"
    , icon = "🐶"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }


shop2 : Shop
shop2 =
    { id = "shop2"
    , name = "Tofu Magnificent"
    , icon = "🍜"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }


shop3 : Shop
shop3 =
    { id = "shop3"
    , name = "Hoodies & Hoods"
    , icon = "🤙"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }


shop4 : Shop
shop4 =
    { id = "shop4"
    , name = "Pizza Veg"
    , icon = "🍕"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }


shop5 : Shop
shop5 =
    { id = "shop5"
    , name = "Chocolateree"
    , icon = "🍫"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }


shop6 : Shop
shop6 =
    { id = "shop6"
    , name = "Che Verde"
    , icon = "🥦"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }


shop7 : Shop
shop7 =
    { id = "shop7"
    , name = "UTT"
    , icon = "✊"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }


shop8 : Shop
shop8 =
    { id = "shop8"
    , name = "Los Serenos"
    , icon = "👩\u{200D}🌾"
    , contact = "+5492235235568"
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    }
