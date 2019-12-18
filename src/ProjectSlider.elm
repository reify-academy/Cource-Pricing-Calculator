module ProjectSlider exposing (Msg(..), viewHourEstimates, hoursEstimates)

import Array
import Element exposing (..)
import Element.Background exposing (..)
import Element.Border exposing (rounded)
import Element.Font as Font
import Element.Input as Input


type alias Estimate =
    { name : String, agencyHours : Int, developerHours : Int }


type Msg
    = HourEstimatesChanged Float


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

        agencyDuration =
            String.fromInt <| calculateAgencyDuration selectedEstimate.agencyHours

        developerDuration =
            String.fromInt <| calculateDeveloperDuration selectedEstimate.developerHours

        agencyCost =
            calculateCost selectedEstimate.agencyHours

        developerCost =
            calculateCost selectedEstimate.developerHours

        selectedEstimates =
            [ { label = "Developer Cost"
              , value = String.fromInt developerCost
              , duration = developerDuration
              }
            , { label = "Agency Cost"
              , value = String.fromInt agencyCost
              , duration = agencyDuration
              }
            ]

        edges =
            { top = 0
            , right = 0
            , bottom = 0
            , left = 0
            }

        estimatesView =
            Element.table []
                { data = selectedEstimates
                , columns =
                    [ { header = el [ Font.bold ] <| text "Description"
                      , width = fill
                      , view =
                            \row ->
                                el [ paddingEach { edges | top = 10 } ] <| Element.text row.label
                      }
                    , { header = el [ Font.bold, Font.center ] <| text "Cost"
                      , width = fill
                      , view =
                            \row ->
                                el [ paddingEach { edges | top = 10 }, Font.center ] <|
                                    Element.text <|
                                        "$"
                                            ++ row.value
                      }
                    , { header = el [ Font.bold ] <| text "Duration"
                      , width = fill
                      , view =
                            \row ->
                                el [ paddingEach { edges | top = 10 } ] <| Element.text (row.duration ++ " month(s)")
                      }
                    ]
                }
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
        , label =
            Input.labelBelow []
                (column []
                    [ paragraph [ Font.center, Font.size 24, paddingEach { edges | bottom = 10 } ] [ el [] <| text ("Project Name: " ++ selectedEstimate.name) ]
                    , estimatesView
                    ]
                )
        , onChange = HourEstimatesChanged
        , value = selectedEstimateIndex
        , step = Just 1

        -- this is the slider
        , thumb =
            Input.thumb
                [ Element.width (Element.px 12)
                , Element.height (Element.px 20)
                , Element.Border.width 10
                , Element.Border.color (Element.rgb 0.5 0.5 0.5)
                , Element.Border.rounded 10
                , Element.Background.color (Element.rgb255 0 0 0)
                ]
        }


averageCostOfDeveloperPerHour =
    85


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


calculateDeveloperDuration : Int -> Int
calculateDeveloperDuration hours =
    hours // 30


calculateAgencyDuration : Int -> Int
calculateAgencyDuration hours =
    hours // 60


calculateCost : Int -> Int
calculateCost =
    (*) averageCostOfDeveloperPerHour


airbnbagencyHours =
    600
