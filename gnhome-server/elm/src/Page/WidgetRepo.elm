port module Page.WidgetRepo exposing (..)

import Html exposing (Html, text, div, hr, table, tr, td, th, button)
import Html.Attributes exposing (style, class, id)
import Html.Events exposing (onCheck)
import Http
import Json.Decode as JSON exposing(Decoder, field, list, string, int, bool)
import Json.Encode as JEncode

import ContentUtil

type Model
    = Loading
    | Loaded (List Widget)
    | Failed

type Event
    = OnToggleToggled Widget Bool
    | OnWidgetJSONObtained JSON.Value

type alias Widget =
    {   name : String
    ,   uuid: String
    ,   version : String
    ,   description : String
    ,   active : Bool
    }

port fetchWidgetList : () -> Cmd msg
port toggleWidgetState : JEncode.Value -> Cmd msg
port onWidgetListJSONObtained : (JSON.Value -> msg) -> Sub msg


init : (Model, Cmd Event)
init = (Loading, fetchWidgetList ())

update : Event -> Model -> (Model, Cmd Event)
update event model = 
    case event of
        OnToggleToggled widget state -> (model, toggleWidgetState (toggleWidgetStateValue widget))
        OnWidgetJSONObtained json ->
            case JSON.decodeValue widgetArrayDecoder json of
                Ok widgetList -> (Loaded widgetList, Cmd.none)
                Err _ -> (Failed, Cmd.none)

subscriptions : Sub Event
subscriptions =
    Sub.batch
        [onWidgetListJSONObtained OnWidgetJSONObtained
        ]


view : Model -> (Html Event)
view model = 
    ContentUtil.viewModal
    [   div [ class "modal-header" ] [ text "Manage Widgets" ]
    ,   hr [] []
    ,   case model of
            Loading -> viewLoad
            Loaded widgetList -> viewLoaded widgetList
            Failed -> viewFail
    ]

viewLoad : Html Event
viewLoad = div [class "loading"] []

viewFail : Html Event
viewFail = 
    div []
    [   text "Failed to load.",
        ContentUtil.viewMessage ContentUtil.Error "Failed to interface with widget API. Try again later!"
    ]

viewLoaded : List Widget -> Html Event
viewLoaded widgetList = 
    table [id "widget-repo"]
    (
        List.append viewTableHeaders (viewWidgetList widgetList)
    )

viewTableHeaders : List (Html Event)
viewTableHeaders = 
    [
        tr []
        [   th [] [ text "Name" ]
        ,   th [] [ text "Version" ]
        ,   th [] [ text "Description" ]
        ,   th [] [ text "Add/Remove" ]
        ]
    ]

viewWidgetList : List Widget -> List (Html Event)
viewWidgetList widgetList = 
    List.map viewWidget widgetList

viewWidget : Widget -> Html Event
viewWidget widget = 
    tr []
    [   td [class "name"] [ text widget.name ]
    ,   td [class "version"] [ text widget.version ]
    ,   td [class "description"] [ text widget.description ]
    ,   td [class "button"] [ ContentUtil.viewToggle [ onCheck (OnToggleToggled widget) ] widget.active ]
    ]

widgetArrayDecoder : Decoder (List Widget)
widgetArrayDecoder =
    (list widgetDecoder)

widgetDecoder : Decoder Widget
widgetDecoder =
    JSON.map5 Widget
        (field "name" string)
        (field "uuid" string)
        (field "version" string)
        (field "description" string)
        (field "active" bool)

widgetStateChangeResultDecoder : Decoder Bool
widgetStateChangeResultDecoder = 
    JSON.at ["data", "setWidget"] bool

toggleWidgetStateValue : Widget -> JEncode.Value
toggleWidgetStateValue widget = 
    JEncode.object
    [   ("uuid", JEncode.string widget.uuid)
    ,   ("newState", JEncode.bool
            (
            if widget.active then
                False
            else
                True
            )
        )
    ]