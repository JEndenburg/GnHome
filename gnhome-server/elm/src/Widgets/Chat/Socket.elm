port module Widgets.Chat.Socket exposing (..)

import Json.Decode as JSON exposing(Decoder, field, int, string, null)
import Json.Decode.Extra exposing (datetime)

import Time exposing (Posix, toYear, toMonth, toDay, toHour, toMinute, toSecond, Month(..))


type SocketMessageType
    = Connected Viewer
    | Disconnected
    | ReceivedMessage Message
    | Invalid

type alias SocketMessage =
    {   identifier : Int
    ,   content : Maybe SocketMessageContent
    }

type alias SocketMessageContent =
    {   message : Maybe Message
    ,   state : Maybe Viewer
    }

type alias Message =
    {   author : String
    ,   time : Posix
    ,   content : String
    }

type alias Viewer =
    {   username : String
    ,   messages : List Message
    }

type Event
    = OnSocketMessageReceived JSON.Value


port receiveSocketMessage : (JSON.Value -> msg) -> Sub msg
port sendSocketMessage : String -> Cmd msg


subscriptions : Sub Event
subscriptions = Sub.batch
    [   receiveSocketMessage OnSocketMessageReceived
    ]

update : Event -> SocketMessageType
update event =
    case event of
        OnSocketMessageReceived json -> decodeSocketMessage json


decodeSocketMessage : JSON.Value -> SocketMessageType
decodeSocketMessage json = 
    case JSON.decodeValue socketMessageDecoder json of
        Ok message -> case message.identifier of
            0 -> Disconnected
            1 -> case message.content of
                Just content -> case content.state of
                    Just viewer -> Connected viewer
                    Nothing -> Invalid
                Nothing -> Invalid
            2 -> case message.content of
                Just content -> case content.message of
                    Just userMessage -> ReceivedMessage userMessage
                    Nothing -> Invalid
                Nothing -> Invalid
            _ -> Invalid
        Err _ -> Invalid

socketMessageDecoder : JSON.Decoder SocketMessage
socketMessageDecoder = 
    JSON.map2 SocketMessage
        (field "id" int)
        (
            field "id" int
            |> JSON.andThen (socketMessageContentDecoder)
        )

socketMessageContentDecoder : Int -> JSON.Decoder (Maybe SocketMessageContent)
socketMessageContentDecoder id =
    case id of
        1 -> JSON.maybe <| JSON.map2 SocketMessageContent
                (JSON.succeed Nothing)
                (JSON.maybe (field "message" viewerDecoder))
        2 -> JSON.maybe <| JSON.map2 SocketMessageContent
                (JSON.maybe (field "message" messageDecoder))
                (JSON.succeed Nothing)
        _ -> JSON.succeed Nothing

messageDecoder : JSON.Decoder Message
messageDecoder = 
    JSON.map3 Message
        (field "author" string)
        (field "timestamp" datetime)
        (field "content" string)

viewerDecoder : JSON.Decoder Viewer
viewerDecoder =
    JSON.map2 Viewer
        (field "username" string)
        (field "history" (JSON.list messageDecoder))