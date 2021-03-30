module Utils.ContactChannel exposing (..)

import FontAwesome.Brands as Icon
import FontAwesome.Icon as Icon
import FontAwesome.Solid as Icon
import Html exposing (Html, div, text)
import Html.Attributes exposing (class)
import Utils.Utils exposing (cleanPhoneNumber)


type ContactChannel
    = Facebook String
    | Instagram String
    | Whatsapp String
    | Telegram String
    | Phone String
    | Email String


toColor : ContactChannel -> String
toColor contactChannel =
    case contactChannel of
        Facebook _ ->
            "#4267B2"

        Instagram _ ->
            "#E1306C"

        Whatsapp _ ->
            "#25D366"

        Telegram _ ->
            "#0088CC"

        Phone _ ->
            "#444444"

        Email _ ->
            "#c43632"


toLabelView : ContactChannel -> Html msg
toLabelView contactChannel =
    div [ class "flex items-center" ]
        [ div [ class "h-4 w-4 mr-1" ] [ Icon.viewIcon (toIcon contactChannel) ]
        , div [ class "flex-grow" ] [ text (unwrap contactChannel) ]
        ]


toLabel : ContactChannel -> String
toLabel contactChannel =
    case contactChannel of
        Facebook _ ->
            "Facebook"

        Instagram _ ->
            "Instagram"

        Whatsapp _ ->
            "Whatsapp"

        Telegram _ ->
            "Telegram"

        Phone _ ->
            "Phone"

        Email _ ->
            "Email"


toUrl : ContactChannel -> String
toUrl contactChannel =
    case contactChannel of
        Facebook account ->
            "https://www.facebook.com/" ++ account

        Instagram account ->
            "https://instagram.com/" ++ account

        Whatsapp phone ->
            "https://wa.me/" ++ cleanPhoneNumber phone

        Telegram account ->
            "https://t.me/" ++ account

        Phone phone ->
            "tel:" ++ cleanPhoneNumber phone

        Email email ->
            "mailto:" ++ email


unwrap : ContactChannel -> String
unwrap contactChannel =
    case contactChannel of
        Facebook account ->
            account

        Instagram account ->
            account

        Whatsapp phone ->
            phone

        Telegram account ->
            account

        Phone phone ->
            phone

        Email email ->
            email


toIcon : ContactChannel -> Icon.Icon
toIcon contactChannel =
    case contactChannel of
        Facebook _ ->
            Icon.facebookSquare

        Instagram _ ->
            Icon.instagram

        Whatsapp _ ->
            Icon.whatsapp

        Telegram _ ->
            Icon.telegram

        Phone _ ->
            Icon.phoneSquare

        Email _ ->
            Icon.envelope
