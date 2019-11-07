module Main exposing (..)

import Browser
import Html exposing(Html, div, text)
import Http
import Json.Decode as JSON exposing(Decoder, field, list, string)

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

type alias Widget =
    {
        name : String,
        url : String
    }



graphqlURL =
    "http://localhost:8000/api/graphql?query={main{widgets{name html{responseJson}}}}"

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
    Sub.none




updateView : Event -> Model -> (Model, Cmd Event)
updateView event model = 
    case event of
        OnWidgetListDecoded response ->
            case response of
                Ok widgetList -> (Succeed widgetList, Cmd.none)
                Err _ -> (Failed, Cmd.none)


getView : Model -> Html Event
getView model = 
    case model of
        Loading -> loadView model
        Failed -> failView model
        Succeed widgetList -> successView widgetList model

loadView : Model -> Html Event
loadView model = div[] [text "Loading..."]

failView : Model -> Html Event
failView model = div[] [text "Unfortunately, it failed."]

successView : (List Widget) -> Model -> Html Event
successView widgetList model = div[] [ constructWidgetListHTML widgetList ]




fetchWidgetList : Cmd Event
fetchWidgetList = Http.get { url = graphqlURL, expect = Http.expectJson OnWidgetListDecoded widgetArrayDecoder }

widgetArrayDecoder : Decoder (List Widget)
widgetArrayDecoder =
    JSON.at ["data", "main", "widgets"] (list widgetDecoder)

widgetDecoder : Decoder Widget
widgetDecoder =
    JSON.map2 Widget
        (field "name" string)
        (field "html" (field "responseJson" string))

constructWidgetListHTML : (List Widget) -> Html Event
constructWidgetListHTML widgetList = 
    widgetList
    |> List.map (constructWidgetHTML)
    |> div []

constructWidgetHTML : Widget -> Html Event
constructWidgetHTML widget = 
    Html.article [] [ text (widget.name ++ " at " ++ widget.url) ]