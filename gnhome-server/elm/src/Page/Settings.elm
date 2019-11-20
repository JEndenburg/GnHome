port module Page.Settings exposing (..)

import Html exposing (Html, text, div, hr, table, tr, td, select, option)
import Html.Attributes exposing (class, id)
import Json.Decode as JSON exposing (field, int)

import ContentUtil

type Model
    = Loading
    | Loaded Settings
    | Failed

type alias Settings = Int

type Event
    = OnSettingsJSONReceived JSON.Value


port getSettings : () -> Cmd msg
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
    [   viewTableRowDropdown "theme" "Theme" settings ["Light", "Dark"]
    ]

viewTableRowDropdown : String -> String -> Int -> List String -> Html Event
viewTableRowDropdown rowId name value possibleValues = 
    tr [id rowId]
    [   td [] [ text name ]
    ,   select [] (viewDropdown possibleValues)

    ]

viewDropdown : List String -> List (Html Event)
viewDropdown possibleValues = 
    List.map (viewDropdownOption) possibleValues

viewDropdownOption : String -> Html Event
viewDropdownOption possibleValue =
    option [] [ text possibleValue ]

settingsDecoder : JSON.Decoder (Settings)
settingsDecoder =
    field "theme" int