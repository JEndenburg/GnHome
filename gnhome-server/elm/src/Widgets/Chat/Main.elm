module Widgets.Chat.Main exposing (..)

import Browser exposing (Document)

import Html exposing (Html, text, div, span, form, input)
import Html.Attributes exposing (class, id, type_, placeholder, required, value)
import Html.Events exposing (onInput, onSubmit)

import Json.Decode as JSON exposing (field, at, string, list)

import Time exposing (Posix, toYear, toMonth, toDay, toHour, toMinute, toSecond, Month(..))

import Widgets.Chat.Socket as Socket exposing(Message)

type alias Model =
    {   state : State
    ,   viewer : Maybe Socket.Viewer
    ,   typedMessage : String
    }

type State 
    = Connecting
    | Connected
    | Disconnected
    | Error

type Event
    = OnReceiveSocketMessage Socket.Event
    | OnSendMessage
    | OnTypingMessage String


main = Browser.document
    {   init = init
    ,   view = view
    ,   update = update
    ,   subscriptions = subscriptions
    }


init : JSON.Value -> (Model, Cmd Event)
init _ = ({ state = Connecting, viewer = Nothing, typedMessage = "" }, Cmd.none)

view : Model -> Document Event
view model = 
    {   title = "WebChat!"
    ,   body = 
        [   case model.state of
                Connecting -> viewConnecting
                Disconnected -> viewDisconnected
                Connected -> case model.viewer of
                    Just viewer -> viewConnected viewer model.typedMessage
                    Nothing -> viewError
                Error -> viewError
        ]
    }

update : Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
        OnReceiveSocketMessage socketEvent -> case Socket.update socketEvent of
            Socket.Connected viewer -> ({ model | state = Connected, viewer = Just viewer }, Cmd.none)
            Socket.Disconnected -> ({ model | state = Disconnected }, Cmd.none)
            Socket.ReceivedMessage message -> (appendMessageToHistory message model, Cmd.none)
            Socket.Invalid -> (model, Cmd.none)
        OnSendMessage -> ({model | typedMessage = ""}, Socket.sendSocketMessage model.typedMessage)
        OnTypingMessage message -> ({model | typedMessage = message}, Cmd.none)

subscriptions : Model -> Sub Event
subscriptions model = Sub.batch
    [   Sub.map OnReceiveSocketMessage Socket.subscriptions
    ]


appendMessageToHistory : Socket.Message -> Model -> Model
appendMessageToHistory message model =
    case model.state of
        Connected ->
            let
                (maybeViewer) = model.viewer
            in
                case maybeViewer of
                    Just viewer -> 
                        let
                            (updatedViewer) = { viewer | messages = (List.append viewer.messages [message]) }
                        in
                            { model | viewer = Just updatedViewer }
                    Nothing -> model
        _ -> { model | state = Error }
    

viewConnecting : Html Event
viewConnecting =
    div[] [text "Loading..."]

viewDisconnected : Html Event
viewDisconnected = 
    div[] [text "Failed!"]

viewConnected : Socket.Viewer -> String -> Html Event
viewConnected state typedMessage = 
    div[]
    [   div[] [text ("User: " ++ state.username)]
    ,   div[class "message-container"] (List.map viewMessage state.messages)
    ,   viewInputForm typedMessage
    ]

viewMessage : Message -> Html Event
viewMessage message = 
    div[class "message"]
    [   div[class "author"] [text (message.author ++ " sent:")]
    ,   div[class "content"] [text message.content]
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

viewInputForm : String -> Html Event
viewInputForm typedMessage = 
    form [onSubmit OnSendMessage]
    [   input [type_ "text", value typedMessage, placeholder "Enter a message here...", onInput OnTypingMessage, required True] []
    ,   input [type_ "submit", value "Send"] []
    ]

viewError : Html Event
viewError = 
    div[id "error"] [text "Something went wrong."]