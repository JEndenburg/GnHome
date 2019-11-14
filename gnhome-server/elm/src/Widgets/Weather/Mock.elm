port module Widgets.Weather.Mock exposing (..)

import Browser
import Html exposing (Html, div, text, span)
import Html.Attributes exposing(id, style, width, height)
import Http
import Json.Decode as JSON exposing (Decoder, field, float, string)
import Json.Encode

type Model 
    = FetchingLocation
    | FetchingWeather Location
    | Complete WeatherReport
    | FailedLocation
    | FailedWeather

type alias Location = 
    {   longitude : Float
    ,   latitude : Float
    }

type alias WeatherReport = 
    {   locationName : String
    ,   weather: String
    ,   temperature : String
    }

type Event
    = ReceivedGeolocation Json.Encode.Value
    | DecodedWeatherReport ( Result Http.Error WeatherReport )


main = Browser.element
    {   init = initialModel
    ,   view = view
    ,   update = update
    ,   subscriptions = subscriptions
    }

port requestGeolocation : () -> Cmd msg
port receiveGeolocation : (JSON.Value -> msg) -> Sub msg


initialModel : () -> (Model, Cmd Event)
initialModel _ = (FetchingLocation, fetchWeatherReport (Location 0 0))

view : Model -> Html Event
view model = 
    div [id "app"] [
        case model of
            FetchingLocation -> fetchingLocationModel
            FetchingWeather location -> fetchingWeatherModel location
            Complete weatherReport -> completeModel weatherReport
            FailedLocation -> noLocationModel
            FailedWeather -> noWeatherModel
    ]

update : Event -> Model -> (Model, Cmd Event)
update event model = 
    case event of
        ReceivedGeolocation jsonValue -> 
            case (JSON.decodeValue locationDecoder jsonValue) of
                Ok location -> (FetchingWeather location, fetchWeatherReport location)
                Err _ -> (FailedLocation, Cmd.none)
        DecodedWeatherReport result ->
            case result of
                Ok report -> (Complete report, Cmd.none)
                Err _ -> (FailedWeather, Cmd.none)

subscriptions : Model -> Sub Event
subscriptions model =
    receiveGeolocation ReceivedGeolocation



fetchingLocationModel : Html Event
fetchingLocationModel = 
    div [id "loading"] [ text "Fetching Location..." ]

fetchingWeatherModel : Location -> Html Event
fetchingWeatherModel location = 
    div[id "loading"] [ text "Fetching Weather..." ]

completeModel : WeatherReport -> Html Event
completeModel weatherReport = 
    div[ 
        id "weather-report",
        style "background-image" ("url(\"./img/icons/" ++ weatherReport.weather ++ ".png\")")
    ] [
        div [id "location"] [ text weatherReport.locationName ],
        div [id "temperature"] [ text weatherReport.temperature, span [] [ text "°C" ] ]
    ]

noLocationModel : Html Event
noLocationModel = 
    div[id "error"] [ text "Failed to get Location!" ]

noWeatherModel : Html Event
noWeatherModel = 
    div[id "error"] [ text "Failed to get Weather!" ]



locationDecoder : Decoder Location
locationDecoder =
    JSON.map2 Location
        (field "longitude" float)
        (field "latitude" float)



getWeatherAPIUrl : Location -> String
getWeatherAPIUrl location = "/mock/api/weather.json"

fetchWeatherReport : Location -> Cmd Event
fetchWeatherReport location = Http.get { url = (getWeatherAPIUrl location), expect = Http.expectJson DecodedWeatherReport weatherReportDecoder }

weatherReportDecoder : Decoder WeatherReport
weatherReportDecoder =
    JSON.at [ "liveweer" ] (JSON.index 0 weatherReportInternalDecoder)

weatherReportInternalDecoder : Decoder WeatherReport
weatherReportInternalDecoder = 
    JSON.map3 WeatherReport
        (field "plaats" string)
        (field "image" string)
        (field "temp" string)