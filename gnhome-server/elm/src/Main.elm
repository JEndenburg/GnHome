module Main exposing (..)

import Browser
import Browser.Navigation as Navigator
import Html exposing (Html, text, nav, div, span, ul, li, i, hr)
import Html.Attributes as Attributes exposing (id, class)
import Url
import Route exposing(Route)

import Page
import Page.Dashboard

type alias Model = 
    {   route : Route
    ,   navKey : Navigator.Key
    ,   page : Page
    }

type Page
    = NotFound
    | Dashboard Page.Dashboard.Model

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
    let
        model =
            {   route = Route.parseUrl url
            ,   page = NotFound
            ,   navKey = key
            }
    in
        changePage (model, Cmd.none)

update : Event -> Model -> (Model, Cmd Event)
update event model = 
    case event of
        UrlRequested request ->
            case request of
                Browser.Internal url -> ( model, Navigator.pushUrl model.navKey (Url.toString url) )
                Browser.External href -> ( model, Navigator.load href )
        UrlChanged url ->
            ({model | route = (Route.parseUrl url)}, Cmd.none)


changePage : (Model, Cmd msg) -> (Model, Cmd msg)
changePage (model, ev) = 
    let
        (page, mappedCommands) = 
            case model.route of
                Route.NotFound -> ( NotFound, Cmd.none )
                Route.Dashboard -> let (subModel, subCmds) = Page.Dashboard.init in ( Dashboard subModel, subCmds )
                Route.Widgets -> let (subModel, subCmds) = Page.Dashboard.init in ( NotFound, subCmds )
    in
    (   { model | page = page }
    ,   Cmd.batch [ ev, mappedCommands ]
    )
    

subscriptions : Model -> Sub Event
subscriptions model =
    Sub.none

view : Model -> Browser.Document Event
view model = 
    {   title = "GnHome"
    ,   body = 
        List.append
        Page.view
        [   case model.page of
                NotFound -> div [] []
                Dashboard subModel -> div [] []
        ]
    }