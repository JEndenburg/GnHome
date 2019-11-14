module Page.WidgetRepo exposing (..)

import Html exposing (Html, text, div, hr)
import Html.Attributes exposing (style, class, id)

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
    [   div [ class "modal-header" ] [ text "Manage Widgets" ]
    ,   hr [] []
    ,   div [ class "modal-content" ] [ text "Widget Text" ]
    ]