module ContentUtil exposing (MessageType(..), viewMessage, viewModal, viewToggle)

import Html exposing (Html, text, div, label, input, span)
import Html.Attributes exposing (class, id, type_, checked)

type MessageType
    = Info
    | Warning
    | Error

viewMessage : MessageType -> String -> Html null
viewMessage type_ text_ = 
    let
        className : String
        className = 
            case type_ of
                Info -> "notif info"
                Warning -> "notif warning"
                Error -> "notif error"
    in
        div
        [
            class className
        ]
        [
            text text_
        ]

viewModal : List (Html msg) -> Html msg
viewModal content =
    div [id "modal-popup"] [div [id "modal-popup-container"] content]

viewToggle : List (Html.Attribute msg) -> Bool -> Html msg
viewToggle attributes isChecked = 
    label ( List.append [ class "switch" ] attributes )
        [   input [ type_ "checkbox", checked isChecked ] []
        ,   span [ class "slider" ] []
        ]