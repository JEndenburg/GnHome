port module Page.Settings exposing (..)

import Html exposing (Html, text, div, hr, table, tr, td, select, option)
import Html.Attributes exposing (class, id, selected)
import Html.Events exposing (on)
import Json.Decode as JSON exposing (field, int)

import ContentUtil

type Model
    = Loading
    | Loaded Settings
    | Failed

type alias Settings =
    {   theme : Int
    }

type Event
    = OnSettingsJSONReceived JSON.Value
    | OnThemeChanged String


port getSettings : () -> Cmd msg
port updateSettings : Settings -> Cmd msg
port receiveSettings : (JSON.Value -> msg) -> Sub msg


init : (Model, Cmd Event)
init = (Loading, getSettings ())

update : Event -> Model -> (Model, Cmd Event)
update event model =
    case event of
        OnSettingsJSONReceived json -> 
            case JSON.decodeValue settingsDecoder json of
                Ok settings -> (Loaded settings, Cmd.none)
                Err _ -> (Failed, Cmd.none)
        OnThemeChanged themeName ->
            case model of
                Loaded settings -> (model, updateSettings { settings | theme = (mapThemeValue themeName)} )
                _ -> (model, Cmd.none)

view : Model -> (Html Event)
view model = 
    ContentUtil.viewModal
    [   div [ class "modal-header" ] [ text "User Settings" ]
    ,   hr [] []
    ,   case model of
            Loading -> viewLoad
            Loaded settings -> viewLoaded settings
            Failed -> viewFail
    ]

subscriptions : Sub Event
subscriptions =
    Sub.batch
        [receiveSettings OnSettingsJSONReceived
        ]


viewLoad : Html Event
viewLoad = div [class "loading"] []

viewFail : Html Event
viewFail = 
    div []
    [   text "Failed to load.",
        ContentUtil.viewMessage ContentUtil.Error "Failed to get user settings. Try again later!"
    ]

viewLoaded : Settings -> Html Event
viewLoaded settings = 
    table [ id "settings" ]
    [   viewThemeDropdown settings.theme [(0, "Light"), (1, "Dark"), (2, "Pink"), (3, "Blueless")] 
    ]

viewThemeDropdown : Int -> List (Int, String) -> Html Event
viewThemeDropdown selectedId possibleValues = 
    tr [id "theme"]
    [   td [] [ text "Theme" ]
    ,   td [] [select [onChange OnThemeChanged] (viewDropdown selectedId possibleValues)]
    ]

onChange : (String -> msg) -> Html.Attribute msg
onChange eventHandler = 
    on "change" (JSON.map eventHandler (JSON.at ["target", "value"] JSON.string))

viewDropdown : Int -> List (Int, String) -> List (Html Event)
viewDropdown selectedValue possibleValues = 
    List.map (viewDropdownOption selectedValue) possibleValues

viewDropdownOption : Int -> (Int, String) -> Html Event
viewDropdownOption selectedValue possibleValue =
    let
        (index, name) = possibleValue
    in
        option [selected ( selectedValue == index )] [ text name ]

settingsDecoder : JSON.Decoder (Settings)
settingsDecoder =
    JSON.map Settings
        (field "theme" int)

themeDecoder : JSON.Value -> String
themeDecoder value =
    case JSON.decodeValue JSON.string value of
        Ok str -> str
        Err _ -> ""

mapThemeValue : String -> Int
mapThemeValue str = 
    case str of
        "Light" -> 0
        "Dark" -> 1
        "Pink" -> 2
        "Blueless" -> 3
        _ -> 0