module Page.Error.NotFound exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (style, href)

import ContentUtil

type Model
    = Main

type Event
    = None

init : (Model, Cmd msg)
init = (Main, Cmd.none)

view : (Html Event)
view = 
    Html.a [ href "/" ]
        [ContentUtil.viewMessage ContentUtil.Warning "The page you tried to access does not exist."]