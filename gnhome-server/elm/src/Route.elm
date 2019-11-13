module Route exposing (Route(..), parseUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)

type Route
    = NotFound
    | Dashboard
    | Widgets



parser : Parser (Route -> a) a
parser = 
    oneOf
        [   Parser.map Dashboard Parser.top
        ,   Parser.map Dashboard (s "m")
        ,   Parser.map Widgets (s "m/widgets")
        ]

parseUrl : Url -> Route
parseUrl url = 
    case Parser.parse parser url of
        Just route -> route
        Nothing -> NotFound