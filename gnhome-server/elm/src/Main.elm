module Main exposing (..)

import Browser
import Browser.Navigation as Navigator
import Html exposing (Html, text, nav, div, span, ul, li, i, hr)
import Html.Attributes exposing (id, class)
import Url

type alias Navigation = 
    {   key : Navigator.Key
    ,   url : Url.Url
    }

type alias Model = 
    {   navigation : Navigation
    }

type Event
    = UrlChanged Url.Url
    | UrlRequested Browser.UrlRequest

main = Browser.application
    {   init = initialModel
    ,   view = view
    ,   update = update
    ,   subscriptions = subscriptions
    ,   onUrlChange = UrlChanged
    ,   onUrlRequest = UrlRequested
    }


initialModel : () -> Url.Url -> Navigator.Key -> (Model, Cmd Event)
initialModel _ url key = 
    ( Model (Navigation key url) , Cmd.none)

update : Event -> Model -> (Model, Cmd Event)
update event model = 
    case event of
        UrlRequested request ->
            case request of
                Browser.Internal url -> ( model, Navigator.pushUrl model.navigation.key (Url.toString url) )
                Browser.External href -> ( model, Navigator.load href )
        UrlChanged url ->
            (   { model | navigation = (updateNavigationUrl url model.navigation) }
            ,   Cmd.none
            )

updateNavigationUrl : Url.Url -> Navigation -> Navigation
updateNavigationUrl url nav = 
    { nav | url = url }

subscriptions : Model -> Sub Event
subscriptions model =
    Sub.none

view : Model -> Browser.Document Event
view model = 
    {   title = "GnHome"
    ,   body = 
        [   navigationBar
        ]
    }

navigationBar : Html Event
navigationBar = 
    nav []
    [   div [id "nav-header"] [text "Menu"]
    ,   span [id "nav-collapse"] [ i [class "fa fa-angle-right"] [] ]
    ,   ul []
        [   navigationElement [] "Dashboard" "dashboard"
        ,   navigationElementDisabled [] "Settings" "gear"
        ,   hr [] []
        ]
    ]

navigationElement : List (Html.Attribute Event) -> String -> String -> Html Event
navigationElement attributes name icon = 
    li attributes
    [   span [class "text"] [text name]
    ,   i [class ("fa fa-" ++ icon)] []
    ]

navigationElementDisabled : List (Html.Attribute Event) -> String -> String -> Html Event
navigationElementDisabled attributes name icon = 
    navigationElement ((class "Disabled")::attributes) name icon