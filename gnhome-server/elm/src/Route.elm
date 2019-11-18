module Route exposing (Route(..), parseUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)

type Route
    = NotFound
    | Dashboard
    | WidgetRepo
    | NewWidget



parser : Parser (Route -> a) a
parser = 
    oneOf
        [   Parser.map Dashboard Parser.top
        ,   Parser.map WidgetRepo (s "widgets")
        ,   Parser.map NewWidget (s "widgets" </> s "new")
        ]

parseUrl : Url -> Route
parseUrl url = 
    case Parser.parse parser url of
        Just route -> route
        Nothing -> NotFound