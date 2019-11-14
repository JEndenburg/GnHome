module Page.Dashboard exposing (..)

import Html exposing (Html, div)
import Html.Attributes exposing (style)

type Model
    = Main

type Event
    = None

init : (Model, Cmd msg)
init = (Main, Cmd.none)

view : Model -> (Html Event)
view model = 
    div[style "display" "none"] []