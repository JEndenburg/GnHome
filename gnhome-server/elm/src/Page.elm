module Page exposing (view, Event, update)

import Html exposing (Html, text, nav, div, span, ul, li, i, hr, input, header, label, footer)
import Html.Attributes as Attributes exposing (id, class, type_, checked)
import Html.Events exposing (onClick)

import Session exposing (Session)
import ContentUtil

type Event
    = OnLogoutClicked

update : Event -> (Cmd Event)
update event =
    case event of
        OnLogoutClicked -> Session.deleteSessionData ()

view : Session -> List (Html Event)
view session = 
    [   viewNavigationBar session
    ,   viewHeader
    ,   viewFooter
    ]

viewHeader : Html msg
viewHeader = 
    header []
    [   text "GnHome"
    ]

viewNavigationBar : Session -> Html Event
viewNavigationBar session = 
    nav []
    [   div [id "nav-header"] [text "Menu"]
    ,   div [id "nav-username"] [(case session of
            Session.Guest -> text "Not Logged In"
            Session.LoggedIn username -> text username
        )]
    ,   span [id "nav-collapse"] [ i [class "fa fa-angle-right"] [] ]
    ,   ul []
        (case session of
            Session.Guest -> 
                [   viewNavigationElementDisabled [] "Dashboard" "dashboard"
                ,   viewNavigationElementDisabled [] "Widgets" "cubes"
                ,   hr [] []
                ,   viewNavigationElementDisabled [] "Settings" "gear"
                ,   viewNavigationElement [] "Login" "user" "/"
                ]
            Session.LoggedIn username ->
                [   viewNavigationElement [] "Dashboard" "dashboard" "/"
                ,   viewNavigationElement [] "Widgets" "cubes" "/widgets"
                ,   hr [] []
                ,   viewNavigationElement [] "Settings" "gear" "/settings"
                ,   viewNavigationElement [ onClick OnLogoutClicked ] "Logout" "user" "/"
                ]
        )
    ]

viewNavigationElement : List (Html.Attribute msg) -> String -> String -> String -> Html msg
viewNavigationElement attributes name icon url = 
    Html.a [ Attributes.href url ]
    [
        li attributes
        [   span [class "text"] [text name]
        ,   i [class ("fa fa-" ++ icon)] []
        ]
    ]

viewNavigationElementDisabled : List (Html.Attribute msg) -> String -> String -> Html msg
viewNavigationElementDisabled attributes name icon = 
    viewNavigationElement ((class "Disabled")::attributes) name icon ""

viewFooter : Html msg
viewFooter = 
    footer []
    [   text "GnHome v1.0.0"
    ]