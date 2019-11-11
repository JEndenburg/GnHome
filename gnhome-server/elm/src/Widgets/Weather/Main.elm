port module Widgets.Weather.Main exposing (..)

import Browser
import Html exposing (Html, div, text)
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
    ,   weather: Weather
    ,   temperature : String
    }

type Weather
    = Sunny
    | ClearNight
    | HalfCloudy
    | Cloudy
    | HeavyCloudy
    | CloudyNight
    | Drizzle
    | Rain
    | Snow
    | Hail
    | Thunder
    | Misty
    | MistyNight

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
initialModel _ = (FetchingLocation, requestGeolocation ())

view : Model -> Html Event
view model = 
    case model of
        FetchingLocation -> fetchingLocationModel
        FetchingWeather location -> fetchingWeatherModel location
        Complete weatherReport -> completeModel weatherReport
        FailedLocation -> noLocationModel
        FailedWeather -> noWeatherModel

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
    div [] [ text "Fetching Location..." ]

fetchingWeatherModel : Location -> Html Event
fetchingWeatherModel location = 
    div[] [ text "Fetching Weather..." ]

completeModel : WeatherReport -> Html Event
completeModel weatherReport = 
    div[] [ text "Got Weather!" ]

noLocationModel : Html Event
noLocationModel = 
    div[] [ text "Failed to get Location!" ]

noWeatherModel : Html Event
noWeatherModel = 
    div[] [ text "Failed to get Weather!" ]



locationDecoder : Decoder Location
locationDecoder =
    JSON.map2 Location
        (field "longitude" float)
        (field "latitude" float)



getWeatherAPIUrl : Location -> String
getWeatherAPIUrl location = "http://weerlive.nl/api/json-data-10min.php?key=4096407fcf&locatie=" ++ (String.fromFloat location.latitude) ++ "," ++ (String.fromFloat location.longitude)

fetchWeatherReport : Location -> Cmd Event
fetchWeatherReport location = Http.get { url = (getWeatherAPIUrl location), expect = Http.expectJson DecodedWeatherReport weatherReportDecoder }

weatherReportDecoder : Decoder WeatherReport
weatherReportDecoder =
    JSON.at [ "liveweer" ] (JSON.index 0 weatherReportInternalDecoder)

weatherReportInternalDecoder : Decoder WeatherReport
weatherReportInternalDecoder = 
    JSON.map3 WeatherReport
        (field "plaats" string)
        (field "image" weatherTypeDecoder)
        (field "temp" string)

weatherTypeDecoder : Decoder Weather
weatherTypeDecoder = 
    string
        |> JSON.andThen (\str ->
            case str of
                "zonnig" ->
                    JSON.succeed Sunny
                "bliksem" ->
                    JSON.succeed Thunder
                "regen" ->
                    JSON.succeed Rain
                "buien" ->
                    JSON.succeed Drizzle
                "hagel" ->
                    JSON.succeed Hail
                "mist" ->
                    JSON.succeed Misty
                "sneeuw" ->
                    JSON.succeed Snow
                "bewolkt" ->
                    JSON.succeed Cloudy
                "halfbewolkt" ->
                    JSON.succeed HalfCloudy
                "zwaarbewolkt" ->
                    JSON.succeed HeavyCloudy
                "nachtmist" ->
                    JSON.succeed MistyNight
                "helderenacht" ->
                    JSON.succeed ClearNight
                "wolkennacht" ->
                    JSON.succeed CloudyNight
                _ ->
                    JSON.fail <| "Unrecognized weather type."
        )