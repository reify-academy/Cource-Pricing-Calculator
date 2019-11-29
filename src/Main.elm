module Main exposing (main)

import Array
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


minimumSessionsPerMonths =
    4


defaultCostPerSession =
    125


type alias Model =
    { sessionsPerMonth : Int
    , config : Flags
    , selectedEstimate : Float
    }


type alias Flags =
    { costPerSession : Maybe Int
    , programCost : Maybe Int
    }


type Msg
    = NumberOfSessionsChanged Float
    | HourEstimatesChanged Float


flagsDecoder : D.Decoder Flags
flagsDecoder =
    D.map2 Flags (D.maybe (D.field "costPerSession" D.int)) (D.maybe (D.field "programCost" D.int))


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { sessionsPerMonth = minimumSessionsPerMonths
      , config = flags
      , selectedEstimate = 0
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NumberOfSessionsChanged numberOfSessions ->
            ( { model | sessionsPerMonth = round numberOfSessions }, Cmd.none )

        HourEstimatesChanged selectedEstimate ->
            ( { model | selectedEstimate = selectedEstimate }, Cmd.none )


renderSessionsPerMonth numberOfSessions =
    if numberOfSessions == 0 then
        "No sessions with a mentor."

    else if numberOfSessions == 1 then
        String.fromInt numberOfSessions ++ " session with a mentor per month."

    else
        String.fromInt numberOfSessions ++ " sessions with a mentor per month."


renderSlider : Int -> Element Msg
renderSlider numberOfSessions =
    let
        numberOfSessionsLabel : Element Msg
        numberOfSessionsLabel =
            el [] <| text (renderSessionsPerMonth numberOfSessions)
    in
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
        { min = minimumSessionsPerMonths
        , max = 20
        , label = Input.labelAbove [] (paragraph [] [ numberOfSessionsLabel ])
        , onChange = NumberOfSessionsChanged
        , value = toFloat numberOfSessions
        , step = Just 1
        , thumb =
            Input.thumb
                [ Element.width (Element.px 12)
                , Element.height (Element.px 20)
                , Element.Border.width 1
                , Element.Border.color (Element.rgb 0.5 0.5 0.5)
                , Element.Border.rounded 10
                , Element.Background.color (Element.rgb255 0 0 0)
                ]
        }


averageCostOfDeveloperPerHour =
    85


type alias Estimate =
    { name : String, agencyHours : Int, developerHours : Int }


hoursEstimates : List Estimate
hoursEstimates =
    [ { agencyHours = 125
      , developerHours = 100
      , name = "Minimal Reddit"
      }
    , { developerHours = 175
      , agencyHours = 220
      , name = "Real Reddit"
      }
    , { agencyHours = 440
      , developerHours = 350
      , name = "Etsy"
      }
    , { agencyHours = 600
      , developerHours = 500
      , name = "AirBnB"
      }
    ]


airbnbDevHours =
    500


totalDeveloperCost =
    airbnbDevHours * averageCostOfDeveloperPerHour


agencyCost =
    averageCostOfDeveloperPerHour * airbnbagencyHours


airbnbagencyHours =
    600



-- calcDeveloperEquivalent : Float -> Int
-- calcDeveloperEquivalent numberOfSessions =
--     numberOfSessions * 5


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


viewHourEstimates : Float -> List Estimate -> Element Msg
viewHourEstimates selectedEstimateIndex estimates =
    let
        estimatesArray =
            Array.fromList estimates

        selectedEstimate : Estimate
        selectedEstimate =
            let
                candidate =
                    Array.get (round selectedEstimateIndex) estimatesArray

                default =
                    { agencyHours = 125
                    , developerHours = 100
                    , name = "Minimal Reddit"
                    }
            in
            Maybe.withDefault default candidate

        selectedEstimateText =
            selectedEstimate.name
    in
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
        { min = 0
        , max = toFloat <| List.length estimates - 1
        , label = Input.labelAbove [] (paragraph [] [ text selectedEstimateText ])
        , onChange = HourEstimatesChanged
        , value = selectedEstimateIndex
        , step = Just 1
        , thumb =
            Input.thumb
                [ Element.width (Element.px 12)
                , Element.height (Element.px 20)
                , Element.Border.width 1
                , Element.Border.color (Element.rgb 0.5 0.5 0.5)
                , Element.Border.rounded 10
                , Element.Background.color (Element.rgb255 0 0 0)
                ]
        }


viewTotalCost : Model -> Element Msg
viewTotalCost model =
    let
        numberOfSessions =
            model.sessionsPerMonth

        sessionsCost =
            numberOfSessions * costPerSession model

        totalCost =
            programCost model + sessionsCost
    in
    paragraph []
        [ text "The total cost of the program: "
        , el [ Font.bold ] <| text ("$" ++ " " ++ String.fromInt totalCost ++ " per month")
        ]


viewSessionsPerWeek : Model -> Element Msg
viewSessionsPerWeek model =
    let
        sessionsPerWeek =
            toFloat model.sessionsPerMonth / 4
    in
    paragraph [] [ el [] <| text <| "Average number of sessions per week: " ++ String.fromFloat sessionsPerWeek ]


view : Model -> Html Msg
view model =
    let
        numberOfSessions =
            model.sessionsPerMonth
    in
    layout
        [ padding 10
        , Font.family [ Font.typeface "Montserrat", Font.sansSerif ]
        ]
    <|
        column [ width fill, spacingXY 0 20, paddingXY 50 0 ]
            [ el [ centerX ] <|
                text "Reify Cost Calculator"
            , renderSlider numberOfSessions
            , viewSessionsPerWeek model
            , viewTotalCost model
            , viewHourEstimates model.selectedEstimate hoursEstimates
            ]
