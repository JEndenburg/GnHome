module Page.WidgetRepo exposing (..)

import Html exposing (Html, text, div)
import Html.Attributes exposing (style)

import ContentUtil

type Model
    = Main

type Event
    = None

init : (Model, Cmd msg)
init = (Main, Cmd.none)

view : Model -> (Html Event)
view model = 
    ContentUtil.viewModal
    [
        text "Bacon Ipsum Dolorem Spicy Jalapeño"
    ]