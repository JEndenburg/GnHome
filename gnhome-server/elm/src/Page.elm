module Page exposing (view)

import Html exposing (Html, text, nav, div, span, ul, li, i, hr, input, header, label, footer)
import Html.Attributes as Attributes exposing (id, class, type_, checked)

import Session exposing (Session)
import ContentUtil

view : Session -> List (Html msg)
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

viewNavigationBar : Session -> Html msg
viewNavigationBar session = 
    nav []
    [   div [id "nav-header"] [text "Menu"]
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
                ,   viewNavigationElementDisabled [] "Login" "user"
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