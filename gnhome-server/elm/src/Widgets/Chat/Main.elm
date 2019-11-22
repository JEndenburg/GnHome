module Widgets.Chat.Main exposing (..)

import Browser exposing (Document)

import Html exposing (Html, text, div, span)
import Html.Attributes exposing (class, id)
import Html.Events

import Json.Decode as JSON exposing (field, at, string, list)

import Time exposing (Posix, toYear, toMonth, toDay, toHour, toMinute, toSecond, Month(..))

import Widgets.Chat.Socket as Socket exposing(Message)

type Model
    = Connecting
    | Connected Socket.Viewer
    | Disconnected
    | Error

type Event
    = OnReceiveSocketMessage Socket.Event
    | OnSendMessage


main = Browser.document
    {   init = init
    ,   view = view
    ,   update = update
    ,   subscriptions = subscriptions
    }


init : JSON.Value -> (Model, Cmd Event)
init _ = (Connecting, Cmd.none)

view : Model -> Document Event
view model = 
    {   title = "WebChat!"
    ,   body = 
        [   case model of
                Connecting -> viewConnecting
                Disconnected -> viewDisconnected
                Connected viewer -> viewConnected viewer
                Error -> Debug.todo "Implement Error view"
        ]
    }

update : Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
        OnReceiveSocketMessage socketEvent -> case Socket.update socketEvent of
            Socket.Connected viewer -> (Connected viewer, Cmd.none)
            Socket.Disconnected -> (Disconnected, Cmd.none)
            Socket.ReceivedMessage message -> (appendMessageToHistory message model, Cmd.none)
            Socket.Invalid -> (model, Cmd.none)
        OnSendMessage -> Debug.todo "Implement sending message"

subscriptions : Model -> Sub Event
subscriptions model = Sub.batch
    [   Sub.map OnReceiveSocketMessage Socket.subscriptions
    ]


appendMessageToHistory : Socket.Message -> Model -> Model
appendMessageToHistory message model =
    case model of
        Connected viewer -> Connected { viewer | messages = (viewer.messages ++ [message]) }
        _ -> Error
    

viewConnecting : Html Event
viewConnecting =
    div[] [text "Loading..."]

viewDisconnected : Html Event
viewDisconnected = 
    div[] [text "Failed!"]

viewConnected : Socket.Viewer -> Html Event
viewConnected state = 
    div[]
    [   div[] [text ("User: " ++ state.username)]
    ,   div[] (List.map viewMessage state.messages)
    ]

viewMessage : Message -> Html Event
viewMessage message = 
    div[]
    [   div[] [text (message.author ++ " sent:")]
    ,   div[] [text message.content]
    ,   viewTimestamp message.time
    ]

viewTimestamp : Posix -> Html Event
viewTimestamp posix =
    span [class "timestamp"] [ text 
        (   String.padLeft 4 '0' (String.fromInt (toYear Time.utc posix)) 
        ++  "-"
        ++  String.padLeft 2 '0' (String.fromInt (monthToInt (toMonth Time.utc posix)))
        ++  "-"
        ++  String.padLeft 2 '0' (String.fromInt (toDay Time.utc posix))
        ++  " "
        ++  String.padLeft 2 '0' (String.fromInt (toHour Time.utc posix))
        ++  ":"
        ++  String.padLeft 2 '0' (String.fromInt (toMinute Time.utc posix))
        ++ " (UTC)"
        ) ]

monthToInt : Time.Month -> Int
monthToInt month = 
    case month of
        Jan -> 1
        Feb -> 2
        Mar -> 3
        Apr -> 4
        May -> 5
        Jun -> 6
        Jul -> 7
        Aug -> 8
        Sep -> 9
        Oct -> 10
        Nov -> 11
        Dec -> 12