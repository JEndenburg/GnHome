port module Page.Login exposing(..)

import Html exposing (Html, text, div, hr, form, input, button, label)
import Html.Attributes exposing (class, id, action, type_, placeholder, required)
import Html.Events exposing (onSubmit)

import ContentUtil

type Model
    = LoggedOut
    | Loading
    | LoggedIn

type Event
    = OnLoginSubmit
    | OnLoggedIn String



port login : () -> Cmd msg

init : (Model, Cmd Event)
init = (LoggedOut, Cmd.none)

update : Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
        OnLoginSubmit -> (Loading, login ())
        OnLoggedIn name -> (LoggedIn, Cmd.none)

view : Model -> (Html Event)
view model = ContentUtil.viewModal
    [   div [ class "modal-header" ] [ text (modalHeaderText model) ]
    ,   hr [] []
    ,   case model of
            LoggedOut -> viewLoggedOut
            LoggedIn -> div [] []
            Loading -> viewLoad
    ]

modalHeaderText : Model -> String
modalHeaderText model = 
    case model of
        LoggedOut -> "Login"
        LoggedIn -> "User Management"
        Loading -> "Login"

viewLoad : Html Event
viewLoad = div [class "loading"] []

viewLoggedOut : Html Event
viewLoggedOut = 
    form [id "login-form", action "javascript:;", onSubmit OnLoginSubmit] 
    [   div [ id "username" ]
        [   label [] [ text "Username" ]
        ,   input [ type_ "text", placeholder "Username1234", required True ] []
        ]
    ,   div [ id "password" ]
        [   label [] [ text "Password" ]
        ,   input [ type_ "password", placeholder "Password1234", required True ] []
        ]
    ,   button [] [ text "Login" ]
    ]