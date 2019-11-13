module Page exposing (view)

import Html exposing (Html, text, nav, div, span, ul, li, i, hr, input, header, label, footer)
import Html.Attributes as Attributes exposing (id, class, type_, checked)

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
    ,   label [ id "dark-mode-switch", class "switch" ]
        [   input [ type_ "checkbox", checked False ] []
        ,   span [ class "slider" ] []
        ]
    ]

viewNavigationBar : Html msg
viewNavigationBar = 
    nav []
    [   div [id "nav-header"] [text "Menu"]
    ,   span [id "nav-collapse"] [ i [class "fa fa-angle-right"] [] ]
    ,   ul []
        [   viewNavigationElement [] "Dashboard" "dashboard"
        ,   viewNavigationElementDisabled [] "Settings" "gear"
        ,   hr [] []
        ]
    ]

viewNavigationElement : List (Html.Attribute msg) -> String -> String -> Html msg
viewNavigationElement attributes name icon = 
    Html.a [ Attributes.href "javascript:;" ]
    [
        li attributes
        [   span [class "text"] [text name]
        ,   i [class ("fa fa-" ++ icon)] []
        ]
    ]

viewNavigationElementDisabled : List (Html.Attribute msg) -> String -> String -> Html msg
viewNavigationElementDisabled attributes name icon = 
    viewNavigationElement ((class "Disabled")::attributes) name icon

viewFooter : Html msg
viewFooter = 
    footer []
    [   text "GnHome v0.0.2"
    ]