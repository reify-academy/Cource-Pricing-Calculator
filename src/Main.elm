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


defaultTotal =
    480


defaultSessionsPerMonths =
    0


defaultCostPerMonth =
    2000


type alias Model =
    { sessionsPerMonth : Int
    , config : Flags
    }


type alias Flags =
    { costPerMonth : Maybe Int
    , totalNumberOfHours : Maybe Int
    }


type Msg
    = NumberOfSessionsChanged Float


flagsDecoder : D.Decoder Flags
flagsDecoder =
    D.map2 Flags (D.maybe (D.field "costPerMonth" D.int)) (D.maybe (D.field "totalNumberOfHour" D.int))


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


renderTotal : String -> Int -> Element Msg
renderTotal label number =
    wrappedRow []
        [ el [ Font.bold ] <| text (String.fromInt number)
        , el [] <| text (" " ++ label)
        ]


renderSessionsPerMonth numberOfSessions =
    if numberOfSessions == 0 then
        "No sessions with a mentor."

    else if numberOfSessions == 1 then
        String.fromInt numberOfSessions ++ " session with a mentor"

    else
        String.fromInt numberOfSessions ++ " sessions with a mentor"


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
                , Element.Background.color (Element.rgb 1 1 1)
                ]
        }


headingStyle =
    [ Font.bold, Font.underline, width fill ]


costPerMonth : Model -> Int
costPerMonth =
    Maybe.withDefault defaultCostPerMonth
        << .costPerMonth
        << .config


total : Model -> Int
total =
    Maybe.withDefault defaultTotal
        << .totalNumberOfHours
        << .config


view : Model -> Html Msg
view model =
    let
        numberOfSessions =
            model.sessionsPerMonth

        totalWeeks =
            total model // model.sessionsPerMonth

        totalMonth =
            totalWeeks // 4

        totalCost =
            costPerMonth model * totalMonth
    in
    layout
        [ padding 10
        ]
    <|
        column [ width fill, spacingXY 0 20 ]
            [ el [ centerX ] <|
                text "Program Cost Calculator"
            , renderSlider numberOfSessions
            , paragraph headingStyle [ text "How long will it take to learn how to build my project?" ]
            , renderTotal "weeks" totalWeeks
            , renderTotal "months approximately" totalMonth
            , paragraph headingStyle [ text "How much will it cost?" ]
            , el [] <| text ("$" ++ " " ++ String.fromInt totalCost)
            ]
