module Main exposing (..)

import Browser
import Browser.Navigation as Navigator
import Html exposing (Html, text, nav, div, span, ul, li, i, hr)
import Html.Attributes as Attributes exposing (id, class)
import Url
import Route exposing(Route)
import Session exposing(Session)

import Page
import Page.Dashboard
import Page.WidgetRepo
import Page.NewWidget
import Page.Settings
import Page.Login

import Page.Error.NotFound

type alias Model = 
    {   route : Route
    ,   navKey : Navigator.Key
    ,   page : Page
    ,   session : Session
    }

type Page
    = NotFound
    | Dashboard Page.Dashboard.Model
    | WidgetRepo Page.WidgetRepo.Model
    | NewWidget Page.NewWidget.Model
    | Settings Page.Settings.Model
    | Login Page.Login.Model

type Event
    = UrlChanged Url.Url
    | UrlRequested Browser.UrlRequest
    | BasePageEvent Page.Event
    | NotFoundEvent Page.Error.NotFound.Event
    | DashboardEvent Page.Dashboard.Event
    | WidgetRepoEvent Page.WidgetRepo.Event
    | NewWidgetEvent Page.NewWidget.Event
    | SettingsEvent Page.Settings.Event
    | LoginEvent Page.Login.Event
    | SessionEvent Session.Event

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
            ,   session = Session.Guest
            }
    in
        changePage (model, Cmd.map SessionEvent (Session.requestSessionData ()))

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

        (BasePageEvent ev, _) ->
            let subCmd = Page.update ev
            in (model, Cmd.map BasePageEvent subCmd)

        (WidgetRepoEvent ev, WidgetRepo page) ->
            let (subModel, subCmd) = Page.WidgetRepo.update ev page
            in ({model | page = WidgetRepo subModel}, Cmd.map WidgetRepoEvent subCmd)

        (SettingsEvent ev, Settings page) ->
            let (subModel, subCmd) = Page.Settings.update ev page
            in ({model | page = Settings subModel}, Cmd.map SettingsEvent subCmd)

        (LoginEvent ev, Login page) ->
            let (subModel, subCmd) = Page.Login.update ev page
            in ({model | page = Login {subModel | session = model.session }}, Cmd.map LoginEvent subCmd)

        (SessionEvent ev, _) ->
            case ev of
                Session.OnSessionChanged maybeUsername ->
                    case maybeUsername of
                        Just username -> changePage ( { model | session = Session.LoggedIn username }, Cmd.none )
                        Nothing -> ( { model | session = Session.Guest }, Cmd.none)

        (_,_) -> (model, Cmd.none)


changePage : (Model, Cmd Event) -> (Model, Cmd Event)
changePage (model, ev) = 
    let
        (page, mappedCommands) = 
            case model.session of
                Session.Guest -> let (subModel, subCmds) = Page.Login.init in ( Login subModel, Cmd.map LoginEvent subCmds )
                Session.LoggedIn session ->
                    case model.route of
                        Route.NotFound -> let (subModel, subCmds) = Page.Error.NotFound.init in ( NotFound, Cmd.map NotFoundEvent subCmds )
                        Route.WidgetRepo -> let (subModel, subCmds) = Page.WidgetRepo.init in ( WidgetRepo subModel, Cmd.map WidgetRepoEvent subCmds )
                        Route.Dashboard -> let (subModel, subCmds) = Page.Dashboard.init in ( Dashboard subModel, Cmd.map DashboardEvent subCmds )
                        Route.NewWidget -> let (subModel, subCmds) = Page.NewWidget.init in ( NewWidget subModel, Cmd.map NewWidgetEvent subCmds )
                        Route.Settings -> let (subModel, subCmds) = Page.Settings.init in ( Settings subModel, Cmd.map SettingsEvent subCmds )
    in
    (   { model | page = page }
    ,   Cmd.batch [ ev, mappedCommands ]
    )
    

    
-- An ugly workaround for something that's either unexpected behaviour in the elm runtime, or a flaw within the foundation of this application.

-- I'd expect that you subscribe based on the model on a per-page module case, though this seems to not trigger correctly.
-- The workaround makes it so that the SPA is always subscribed to the subscriptions expected from every single page.
subscriptions : Model -> Sub Event
subscriptions model =
    Sub.batch
    [   (Sub.map WidgetRepoEvent (Page.WidgetRepo.subscriptions))
    ,   (Sub.map SettingsEvent (Page.Settings.subscriptions))
    ,   (Sub.map SessionEvent (Session.subscriptions))
    ]

view : Model -> Browser.Document Event
view model = 
    {   title = "GnHome"
    ,   body = 
            List.append
                (Page.view model.session
                    |> List.map (Html.map BasePageEvent)
                )
                [
                case model.page of
                    NotFound -> Page.Error.NotFound.view
                        |> Html.map NotFoundEvent
                    Dashboard subModel -> Page.Dashboard.view subModel
                        |> Html.map DashboardEvent
                    WidgetRepo subModel -> Page.WidgetRepo.view subModel
                        |> Html.map WidgetRepoEvent
                    NewWidget subModel -> Page.NewWidget.view subModel
                        |> Html.map NewWidgetEvent
                    Settings subModel -> Page.Settings.view subModel
                        |> Html.map SettingsEvent
                    Login subModel -> Page.Login.view subModel
                        |> Html.map LoginEvent
                ]
    }