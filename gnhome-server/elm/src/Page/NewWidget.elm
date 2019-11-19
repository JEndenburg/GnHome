module Page.NewWidget exposing (..)

import Html exposing (Html, text, div, button, hr, form, label, input, textarea)
import Html.Attributes exposing (style, class, id, type_, placeholder, action, enctype, method, name)
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
        [   div [id "app-name"] 
            [   label [] [text "App Name"]
            ,   input [type_ "text", placeholder "MyFirstApp", name "name"] [] 
            ]
        ,   div [id "app-version"]
            [   label [] [text "App Version"]
            ,   input [type_ "text", placeholder "4.1.8", name "version"] []
            ]
        ,   div [id "app-description"]
            [   label [] [text "Description"]
            ,   textarea [placeholder "My first application! It's amazing", name "description"] []
            ]
        ,   div [id "app-files"]
            [   label [] [text "Widget Back-End"]
            ,   label [] [text "Widget Front-End"]
            ,   input [id "app-files-back", type_ "file", name "back-end"] []
            ,   input [id "app-files-front", type_ "file", name "front-end"] []
            ]
        ,   div [id "app-upload"] [button [type_ "submit"] [text "Upload"]]
        ]
    ]