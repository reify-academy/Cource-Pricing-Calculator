module Main exposing (main)

-- import Html.Attributes as Attrs exposing (..)

import Browser
import Element exposing (..)
import Element.Background exposing (..)
import Element.Border exposing (rounded)
import Element.Input as Input
import Html exposing (Html)
import Html.Events exposing (..)


main =
    Browser.sandbox { init = init, view = view, update = update }


total =
    600


defaultHours =
    20


costPerMonth =
    2000


type alias Model =
    { hoursPerMonth : Int }


type Msg
    = HoursChanged Float



-- | ManualChange String


init : Model
init =
    { hoursPerMonth = defaultHours }


update : Msg -> Model -> Model
update msg model =
    case msg of
        HoursChanged hours ->
            { model | hoursPerMonth = round hours }



-- ManualChange value ->
--     { model | hoursPerMonth = Maybe.withDefault defaultHours (String.toInt value) }


renderTotal : String -> Int -> Element Msg
renderTotal label number =
    el [] <| text (String.fromInt number ++ " " ++ label)


view : Model -> Html Msg
view model =
    let
        hours =
            model.hoursPerMonth

        totalWeeks =
            total // model.hoursPerMonth

        totalMonth =
            totalWeeks // 4

        totalCost =
            costPerMonth * totalMonth
    in
    layout
        [ padding 10
        ]
    <|
        column [ width fill, spacingXY 0 20 ]
            [ el [ centerX ] <|
                text "What is the total cost of the program ?"
            , Input.slider
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
                { min = 10
                , max = 60
                , label = Input.labelAbove [] (text (String.fromInt hours ++ " hours commited per week"))
                , onChange = HoursChanged
                , value = toFloat hours
                , step = Just 1
                , thumb = Input.defaultThumb
                }
            , renderTotal "weeks" totalWeeks
            , renderTotal "months" totalMonth
            , renderTotal "$" totalCost
            ]
