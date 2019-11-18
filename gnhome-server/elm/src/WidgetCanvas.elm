port module WidgetCanvas exposing (..)

import Browser
import Html exposing(Html, div, text)
import Html.Attributes exposing(id)
import Http
import Json.Decode as JSON exposing(Decoder, field, list, string, int, bool, float)

type Model
    = Loading
    | Failed
    | Succeed (List Widget)

type Event
    =  OnRefresh ()
    | OnWidgetListJSONReceived JSON.Value

type alias Widget =
    {
        uuid : Int,
        name : String,
        version : String,
        size : Size,
        position: Position
    }

type alias Size =
    {
        width: Int,
        height: Int
    }

type alias Position = 
    {   x : Float
    ,   y : Float
    ,   z : Float
    }

    
port getWidgetsForUser : () -> Cmd msg
port onGetWidgetsForUser : (JSON.Value -> msg) -> Sub msg
port refreshWidgetCanvas : (() -> msg) -> Sub msg




main = Browser.element 
    {
        init = initialModel,
        view = view,
        update = update,
        subscriptions = subscriptions
    }

initialModel : () -> (Model, Cmd Event)
initialModel _ = (Loading, getWidgetsForUser ())

view : Model -> Html Event
view model = getView model

update : Event -> Model -> (Model, Cmd Event)
update event model = updateView event model

subscriptions : Model -> Sub Event
subscriptions model = Sub.batch 
    [   (refreshWidgetCanvas OnRefresh)
    ,   (onGetWidgetsForUser OnWidgetListJSONReceived)
    ]




updateView : Event -> Model -> (Model, Cmd Event)
updateView event model = 
    case event of
        OnRefresh _ ->
            (model, getWidgetsForUser ())
        OnWidgetListJSONReceived json ->
            case JSON.decodeValue widgetArrayDecoder json of
                Ok widgetList -> (Succeed widgetList, Cmd.none)
                Err _ -> (Failed, Cmd.none)


getView : Model -> Html Event
getView model = 
    case model of
        Loading -> loadView model
        Failed -> failView model
        Succeed widgetList -> successView widgetList model

loadView : Model -> Html Event
loadView model = div [id "loading"] []

failView : Model -> Html Event
failView model = div [] [text "Unfortunately, it failed."]

successView : (List Widget) -> Model -> Html Event
successView widgetList model = div[] [ constructWidgetListHTML widgetList ]




widgetArrayDecoder : Decoder (List Widget)
widgetArrayDecoder =
    (list widgetDecoder)

widgetDecoder : Decoder Widget
widgetDecoder =
    JSON.map5 Widget
        (field "uuid" int)
        (field "name" string)
        (field "version" string)
        (field "size" (sizeDecoder))
        (field "position" (positionDecoder))

sizeDecoder : Decoder Size
sizeDecoder = 
    JSON.map2 Size
        (field "width" int)
        (field "height" int)

positionDecoder : Decoder Position
positionDecoder = 
    JSON.map3 Position
        (field "x" float)
        (field "y" float)
        (field "z" float)

constructWidgetListHTML : (List Widget) -> Html Event
constructWidgetListHTML widgetList = 
    widgetList
    |> List.map (constructWidgetHTML)
    |> div []

constructWidgetHTML : Widget -> Html Event
constructWidgetHTML widget = 
    Html.article [Html.Attributes.id ("w-" ++ (String.fromInt widget.uuid)), Html.Attributes.class "widget", Html.Attributes.style "top" (String.fromFloat widget.position.y ++ "px"), Html.Attributes.style "left" (String.fromFloat widget.position.x ++ "px")] 
    [
        Html.div [Html.Attributes.class "widget-bar"] [ text (widget.name ++ " (" ++ widget.version ++ ")") ],
        Html.iframe 
        [
            Html.Attributes.src ("../widget/" ++ (String.fromInt widget.uuid)),
            Html.Attributes.width widget.size.width,
            Html.Attributes.height widget.size.height
        ] [],
        Html.div [Html.Attributes.class "blocker", Html.Attributes.hidden True] []
    ]