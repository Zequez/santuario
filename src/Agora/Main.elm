module Agora.Main exposing (..)

import Agent.SignIn as Agent
import Browser
import Communities.Communities as Communities exposing (Community, communities)
import Dict exposing (Dict)
import EnvConstants
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Attribute, Html, a, button, code, div, img, input, span, text)
import Html.Attributes exposing (class, classList, disabled, href, placeholder, src, style, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Json.Decode as JD
import Kinto
import List.Extra
import Ui.Ui as Ui
import Utils.ContactChannel as ContactChannel
import Utils.Utils as Utils exposing (IPFSAddress, classFocusRing, classInput, dictFromRecordLike, iif, ipfsUrl)



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
    , community : Maybe Community
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
        (dictFromRecordLike [ shop1, shop2, shop3, shop4, shop5, shop6, shop7, shop8, shop9 ])
        (Just "vegan")
        Nothing
        (List.head communities)
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
    , logo : IPFSAddress
    , contact : List ContactChannel.ContactChannel
    , admin : String
    , team : List String
    , products : List Product
    , locations : List PhysicalLocation
    , marketDisplay : ProductsListDisplay
    }



-- type alias TeamMember =
--     { name : String
--     , avatar : String
--     }


type alias Product =
    { name : String
    , images : List IPFSAddress
    , description : String
    , pricingModel : PricingModel
    }


type PricingModel
    = FixedPrice Int
    | SuggestedPrice Int
    | Gift
    | Consult
    | Custom String



-- type PhysicalLocation = NoPhysicalLocation | SingleLocation (Float, Float) | SalesPoint (Float, Float)


type alias PhysicalLocation =
    { lat : Float
    , lng : Float
    , address : String
    , name : String
    , details : String
    , availability : String
    }



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
    div [ class "flex flex-col h-full" ]
        [ topBarView model
        , div [ class "bg-gray-200 flex-grow flex" ]
            (mainSidebarView model markets
                :: (case maybeMarketShops of
                        Just marketShops ->
                            [ div [ class "px-4 py-8 sm:p-12 flex-grow" ] [ marketShopsView marketShops ]
                            , shopsListSidebarView marketShops model.selectedShop
                            ]

                        Nothing ->
                            [ div [] [] ]
                   )
            )
        ]


marketShopsView : List Shop -> Html Msg
marketShopsView shops =
    div [ class "grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-8" ]
        (shops
            |> List.map marketShopCardView
        )


marketShopCardView : Shop -> Html Msg
marketShopCardView shop =
    div [ class "bg-white shadow-md rounded-lg flex flex-col" ]
        [ div [ class "flex h-16" ]
            [ div [ class "h-20 w-20  ml-2 -mt-6 rounded-full overflow-hidden p-1 bg-white border border-gray-200" ]
                [ img [ src (ipfsUrl shop.logo), class "rounded-full" ] []
                ]
            , div [ class "p-2 font-thin text-base" ]
                [ div []
                    [ text (shop.icon ++ " " ++ shop.name)
                    , div [ class "-ml-2 text-sm flex" ]
                        (if List.length shop.locations > 1 then
                            [ div [ class "h-3 w-3 mr-1 text-gray-700" ] [ Icon.viewIcon Icon.mapMarkerAlt ]
                            , text (String.fromInt (List.length shop.locations) ++ " nodos de distribución")
                            ]

                         else
                            case List.head shop.locations of
                                Just location ->
                                    [ div [ class "h-3 w-3 mr-1 text-gray-700" ] [ Icon.viewIcon Icon.mapMarkerAlt ]
                                    , text location.address
                                    ]

                                Nothing ->
                                    [ div [] [] ]
                        )
                    ]
                ]
            ]
        , marketShopProductsView shop.marketDisplay shop.products
        , div [ class "h-12 rounded-b-lg flex justify-end overflow-hidden text-white font-semibold" ]
            (shop.contact
                |> List.map contactChannelButtonView
            )
        ]


marketShopProductsView : ProductsListDisplay -> List Product -> Html Msg
marketShopProductsView display products =
    goldenRatioElementView [ class "bg-gray-100 shadow-top overflow-auto" ]
        (if List.isEmpty products then
            [ div [ class "h-full w-full flex items-center justify-center text-gray-400" ]
                [ text "Sin lista de productos"
                ]
            ]

         else
            [ case display of
                SmallSquare ->
                    div [] []

                BigSquare ->
                    div [ class "p-2 grid grid-cols-2 gap-2 flex-grow" ]
                        (products
                            |> List.map
                                (\p ->
                                    div [ class "flex flex-col" ]
                                        [ squareImageWithDefault p.images
                                        , div [ class "text-base font-thin" ] [ text p.name ]
                                        ]
                                )
                        )

                BigList ->
                    div [] []

                CompactList ->
                    div [ class "p-2 grid grid-cols-1 gap-2" ]
                        (products
                            |> List.map
                                (\p ->
                                    a [ href "/product", class "flex items-center" ]
                                        [ div [ class "h-8 w-8 mr-2" ] [ squareImageWithDefault p.images ]
                                        , div [ class "flex-grow text-sm" ] [ text (p.name ++ "aaaa") ]
                                        , div [ class "text-gray-400" ] [ text (pricingModelToString p.pricingModel) ]
                                        ]
                                )
                        )
            ]
        )


type ProductsListDisplay
    = SmallSquare
    | BigSquare
    | BigList
    | CompactList


squareImageWithDefault : List IPFSAddress -> Html Msg
squareImageWithDefault imagesList =
    squareElementView [ class "overflow-hidden rounded-md bg-gray-200" ]
        [ case List.head imagesList of
            Just firstImage ->
                img [ class "object-cover ", src (ipfsUrl firstImage) ] []

            Nothing ->
                div [ class "h-full w-full text-gray-300 p-2" ]
                    [ Icon.viewIcon Icon.image
                    ]
        ]



-- productsListItemView : ProductsListItem -> Html Msg
-- productsListItemView productsListItem =
--     case productsListItem of
--         ProductWithImage product ipfsHash ->
--             a [ href "/product", class "relative" ]
--                 [ squareElementView [ class "overflow-hidden rounded-md" ]
--                     [ img [ class "object-cover ", src (ipfsUrl ipfsHash) ] []
--                     ]
--                 , div [ class "flex justify-end mt-1" ]
--                     [ div [ class "bg-white text-sm text-gray-700 flex-grow whitespace-nowrap overflow-hidden overflow-ellipsis" ]
--                         [ text product.name
--                         ]
--                     , div [ class "text-xs flex ring-1 ring-gray-200 items-center px-1 bg-white rounded-sm text-gray-400" ] [ text (pricingModelToString product.pricingModel) ]
--                     ]
--                 ]
--         ProductWithoutImage product ->
--             a [ href "/product" ]
--                 [ squareElementView []
--                     [ div [ class "h-full bg-gray-200 p-4 text-gray-600 rounded-md" ]
--                         [ Icon.viewIcon Icon.image
--                         ]
--                     ]
--                 , div [] [ text product.name ]
--                 ]
--         EmptyItem ->
--             div []
--                 [ squareElementView []
--                     [ div [ class "h-full border-4 border-gray-300 border-dashed p-4 text-gray-600 rounded-md opacity-25" ]
--                         []
--                     ]
--                 ]
--         MoreItems more ->
--             a [ href "/shop" ]
--                 [ squareElementView []
--                     [ div [ class "h-full bg-gray-200 p-4 text-gray-600 flex items-center justify-center font-bold text-3xl rounded-md" ]
--                         [ text ("+" ++ String.fromInt more)
--                         ]
--                     ]
--                 ]


squareElementView : List (Attribute Msg) -> List (Html Msg) -> Html Msg
squareElementView attributes children =
    div ([ style "padding-top" "100%", class "relative w-full" ] ++ attributes)
        [ div [ class "absolute inset-0" ] children
        ]


goldenRatioElementView : List (Attribute Msg) -> List (Html Msg) -> Html Msg
goldenRatioElementView attributes children =
    div ([ style "padding-top" "62%", class "relative w-full" ] ++ attributes)
        [ div [ class "absolute inset-0" ] children
        ]


type ProductsListItem
    = ProductWithImage Product IPFSAddress
    | ProductWithoutImage Product
    | EmptyItem
    | MoreItems Int



-- productsToProductsListItem : List Product -> Int -> List ProductsListItem
-- productsToProductsListItem products listLength =
--     let
--         -- productsIndex =
--         --     Dict.fromList (List.indexedMap Tuple.pair products)
--         ( firstProducts, lastProducts ) =
--             products
--                 |> List.map
--                     (\p ->
--                         case List.head p.images of
--                             Just hash ->
--                                 ProductWithImage p hash
--                             Nothing ->
--                                 ProductWithoutImage p
--                     )
--                 |> List.indexedMap Tuple.pair
--                 |> List.partition
--                     (\( i, p ) ->
--                         i < listLength
--                     )
--                 |> Tuple.mapBoth unIndex unIndex
--     in
--     case List.length lastProducts of
--         0 ->
--             if List.length firstProducts < listLength then
--                 firstProducts ++ List.repeat (listLength - List.length firstProducts) EmptyItem
--             else
--                 firstProducts
--         num ->
--             MoreItems (num + 1)
--                 :: (firstProducts
--                         |> List.reverse
--                         |> List.tail
--                         |> Maybe.withDefault []
--                     -- NEVER
--                    )
--                 |> List.reverse
-- unIndex : List ( a, b ) -> List b
-- unIndex list =
--     List.map (\( i, p ) -> p) list


contactChannelButtonView : ContactChannel.ContactChannel -> Html Msg
contactChannelButtonView contactChannel =
    a
        [ class "flex items-center justify-center px-4 text-sm saturate-hover text-white text-opacity-75 hover:text-opacity-100"
        , style "background-color" (ContactChannel.toColor contactChannel)
        , href (ContactChannel.toUrl contactChannel)
        , target "_blank"
        ]
        [ div [ class "w-6" ] [ Icon.viewIcon (ContactChannel.toIcon contactChannel) ] ]


pricingModelToString : PricingModel -> String
pricingModelToString pricingModel =
    case pricingModel of
        Custom price ->
            price

        _ ->
            "N/A"


topBarView : Model -> Html Msg
topBarView model =
    div [ class "bg-green-500 bg-opacity-75 h-12 flex" ]
        [ div [ class "flex-grow flex justify-start text-white" ]
            [ a [ class "flex items-center flex-stretch text-2xl px-4 hover:bg-white hover:bg-opacity-25 ", href "/" ]
                [ text "❮"
                ]
            , div [ class "text-xl px-2 flex items-center" ] [ text "Agora" ]
            ]
        , userAccountButtonView model.user model.accountPopupVisible
        ]


mainSidebarView : Model -> List Market -> Html Msg
mainSidebarView model markets =
    div
        [ class "flex flex-shrink-0 flex-col bg-gray-100 shadow-md w-16 sm:w-32" ]
        [ marketListView markets (Maybe.withDefault "" model.selectedMarket)
        , case model.community of
            Just community ->
                div
                    [ class "text-gray-100 hover:bg-gray-200 font-semibold flex flex-col items-center justify-center pt-2 sm:py-2 cursor-pointer"

                    -- , style "background-image" ("url(" ++ ipfsUrl community.banner ++ ")")
                    ]
                    [ div [ class "h-16 w-16 sm:h-24 sm:w-24 p-1 bg-gray-200 border border-gray-300 rounded-full shadow-sm" ]
                        [ img [ class "rounded-full", src (ipfsUrl community.logo) ] []
                        ]
                    , div [ class "text-xs sm:text-base text-center  bg-black bg-opacity-50 px-2 sm:rounded-md -mt-6" ] [ text community.name ]
                    ]

            Nothing ->
                div [] []
        ]


userAccountButtonView : String -> Bool -> Html Msg
userAccountButtonView userName popupVisible =
    div [ class "flex-shrink-0 bg-white" ]
        [ div [ class """
            h-full flex flex-col w-32 items-center justify-center
            bg-yellow-500 text-white hover:bg-yellow-400
            cursor-pointer""", onClick ToggleAccountPopup ]
            [ div [ class "h-4 w-4 mb-1" ] [ Icon.viewIcon Icon.userCircle ]
            , div [ class "text-sm font-semibold" ]
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
                        absolute top-0 right-0 w-80 mr-4 mt-4 z-30
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


shopsListSidebarView : List Shop -> Maybe String -> Html Msg
shopsListSidebarView shops selectedShop =
    div [ class "flex-shrink-0 w-60 bg-gray-100 shadow-md hidden md:block" ]
        [ shopsListView shops (Maybe.withDefault "" selectedShop)
        ]


shopsListView : List Shop -> String -> Html Msg
shopsListView shops selectedShop =
    div [ class "flex flex-col p-2 h-full" ]
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
        [ class "flex flex-col items-center justify-center h-16 sm:h-24 cursor-pointer font-bold hover:bg-gray-200"
        , classList [ ( "bg-gray-200", isSelected ) ]
        , onClick (SelectMarket market.id)
        ]
        [ div [ class "text-2xl sm:text-4xl" ]
            [ text market.icon
            ]
        , div [ class "text-gray-600 text-xs sm:text-base" ] [ text market.name ]
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
    , shops = [ "shop6", "shop7", "shop8", "shop9" ]
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
    , logo = Utils.IPFSAddress "QmfG9n6cECZTknMm1HMPrnAaNEBHyQ1mqR6hPuY73moJQV"
    , contact = [ ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    , marketDisplay = CompactList
    }


shop2 : Shop
shop2 =
    { id = "shop2"
    , name = "Tofu Magnificent"
    , icon = "🍜"
    , logo = Utils.IPFSAddress "QmfG9n6cECZTknMm1HMPrnAaNEBHyQ1mqR6hPuY73moJQV"
    , contact = [ ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    , marketDisplay = CompactList
    }


shop3 : Shop
shop3 =
    { id = "shop3"
    , name = "Hoodies & Hoods"
    , icon = "🤙"
    , logo = Utils.IPFSAddress "QmfG9n6cECZTknMm1HMPrnAaNEBHyQ1mqR6hPuY73moJQV"
    , contact = [ ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    , marketDisplay = CompactList
    }


shop4 : Shop
shop4 =
    { id = "shop4"
    , name = "Pizza Veg"
    , icon = "🍕"
    , logo = Utils.IPFSAddress "QmfG9n6cECZTknMm1HMPrnAaNEBHyQ1mqR6hPuY73moJQV"
    , contact = [ ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    , marketDisplay = CompactList
    }


shop5 : Shop
shop5 =
    { id = "shop5"
    , name = "Chocolateree"
    , icon = "🍫"
    , logo = Utils.IPFSAddress "QmfG9n6cECZTknMm1HMPrnAaNEBHyQ1mqR6hPuY73moJQV"
    , contact = [ ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = []
    , marketDisplay = CompactList
    }


shop6 : Shop
shop6 =
    { id = "shop6"
    , name = "Che Verde"
    , icon = "🥦"
    , logo = Utils.IPFSAddress "QmdjaRpTQwHsipEa7tkatNhyWJBJaPgXVyE3qvZSmSZBEa"
    , contact = [ ContactChannel.Instagram "CheVerde", ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products =
        [ { name = "Bolsón"
          , images = [ Utils.IPFSAddress "QmbM3ZqP5icAccMKdnqXcPnNoTmkymrqhMqy8gabn5JX9t" ]
          , description = ""
          , pricingModel = Custom "$500"
          }
        , { name = "Paltas agroecológicas"
          , images = [ Utils.IPFSAddress "QmbM3ZqP5icAccMKdnqXcPnNoTmkymrqhMqy8gabn5JX9t" ]
          , description = ""
          , pricingModel = Custom "$80"
          }
        , { name = "Ajo"
          , images = []
          , description = ""
          , pricingModel = Custom "$60"
          }
        , { name = "Algo"
          , images = [ Utils.IPFSAddress "QmbM3ZqP5icAccMKdnqXcPnNoTmkymrqhMqy8gabn5JX9t" ]
          , description = ""
          , pricingModel = Custom "$100"
          }
        ]
    , locations =
        [ fakeLocation
        ]
    , marketDisplay = CompactList
    }


fakeLocation =
    { lat = -38.0551358
    , lng = -57.5479618
    , address = "Tucumán 3340"
    , name = "Casa central"
    , details = "Portón azúl"
    , availability = "8am - 3pm"
    }


shop7 : Shop
shop7 =
    { id = "shop7"
    , name = "UTT"
    , icon = "✊"
    , logo = Utils.IPFSAddress "QmfG9n6cECZTknMm1HMPrnAaNEBHyQ1mqR6hPuY73moJQV"
    , contact = [ ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products = []
    , locations = [ fakeLocation, fakeLocation, fakeLocation, fakeLocation, fakeLocation ]
    , marketDisplay = CompactList
    }


shop8 : Shop
shop8 =
    { id = "shop8"
    , name = "Los Serenos"
    , icon = "👩\u{200D}🌾"
    , logo = Utils.IPFSAddress "QmfG9n6cECZTknMm1HMPrnAaNEBHyQ1mqR6hPuY73moJQV"
    , contact = [ ContactChannel.Whatsapp "+5492235235568" ]
    , admin = "Zequez"
    , team = []
    , products = List.repeat 10 repeatedProduct
    , locations = []
    , marketDisplay = CompactList
    }


shop9 : Shop
shop9 =
    { id = "shop9"
    , name = "Red Agroecológica"
    , icon = "🌎"
    , logo = Utils.IPFSAddress "QmQsiFfPhbnzq16D7VQerxi5pvURdmmCV6nkUR511emttp"
    , contact =
        [ ContactChannel.Whatsapp "+5492235235568"
        , ContactChannel.Instagram "redagroecologicamdp"
        , ContactChannel.Facebook "alacenasoberana"
        ]
    , admin = "Zequez"
    , team = []
    , products = List.repeat 10 repeatedProduct
    , locations = []
    , marketDisplay = CompactList
    }


repeatedProduct : Product
repeatedProduct =
    { name = "Algo"
    , images = [ Utils.IPFSAddress "QmbM3ZqP5icAccMKdnqXcPnNoTmkymrqhMqy8gabn5JX9t" ]
    , description = ""
    , pricingModel = Custom "$100"
    }
