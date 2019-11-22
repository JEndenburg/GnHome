module Widgets.Chat.Main exposing (..)

import Browser exposing (Document)

import Html exposing (Html, text, div)
import Html.Attributes exposing (class, id)
import Html.Events

import Json.Decode as JSON exposing (Decoder)

type alias Model =
    {   username : String
    ,   messages : List Message
    }

type alias Message =
    {   username : String
    ,   content : String
    }

type Event
    = OnSendMessage



main = Browser.document
    {   init = init
    ,   view = view
    ,   update = update
    ,   subscriptions = subscriptions
    }


init : JSON.Value -> (Model, Cmd Event)
init flags = 
    (   {   username = "nobody"
        ,   messages = []
        }
    ,   Cmd.none
    )

view : Model -> Document Event
view model = 
    {   title = "WebChat!"
    ,   body = []
    }

update : Event -> Model -> (Model, Cmd Event)
update event model = (model, Cmd.none)

subscriptions : Model -> Sub Event
subscriptions model =
    Sub.none


