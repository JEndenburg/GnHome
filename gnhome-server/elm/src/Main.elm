module Main exposing (..)

import Browser
import Html exposing(Html, div, text)
import Http
import Json.Decode as JSON


main = Browser.element 
    {
        init = initialModel,
        view = view,
        update = update,
        subscriptions = subscriptions
    }

type Model = Default
type Message = None

initialModel : () -> (Model, Cmd Message)
initialModel _ = (Default, Cmd.none)

view : Model -> Html null
view model = div[] [text "Hello World"]

update : null -> Model -> (Model, Cmd Message)
update _ model = (Default, Cmd.none)

subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none