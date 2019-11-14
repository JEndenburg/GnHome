module Main exposing (..)

import Browser
import Browser.Navigation as Navigator
import Html exposing (Html, text, nav, div, span, ul, li, i, hr)
import Html.Attributes as Attributes exposing (id, class)
import Url
import Route exposing(Route)

import Page
import Page.Dashboard
import Page.WidgetRepo

import Page.Error.NotFound

type alias Model = 
    {   route : Route
    ,   navKey : Navigator.Key
    ,   page : Page
    }

type Page
    = NotFound
    | Dashboard Page.Dashboard.Model
    | WidgetRepo Page.WidgetRepo.Model

type Event
    = UrlChanged Url.Url
    | UrlRequested Browser.UrlRequest
    | NotFoundEvent Page.Error.NotFound.Event
    | DashboardEvent Page.Dashboard.Event
    | WidgetRepoEvent Page.WidgetRepo.Event

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
    case (event, model.page) of
        (UrlRequested request, _) ->
            case request of
                Browser.Internal url -> ( model, Navigator.pushUrl model.navKey (Url.toString url) )
                Browser.External href -> ( model, Navigator.load href )
        (UrlChanged url, _) ->
            ({model | route = (Route.parseUrl url)}, Cmd.none)
                |> changePage

        (WidgetRepoEvent ev, WidgetRepo page) ->
            let (subModel, subCmd) = Page.WidgetRepo.update ev page
            in ({model | page = WidgetRepo subModel}, Cmd.map WidgetRepoEvent subCmd)

        (_,_) -> (model, Cmd.none)


changePage : (Model, Cmd Event) -> (Model, Cmd Event)
changePage (model, ev) = 
    let
        (page, mappedCommands) = 
            case model.route of
                Route.NotFound -> let (subModel, subCmds) = Page.Error.NotFound.init in ( NotFound, Cmd.map NotFoundEvent subCmds )
                Route.Dashboard -> let (subModel, subCmds) = Page.Dashboard.init in ( Dashboard subModel, Cmd.map DashboardEvent subCmds )
                Route.WidgetRepo -> let (subModel, subCmds) = Page.WidgetRepo.init in ( WidgetRepo subModel, Cmd.map WidgetRepoEvent subCmds )
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
                [
                case model.page of
                    NotFound -> Page.Error.NotFound.view
                        |> Html.map NotFoundEvent
                    Dashboard subModel -> Page.Dashboard.view subModel
                        |> Html.map DashboardEvent
                    WidgetRepo subModel -> Page.WidgetRepo.view subModel
                        |> Html.map WidgetRepoEvent
                ]
    }