module Route exposing (Route(..), parseUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)

type Route
    = NotFound
    | Dashboard
    | WidgetRepo



parser : Parser (Route -> a) a
parser = 
    oneOf
        [   Parser.map Dashboard Parser.top
        ,   Parser.map WidgetRepo (s "widgets")
        ]

parseUrl : Url -> Route
parseUrl url = 
    case Parser.parse parser url of
        Just route -> route
        Nothing -> NotFound