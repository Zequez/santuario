module Utils.Utils exposing (..)

import Dict exposing (Dict)
import Html exposing (Html, a, br, button, code, div, h2, hr, img, input, option, p, select, span, text)
import Html.Attributes exposing (class, classList, disabled, href, placeholder, src, style, target, title, type_, value)
import Html.Events exposing (keyCode, on, onClick, onInput)
import Json.Decode as JD
import Json.Encode as JE
import Regex


onEnter : msg -> Html.Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                JD.succeed msg

            else
                JD.fail "not ENTER"
    in
    on "keydown" (JD.andThen isEnter keyCode)


iif : Bool -> val -> val -> val
iif condition ifTrue ifFalse =
    if condition then
        ifTrue

    else
        ifFalse


classInput : Html.Attribute msg
classInput =
    class "block w-full mb-4 h-12 px-4 py-2 text-lg rounded-md ring-1 ring-gray-200"


classFocusRing : Html.Attribute msg
classFocusRing =
    class "focus:outline-none focus:ring focus:ring-green-500 focus:ring-opacity-50"


type alias RecordLike a =
    { a | id : String }


dictFromRecordLike : List (RecordLike a) -> Dict String (RecordLike a)
dictFromRecordLike records =
    records
        |> List.map (\r -> ( r.id, r ))
        |> Dict.fromList


type IPFSAddress
    = IPFSAddress String


ipfsAddress : String -> IPFSAddress
ipfsAddress hash =
    IPFSAddress hash


ipfsUrl : IPFSAddress -> String
ipfsUrl (IPFSAddress hash) =
    "https://gateway.pinata.cloud/ipfs/" ++ hash


cleanPhoneNumber : String -> String
cleanPhoneNumber phone =
    let
        regex =
            Maybe.withDefault Regex.never (Regex.fromString "[^0-9]")
    in
    phone
        |> Regex.replace regex (\_ -> "")
