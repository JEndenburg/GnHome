module Page exposing (view)

import Html exposing (Html, text, nav, div, span, ul, li, i, hr)
import Html.Attributes as Attributes exposing (id, class)

view : Html msg
view = 
    viewNavigationBar

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