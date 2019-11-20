module Page exposing (view)

import Html exposing (Html, text, nav, div, span, ul, li, i, hr, input, header, label, footer)
import Html.Attributes as Attributes exposing (id, class, type_, checked)

import ContentUtil

view : List (Html msg)
view = 
    [   viewNavigationBar
    ,   viewHeader
    ,   viewFooter
    ]

viewHeader : Html msg
viewHeader = 
    header []
    [   text "GnHome"
    ]

viewNavigationBar : Html msg
viewNavigationBar = 
    nav []
    [   div [id "nav-header"] [text "Menu"]
    ,   span [id "nav-collapse"] [ i [class "fa fa-angle-right"] [] ]
    ,   ul []
        [   viewNavigationElement [] "Dashboard" "dashboard" "/"
        ,   viewNavigationElement [] "Widgets" "cubes" "/widgets"
        ,   hr [] []
        ,   viewNavigationElement [] "Settings" "gear" "/settings"
        ]
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

viewNavigationElementDisabled : List (Html.Attribute msg) -> String -> String -> String -> Html msg
viewNavigationElementDisabled attributes name icon url = 
    viewNavigationElement ((class "Disabled")::attributes) name icon url

viewFooter : Html msg
viewFooter = 
    footer []
    [   text "GnHome v1.0.0"
    ]