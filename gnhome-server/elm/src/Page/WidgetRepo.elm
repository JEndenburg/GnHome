module Page.WidgetRepo exposing (..)

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
    = OnWidgetListDecoded
    (
        Result
        Http.Error
        (List Widget)
    )
    | OnToggleToggled Widget Bool
    | OnWidgetStateToggled
    (
        Result
        Http.Error
        Bool
    )

type alias Widget =
    {   name : String
    ,   version : String
    ,   description : String
    ,   active : Bool
    }

graphqlURL =
    "/api/graphql?query={main{widgets{name version description active}}}"

init : (Model, Cmd Event)
init = (Loading, fetchWidgetList)

update : Event -> Model -> (Model, Cmd Event)
update event model = 
    case event of
        OnWidgetListDecoded res ->
            case res of
                Ok widgetList -> (Loaded widgetList, Cmd.none)
                Err _ -> (Failed, Cmd.none)
        OnToggleToggled widget state -> (model, toggleWidgetState widget)
        OnWidgetStateToggled res -> (model, fetchWidgetList)


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

fetchWidgetList : Cmd Event
fetchWidgetList = Http.get { url = graphqlURL, expect = Http.expectJson OnWidgetListDecoded widgetArrayDecoder }

widgetArrayDecoder : Decoder (List Widget)
widgetArrayDecoder =
    JSON.at ["data", "main", "widgets"] (list widgetDecoder)

widgetDecoder : Decoder Widget
widgetDecoder =
    JSON.map4 Widget
        (field "name" string)
        (field "version" string)
        (field "description" string)
        (field "active" bool)

toggleWidgetState : Widget -> Cmd Event
toggleWidgetState widget =
    let
        stringBool = 
            if widget.active then
                "false"
            else
                "true"
    in
        Http.post 
            {   url = "/api/graphql"
            ,   body = Http.jsonBody (JEncode.object [ ( "query", JEncode.string ("mutation{setWidget(name:\"" ++ widget.name ++ "\"active:" ++ stringBool ++ ")}") ) ])
            ,   expect = Http.expectJson OnWidgetStateToggled widgetStateChangeResultDecoder 
            }

widgetStateChangeResultDecoder : Decoder Bool
widgetStateChangeResultDecoder = 
    JSON.at ["data", "setWidget"] bool