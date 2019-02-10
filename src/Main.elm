module Main exposing (main)

import Browser
import Element exposing (..)
import Element.Background exposing (..)
import Element.Border exposing (rounded)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Html.Events exposing (..)
import Json.Decode as D


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


defaultProgramCost =
    150


defaultSessionsPerMonths =
    0


defaultCostPerSession =
    115


type alias Model =
    { sessionsPerMonth : Int
    , config : Flags
    }


type alias Flags =
    { costPerSession : Maybe Int
    , programCost : Maybe Int
    }


type Msg
    = NumberOfSessionsChanged Float


flagsDecoder : D.Decoder Flags
flagsDecoder =
    D.map2 Flags (D.maybe (D.field "costPerSession" D.int)) (D.maybe (D.field "programCost" D.int))


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { sessionsPerMonth = defaultSessionsPerMonths
      , config = flags
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NumberOfSessionsChanged numberOfSessions ->
            ( { model | sessionsPerMonth = round numberOfSessions }, Cmd.none )


renderSessionsPerMonth numberOfSessions =
    if numberOfSessions == 0 then
        "No sessions with a mentor."

    else if numberOfSessions == 1 then
        String.fromInt numberOfSessions ++ " session with a mentor per month."

    else
        String.fromInt numberOfSessions ++ " sessions with a mentor per month."


renderSlider : Int -> Element Msg
renderSlider numberOfSessions =
    Input.slider
        [ Element.height (Element.px 30)

        -- Here is where we're creating/styling the "track"
        , Element.behindContent
            (Element.el
                [ Element.width Element.fill
                , Element.height (Element.px 2)
                , Element.centerY
                , Element.Background.color (rgb255 52 101 164)
                , Element.Border.rounded 2
                ]
                Element.none
            )
        ]
        { min = defaultSessionsPerMonths
        , max = 60
        , label = Input.labelAbove [] (text (renderSessionsPerMonth numberOfSessions))
        , onChange = NumberOfSessionsChanged
        , value = toFloat numberOfSessions
        , step = Just 1
        , thumb =
            Input.thumb
                [ Element.width (Element.px 12)
                , Element.height (Element.px 20)
                , Element.Border.width 1
                , Element.Border.color (Element.rgb 0.5 0.5 0.5)
                , Element.Background.color (Element.rgb255 76 181 171)
                ]
        }


programCost : Model -> Int
programCost =
    Maybe.withDefault defaultProgramCost
        << .programCost
        << .config


costPerSession : Model -> Int
costPerSession =
    Maybe.withDefault defaultCostPerSession
        << .costPerSession
        << .config


view : Model -> Html Msg
view model =
    let
        numberOfSessions =
            model.sessionsPerMonth

        sessionsCost =
            numberOfSessions * costPerSession model

        totalCost =
            programCost model + sessionsCost
    in
    layout
        [ padding 10
        ]
    <|
        column [ width fill, spacingXY 0 20, paddingXY 50 0 ]
            [ el [ centerX ] <|
                text "Reify Cost Calculator"
            , renderSlider numberOfSessions
            , paragraph []
                [ text "The total cost of the program: "
                , el [ Font.bold ] <| text ("$" ++ " " ++ String.fromInt totalCost ++ " per month")
                ]
            ]
