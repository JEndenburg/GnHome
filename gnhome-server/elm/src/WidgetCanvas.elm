port module WidgetCanvas exposing (..)

import Browser
import Html exposing(Html, div, text)
import Html.Attributes exposing(id)
import Http
import Json.Decode as JSON exposing(Decoder, field, list, string, int, bool)

type Model
    = Loading
    | Failed
    | Succeed (List Widget)

type Event
    = OnWidgetListDecoded
    (
        Result
        Http.Error
        (List Widget)
    )
    | OnRefresh ()

type alias Widget =
    {
        uuid : Int,
        name : String,
        version : String,
        size : Size,
        active : Bool
    }

type alias Size =
    {
        width: Int,
        height: Int
    }



graphqlURL =
    "/api/graphql?query={main{widgets{name version uuid size{width height} active}}}"

port refreshWidgetCanvas : (() -> msg) -> Sub msg

graphqlRequestBody : Http.Body
graphqlRequestBody =
    Http.stringBody "plain/text" "{main{widgets{name html{responseJson}}}}"



main = Browser.element 
    {
        init = initialModel,
        view = view,
        update = update,
        subscriptions = subscriptions
    }

initialModel : () -> (Model, Cmd Event)
initialModel _ = (Loading, fetchWidgetList)

view : Model -> Html Event
view model = getView model

update : Event -> Model -> (Model, Cmd Event)
update event model = updateView event model

subscriptions : Model -> Sub Event
subscriptions model =
    refreshWidgetCanvas OnRefresh




updateView : Event -> Model -> (Model, Cmd Event)
updateView event model = 
    case event of
        OnWidgetListDecoded response ->
            case response of
                Ok widgetList -> (Succeed widgetList, Cmd.none)
                Err _ -> (Failed, Cmd.none)
        OnRefresh _ ->
            (model, fetchWidgetList)


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




fetchWidgetList : Cmd Event
fetchWidgetList = Http.get { url = graphqlURL, expect = Http.expectJson OnWidgetListDecoded widgetArrayDecoder }

widgetArrayDecoder : Decoder (List Widget)
widgetArrayDecoder =
    JSON.at ["data", "main", "widgets"] (list widgetDecoder)

widgetDecoder : Decoder Widget
widgetDecoder =
    JSON.map5 Widget
        (field "uuid" int)
        (field "name" string)
        (field "version" string)
        (field "size" (sizeDecoder))
        (field "active" bool)

sizeDecoder : Decoder Size
sizeDecoder = 
    JSON.map2 Size
        (field "width" int)
        (field "height" int)

constructWidgetListHTML : (List Widget) -> Html Event
constructWidgetListHTML widgetList = 
    widgetList
    |> List.map (constructWidgetHTML)
    |> div []

constructWidgetHTML : Widget -> Html Event
constructWidgetHTML widget = 
    if widget.active then
        Html.article [Html.Attributes.class "widget", Html.Attributes.style "top" "0vw", Html.Attributes.style "left" "0vw"] 
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
    else
        div[] []