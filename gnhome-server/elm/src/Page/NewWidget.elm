module Page.NewWidget exposing (..)

import Html exposing (Html, text, div, button, hr, form, label, input, textarea)
import Html.Attributes exposing (style, class, id, type_, placeholder, action, enctype, method, name, required)
import Html.Events exposing (onCheck)

import ContentUtil

type Model
    = Default

type Event
    = None



init : (Model, Cmd Event)
init = (Default, Cmd.none)

update : Event -> Model -> (Model, Cmd Event)
update event model = init

view : Model -> (Html Event)
view model = ContentUtil.viewModal
    [div [ class "modal-header" ] [ text "Upload a Widget" ]
    ,   Html.a [ id "upload-widget-cancel", Html.Attributes.href "/widgets" ] [ button [] [Html.i [class "fa fa-minus"] []] ]
    ,   hr [] []
    ,   form [action "/api/widget", method "POST", enctype "multipart/form-data"]
        [   div [id "app-id"] 
            [   label [] [text "App ID"]
            ,   input [type_ "text", placeholder "12345678", name "id", required True] [] 
            ]
        ,   div [id "app-auth"] 
            [   label [] [text "App Authentication Secret"]
            ,   input [type_ "password", placeholder "12345678", name "auth", required True] [] 
            ]
        ,   div [id "app-files"]
            [   label [] [text "Widget Back-End"]
            ,   label [] [text "Widget Front-End"]
            ,   input [id "app-files-back", type_ "file", name "back-end", required True] []
            ,   input [id "app-files-front", type_ "file", name "front-end", required True] []
            ]
        ,   div [id "app-upload"] [button [type_ "submit"] [text "Upload"]]
        ]
    ]