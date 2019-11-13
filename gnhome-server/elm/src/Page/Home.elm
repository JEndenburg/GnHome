module Page.Home exposing (..)

import Html

type Model
    = Main

init : (Model, Cmd msg)
init = (Main, Cmd.none)